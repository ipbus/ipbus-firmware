-- The state machine which controls the ipbus itself
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
library work;
use work.ipbus.all;

entity transactor_sm is
  port(
    clk: in std_logic; 
    reset: in std_logic;
    rx_data: in std_logic_vector(31 downto 0); -- input packet data
    rx_ready: in std_logic; -- asserted when valid input packet data is available
    rx_next: out std_logic; -- new input packet data on next cycle when this is asserted
	 tx_func: out std_logic_vector(3 downto 0); -- encodes required transmit function (see transactor_tx)
    byte_order: out std_logic; -- controls byte ordering of input and output packet data
    ipb_out: out ipb_wbus;
    ipb_in: in ipb_rbus);
 
end transactor_sm;

architecture rtl of transactor_sm is

  constant TIMEOUT: unsigned(7 downto 0) := X"ff";
  
  constant TRANS_RD: std_logic_vector(4 downto 0) := "00011";
  constant TRANS_WR: std_logic_vector(4 downto 0) := "00100";
  constant TRANS_RMWB: std_logic_vector(4 downto 0) := "00101";
  constant TRANS_RMWS: std_logic_vector(4 downto 0) := "00110";
  constant TRANS_RDN: std_logic_vector(4 downto 0) := "01000";
  constant TRANS_WRN: std_logic_vector(4 downto 0) := "01001";
  constant TRANS_INFO: std_logic_vector(4 downto 0) := "11101";
 
  type state_type is (ST_IDLE, ST_CHECK_HDR, ST_HDR, ST_WR_INFO, ST_ADDR, ST_BUS_CYCLE, ST_RMW_1, ST_RMW_2, ST_LAST, ST_ERROR);
  signal state: state_type;
  signal last_trans_id: unsigned(10 downto 0);
  signal words: unsigned(8 downto 0);
  signal trans_type: std_logic_vector(4 downto 0);
  signal next_word, ack, strobe, write, ready_d, rmw_cyc, rmw_write, first: std_logic;
  signal addr: unsigned(31 downto 0);
  signal timer: unsigned(7 downto 0);
  signal rmw_coeff, rmw_input, rmw_result: std_logic_vector(31 downto 0);
  signal err_code: std_logic_vector(2 downto 0);
  
begin

  process(clk)
  begin
    if rising_edge(clk) then

      if reset='1' then
        state <= ST_IDLE;
        last_trans_id <= (others => '0');
      else

        case state is

-- Starting state

          when ST_IDLE =>

            byte_order <= '0';
            strobe <= '0';
            next_word <= '0';
            first <= '1';
            
            if rx_ready='1' and ready_d='0' then
              state <= ST_CHECK_HDR;
            else
              state <= ST_IDLE;
            end if;

-- Check for endianness, wait for next word from buffer

          when ST_CHECK_HDR =>

            next_word <= '1';
            if rx_data(31 downto 28)=X"f" then
              byte_order <= '1';
            end if;
             
            state <= ST_HDR;
            
-- Decode header word
            
          when ST_HDR =>
            
            if rx_ready = '0' and first = '0' then
              state <= ST_LAST;
            else
              strobe <= '0';
              trans_type <= rx_data(7 downto 3);

              if rx_data(7 downto 3) = TRANS_RMWB or rx_data(7 downto 3) = TRANS_RMWS then
                words <= to_unsigned(1, 9); -- to correct for issues in software
              else
                words <= unsigned(rx_data(16 downto 8));
              end if;

              rmw_write <= '0';            

              if rx_data(31 downto 28) /= X"1" or rx_data(2) = '1' then
						    err_code <= "000"; -- Bad header
						    state <= ST_ERROR;
--					    elsif rx_data(16 downto 8)/=(8 downto 0 => '0') and unsigned(rx_data(27 downto 17))/=last_trans_id+1 then
--						    err_code <= "001"; -- Non-sequential header ID
--						    state <= ST_ERROR;
					    else
						    if rx_data(16 downto 8) /= (8 downto 0 => '0')then
							    last_trans_id <= unsigned(rx_data(27 downto 17));
						    end if;
						    if rx_data(7 downto 3) = TRANS_INFO then
							    next_word <= '0';
							    state <= ST_WR_INFO;
						    elsif rx_data(16 downto 8) = (8 downto 0 =>'0') then
							    state <= ST_HDR;
						    else
							    state <= ST_ADDR;
						    end if;
              end if;
            end if;
            
            first <= '0';

-- Write last transaction info

          when ST_WR_INFO =>

            next_word <= '1';			
				    state <= ST_HDR;

-- Load address counter
            
          when ST_ADDR =>

            addr <= unsigned(rx_data);
            next_word <= '0';
            if trans_type = TRANS_WR or trans_type = TRANS_WRN then
              write <= '1';
            else
              write <= '0';
            end if;
            
            strobe <= '1';
            words <= words - 1;
            timer <= (others => '0');
                        
            state <= ST_BUS_CYCLE;

-- The bus transaction

          when ST_BUS_CYCLE =>
            
            if ipb_in.ipb_err = '1' then
              strobe <= '0';
		          err_code <= "01" & write; -- Bus error
              state <= ST_ERROR;
            elsif ack = '1' then

              rmw_input <= ipb_in.ipb_rdata;

              if words /= 0 then
                strobe <='1';
                words <= words - 1;
                if trans_type = TRANS_RD or trans_type = TRANS_WR then
                  addr <= addr + 1;
                end if;
                timer <= (others => '0');
                state <= ST_BUS_CYCLE;
              else
                strobe <= '0';
                next_word <= '1';
                if rmw_cyc = '1' and rmw_write = '0' then
                  state <= ST_RMW_1;
                else
                  state <= ST_HDR;
                end if;
              end if;
              
            else
              timer <= timer + 1;
              if timer = TIMEOUT then
					      err_code <= "10" & write; -- Bus timeout
                state <= ST_ERROR;
              else
                state <= ST_BUS_CYCLE;
              end if;
            end if;
            
          when ST_RMW_1 =>
            
            timer <= (others => '0');
            rmw_coeff <= rx_data;
            write <= '1';
            rmw_write <= '1';
            
            if trans_type = TRANS_RMWB then
              state <= ST_RMW_2;
            else
              rmw_result <= std_logic_vector(unsigned(rmw_input) + unsigned(rx_data));
              next_word <= '0';
              strobe <= '1';
              state <= ST_BUS_CYCLE;
            end if;
            
          when ST_RMW_2 =>
            
            rmw_result <= (rmw_input and rmw_coeff) or rx_data;
            next_word <= '0';
            strobe <= '1';
            state <= ST_BUS_CYCLE;

          when ST_LAST =>
                    
            state <= ST_IDLE;

-- Error has occured
                                          
          when ST_ERROR =>

            state <= ST_LAST;

          end case;
      end if;
    end if; 
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      ready_d <= rx_ready;
    end if;
  end process;
  
  rmw_cyc <= '1' when trans_type = TRANS_RMWB or trans_type = TRANS_RMWS else '0';
  
  ack <= ipb_in.ipb_ack or ipb_in.ipb_err;
  rx_next <= next_word or (strobe and ack and write and not rmw_cyc);
  
  with state select tx_func <=
	'1' & err_code when ST_ERROR,
	"0111" when ST_LAST,
	"0100" when ST_HDR,
	"0101" when ST_WR_INFO,
--  "00" & (strobe and ack) & (not write xor rmw_cyc) when ST_BUS_CYCLE,
  "00" & (strobe and ack and (rmw_cyc xor not write)) & (strobe and ack and not (rmw_cyc and not write)) when ST_BUS_CYCLE,
	"0000" when others;

  ipb_out.ipb_addr <= std_logic_vector(addr);
  ipb_out.ipb_write <= write;
  ipb_out.ipb_strobe <= strobe;
 
	ipb_out.ipb_wdata <= rx_data when rmw_cyc='0' else rmw_result;
  
end rtl;
