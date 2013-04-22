-- Interface between transactor and packet buffers
--
-- This module knows nothing about the ipbus transaction protocol
--
-- Dave Newbold, October 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus_trans_decl.all;

entity transactor_if is
  port(
    clk: in std_logic; 
    rst: in std_logic;
    trans_in: in ipbus_trans_in;
    trans_out: out ipbus_trans_out;
    ipb_req: out std_logic; -- Bus request
    ipb_grant: in std_logic; -- Bus grant
    rx_ready: out std_logic; -- New data is available
    rx_next: in std_logic; -- Request for new data from transactor
    tx_data: in std_logic_vector(31 downto 0); -- Packet data from transactor
    tx_we: in std_logic; -- Transactor data valid
    tx_hdr: in std_logic; -- Header word flag from transactor
    tx_err: in std_logic;
    byte_order: out std_logic; -- Controls byte ordering of input and output packet data
    next_pkt_id: out std_logic_vector(15 downto 0); -- Next expected packet ID
    pkt_rx: out std_logic;
    pkt_tx: out std_logic
   );
 
end transactor_if;

architecture rtl of transactor_if is

	type state_type is (ST_IDLE, ST_HDR, ST_PREBODY, ST_BODY, ST_DONE);
	signal state: state_type;
	
	signal raddr, waddr, haddr, waddrh: unsigned(addr_width - 1 downto 0);
	signal hlen, blen, rctr, wctr: unsigned(15 downto 0);
	signal idata: std_logic_vector(31 downto 0);
	signal first, start: std_logic;
  
begin

	start <= trans_in.pkt_rdy and not trans_in.busy;	

	process(clk)
  begin
  	if rising_edge(clk) then
  
  		if rst = '1' then
  			state <= ST_IDLE;
  		else
				case state is

				when ST_IDLE => -- Starting state
					if start = '1' then
						if trans_in.rdata(31 downto 16) = X"0000" then
							state <= ST_PREBODY;
						else
							state <= ST_HDR;
						end if;
					end if;

				when ST_HDR => -- Transfer packet info
					if rctr = hlen then
						state <= ST_PREBODY;
					end if;
					
				when ST_PREBODY =>
					if ipb_grant = '1' then
						state <= ST_BODY;
					end if;

				when ST_BODY => -- Transfer body
					if (rctr > blen and tx_hdr = '1') or tx_err = '1' then
						state <= ST_DONE;
					end if;

				when ST_DONE => -- Write buffer header
					state <= ST_IDLE;

				end case;
			end if;

		end if;
	end process;

	process(clk)
	begin
		if falling_edge(clk) then
			if state = ST_HDR or (state = ST_BODY and rx_next = '1') or (state = ST_IDLE and start = '1') then
				raddr <= raddr + 1;
			elsif state = ST_DONE or rst = '1' then
				raddr <= (others => '0');
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			
			if state = ST_IDLE and start = '1' then
				hlen <= unsigned(trans_in.rdata(31 downto 16));
				blen <= unsigned(trans_in.rdata(15 downto 0));
			end if;
			
			if state = ST_HDR or (state = ST_BODY and tx_we = '1') then
				waddr <= waddr + 1;
			elsif state = ST_DONE or rst = '1' then
				waddr <= to_unsigned(1, addr_width);
			end if;

			if state = ST_IDLE or state = ST_PREBODY then
				rctr <= X"0001";
			elsif state = ST_HDR or (state = ST_BODY and rx_next = '1') then
				rctr <= rctr + 1;
			end if;

			if state = ST_HDR then
				wctr <= X"0000";
			elsif state = ST_BODY and tx_we = '1' and first = '0' then
				wctr <= wctr + 1;
			end if;
			
			if tx_hdr = '1' then
				haddr <= waddr;
			end if;
			
			if state = ST_PREBODY then
				first <= '1';
			elsif tx_we = '1' then
				first <= '0';
			end if;
			
		end if;
	end process;
	
	ipb_req <= '1' when state = ST_PREBODY or state = ST_BODY else '0';
	
	rx_ready <= '1' when state = ST_BODY and not (rctr > blen) else '0';
		
	idata <= std_logic_vector(hlen) & std_logic_vector(wctr) when state = ST_DONE
		else trans_in.rdata;
		
	waddrh <= (others => '0') when state = ST_DONE else waddr;
	
	trans_out.raddr <= std_logic_vector(raddr);
	trans_out.pkt_done <= '1' when state = ST_DONE else '0';
	trans_out.we <= '1' when state = ST_HDR or (tx_we = '1' and first = '0') or state = ST_DONE else '0';
	trans_out.waddr <= std_logic_vector(haddr) when (state = ST_BODY and tx_hdr = '1') else std_logic_vector(waddrh);
	trans_out.wdata <= tx_data when state = ST_BODY else idata;

	pkt_rx <= '1' when state = ST_IDLE and start = '1' else '0';
	pkt_tx <= '1' when state = ST_DONE else '0';
	
end rtl;

