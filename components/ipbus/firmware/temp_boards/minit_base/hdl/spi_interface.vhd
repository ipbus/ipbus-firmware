
----------------------------------------------------------------------------------
-- Company: Imperial College London
--
-- Engineer: Greg Iles
--
-- Description: Testbench for SPI uC-FPGA configuration interface.
--              Run test bench for 25 us.  The test bench writes 
--              and read back from the ram.  It then writes/reads 
--              back handshake flags that are stored in the status 
--              reg.  The testbench will abort if there are any 
--              read back errors.
--
-- Revision : 1.0  -- Intial design
-- Revision : 2.0  -- Added config ready/request signals and made fpga
--                    interface compatible with ipbus.
-- Revision : 3.0  -- Added IpBus transaction request for Dave
-- Revision : 3.1  -- Split read and write RAM buffers (Dave)
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
-- use ieee.std_logic_arith;
-- use ieee.numeric_std;
library UNISIM;
use UNISIM.vcomponents.all;

entity spi_interface is
port(
    -- The fpga clk/rst used to drive the SPI interface
    -- Needs to be musch faster than SPI clk   
    -- Tested with 125MHz fpga clk and 10MHz SPI clk.    
    clk:                in std_logic;
    rst:                in std_logic;
    -- SPI interface
    spi_miso:           out std_logic;
    spi_mosi:           in std_logic;
    spi_sck:            in std_logic;
    spi_cs_b:           in std_logic;
    -- User clk/rst
    user_clk:           in std_logic;
    user_rst:           in std_logic;
    -- Config handshake
    cfgreq_in:          in std_logic;
    cfgrdy_out:         out std_logic;
    -- IpBus handshake
    transrdy_out:         out std_logic;    
    transdone_in:          in std_logic;
    -- Interface to buffer    
    buf_waddr_in:       in std_logic_vector(9 downto 0);
    buf_wdata_in:      in std_logic_vector(31 downto 0);
    buf_wen_in:        in std_logic;
	 buf_raddr_in:			in std_logic_vector(9 downto 0);
    buf_rdata_out:     out std_logic_vector(31 downto 0));  
end spi_interface;

architecture behave of spi_interface is

  signal sck_sreg, si_sreg, cs_sreg: std_logic_vector(2 downto 0);
  signal add_upper_byte: std_logic;
  signal si_error, si_active, si_byte_valid: std_logic;
  signal si_byte: std_logic_vector(7 downto 0);
  signal si_index: integer range 0 to 7;
  signal si_timeout: integer range 0 to 1073741823;
  constant timeout_max: integer := 1073741823;
  signal r_nw: std_logic;
  
  -- RAM interface on SPI side
  signal add_byte_int: integer range 0 to 65535;
  signal add_byte: std_logic_vector(15 downto 0);
  signal add_byte_first: std_logic;
  signal rd_byte, wt_byte: std_logic_vector(7 downto 0);
  signal rd_byte_req, rd_byte_resp: std_logic_vector(7 downto 0);
  signal wt_byte_valid, wea_req, wea_resp: std_logic;

  signal so_byte_valid, so_finished: std_logic;
  signal so_index: integer range 0 to 7;
  signal so_data, so_valid, so_error: std_logic;
  signal so_byte: std_logic_vector(7 downto 0);
  signal so_wait: natural range 0 to 7;

  attribute enum_encoding : string;

  type type_rx_state is (RX_IDLE, RX_BYTE, RX_ACTIVE);
  attribute enum_encoding of type_rx_state : type is "00 01 10";
  signal rx_state: type_rx_state;
  
  type type_tx_state is (TX_IDLE, TX_BYTE, TX_END);
  attribute enum_encoding of type_tx_state : type is "00 01 10";
  signal tx_state: type_tx_state;
  
  type type_scntrl_state is (SCNTRL_IDLE, SCNTRL_ADD, SCNTRL_TX_DATA, SCNTRL_RX_DATA, SCNTRL_WRHF, SCNTRL_RDSR);
  attribute enum_encoding of type_scntrl_state : type is "000 001 010 011 100 101";
  signal scntrl_state: type_scntrl_state;
  
  signal sck_rising_edge, sck_falling_edge: std_logic;
  signal reg_status: std_logic_vector(7 downto 0);

  signal hf1_flag_strobe, hf2_flag_strobe, cfgrdy_strobe, transrdy_strobe: std_logic;
  signal set_flag, clear_flag: std_logic;

  signal cfgreq, cfgrdy, transrdy, transdone: std_logic;

--  component blkram_write_first is
--  generic (
--    WIDTHA      : integer := 8;
--    SIZEA       : integer := 256;
--    ADDRWIDTHA  : integer := 8;
--    WIDTHB      : integer := 32;
--    SIZEB       : integer := 64;
--    ADDRWIDTHB  : integer := 6);
--  port (
--    clkA   : in  std_logic;
--    clkB   : in  std_logic;
--    enA    : in  std_logic;
--    enB    : in  std_logic;
--    weA    : in  std_logic;
--    weB    : in  std_logic;
--    addrA  : in  std_logic_vector(ADDRWIDTHA-1 downto 0);
--    addrB  : in  std_logic_vector(ADDRWIDTHB-1 downto 0);
--    diA    : in  std_logic_vector(WIDTHA-1 downto 0);
--    diB    : in  std_logic_vector(WIDTHB-1 downto 0);
--    doA    : out std_logic_vector(WIDTHA-1 downto 0);
--    doB    : out std_logic_vector(WIDTHB-1 downto 0));
--  end component;
--  
  component blkram_write_first_hard_code is
  port (
    clkA   : in  std_logic;
    clkB   : in  std_logic;
    enA    : in  std_logic;
    enB    : in  std_logic;
    weA    : in  std_logic;
    weB    : in  std_logic;
    ssrA    : in  std_logic;
    ssrB    : in  std_logic; 
    addrA  : in  std_logic_vector(11 downto 0);
    addrB  : in  std_logic_vector(9 downto 0);
    diA    : in  std_logic_vector(7 downto 0);
    diB    : in  std_logic_vector(31 downto 0);
    doA    : out std_logic_vector(7 downto 0);
    doB    : out std_logic_vector(31 downto 0));
  end component;

begin

  -- spi_miso <= so_data when so_valid = '1' else 'Z';
  spi_miso <= so_data;

  sreg_proc: process(clk, rst)
  begin
    if rst = '1' then
      si_sreg <= (others => '0');
      cs_sreg <= (others => '0');
      sck_sreg <= (others => '0');
    elsif (clk'event and clk = '1') then
      -- Oversample SPI clk to avoid metasatbility 
      -- problems and get delayed values.  
      -- FPGA clk >> SPI clk (i.e. 125MHz >> 10MHz)
      si_sreg <= si_sreg(1 downto 0) & spi_mosi;
      cs_sreg <= cs_sreg(1 downto 0) & not spi_cs_b;
      sck_sreg <= sck_sreg(1 downto 0) & spi_sck;
    end if;
  end process;
  
  sck_falling_edge <= '1' when sck_sreg(2 downto 1) = "10" else '0';
  sck_rising_edge <= '1' when sck_sreg(2 downto 1) = "01" else '0';
  
  si_byte_proc: process(clk, rst)
  begin
    if rst = '1' then
      si_error <= '0';
      si_timeout <= timeout_max;
      si_byte_valid <= '0';
      si_byte <= x"00";
      si_byte_valid <= '0';
      si_index <= 0;
      si_active <= '0';
      rx_state <= RX_IDLE;
    elsif (clk'event and clk = '1') then
      case rx_state is
      when RX_IDLE => 
        -- Clear any error
        si_error <= '0';
        si_active <= '0';
        -- Look to see if CS asserted
        if cs_sreg(1) = '1' then
          rx_state <= RX_ACTIVE;
          si_timeout <= timeout_max;
          si_active <= '1';
        end if;
      when RX_ACTIVE => 
        -- Clear any byte received signal;
        si_byte_valid <= '0';
        -- Are we still in valid transaction?
        if (si_timeout = 0) then
           -- Transaction ended unexpectedly
          rx_state <= RX_IDLE;
          si_active <= '0';
          si_error <= '1';
        elsif (cs_sreg(1) = '0')  then
          -- Transaction ended OK
          rx_state <= RX_IDLE;
          si_active <= '0';
        else
          si_timeout <= si_timeout - 1;
          if sck_rising_edge = '1' then
            -- Rising edge of spi_sck.  
            -- Beginning of new byte
            si_byte(7) <= si_sreg(1);
            si_index <= 6;
            si_timeout <= 0;
            rx_state <= RX_BYTE;
            si_timeout <= timeout_max;
            -- Clear any error
            si_error <= '0';
          else
            -- Stay in idle
            rx_state <= RX_ACTIVE;
          end if;
        end if;  
      when RX_BYTE => 
        -- Check for si_timeout (i.e has something gone wrong...)
        if si_timeout = 0 then
          rx_state <= RX_IDLE;
          si_active <= '0';
          si_error <= '1';
        elsif (cs_sreg(1) = '0')  then
          -- Transaction ended prematurely
          rx_state <= RX_IDLE;
          si_active <= '0';
          si_error <= '1';
        else
          si_timeout <= si_timeout - 1;
          if sck_rising_edge = '1' then
            -- Rising edge of spi_sck.  
            -- Load bits one by one...
            si_byte(si_index) <= si_sreg(1);
            if si_index = 0 then
              -- End of byte
              rx_state <= RX_ACTIVE;
              si_byte_valid <= '1';
            else  
              si_index <= si_index - 1;
              rx_state <= RX_BYTE;
            end if;
          end if;
        end if;    
      when others =>
        rx_state <= RX_IDLE;
      end case;
    end if;
  end process;
  

  scntrl_proc: process(clk, rst)
  begin
    if rst = '1' then
      add_upper_byte <= '0';
      add_byte <= (others => '0');
      r_nw <= '0';
      wt_byte <= x"00";
      wt_byte_valid <= '0';
      so_byte <= x"00";
      so_byte_valid <= '0';
      add_byte_first <= '0';  
      so_wait <= 0;
      set_flag <= '0';
      clear_flag <= '0';
      hf1_flag_strobe <= '0';
      hf2_flag_strobe <= '0'; 
      cfgrdy_strobe <= '0';
      transrdy_strobe <= '0';      
    elsif (clk'event and clk = '1') then
      case scntrl_state is
      when SCNTRL_IDLE => 
        -- Defaults
        wt_byte_valid <= '0'; 
        so_byte_valid <= '0';
        hf1_flag_strobe <= '0';
        hf2_flag_strobe <= '0';
        cfgrdy_strobe <= '0';  
        transrdy_strobe <= '0';                
        set_flag <= '0';
        clear_flag <= '0';        
        if (si_byte_valid = '1') and (si_active = '1') then
          -- Begining of new transaction.
          case si_byte is
          when "00000011" => 
            -- READ: Read RAM contents
            scntrl_state <= SCNTRL_ADD;
            add_upper_byte <= '1';
            add_byte_first <= '1';
            r_nw <= '1';
          when "00000010" => 
            -- WRITE: Write RAM contents
            scntrl_state <= SCNTRL_ADD;
            add_upper_byte <= '1';
            add_byte_first <= '1';
            r_nw <= '0';
          when "00000101" => 
            -- RDSR: Read Status Register
             scntrl_state <= SCNTRL_RDSR;           
          when "00000111" => 
            -- WRHF: Write Handshake Flags
            scntrl_state <= SCNTRL_WRHF;           
          when others =>
            scntrl_state <= SCNTRL_IDLE;
          end case;
        end if;
      when SCNTRL_ADD => 
        if (si_active = '0') then
          -- Transaction error.  Return to idle.
          scntrl_state <= SCNTRL_IDLE;
        elsif (si_byte_valid = '1') then 
          if add_upper_byte = '1' then
            add_byte(15 downto 8) <= si_byte;
            add_upper_byte <= '0';
          else
            add_byte(7 downto 0) <= si_byte;
            if r_nw = '1' then
              scntrl_state <= SCNTRL_TX_DATA;
              -- Set wait period to allow recently aquired address to propagate
              so_wait <= 2;
            else
              scntrl_state <= SCNTRL_RX_DATA;
            end if;
          end if;
        end if;
      when SCNTRL_RX_DATA =>
        -- Defaults
        wt_byte_valid <= '0'; 
        if (si_active = '0') then
          -- End transaction.  Return to idle.
          scntrl_state <= SCNTRL_IDLE;
        elsif (si_byte_valid = '1') then
          -- Increment add_byte counter
          if add_byte_first = '1' then
            add_byte_first <= '0';
          else
            -- Only incremend add after first data byte
            add_byte <= add_byte + x"0001";
          end if; 
          -- WRITE DATA
          wt_byte <= si_byte;
          wt_byte_valid <= '1';
        end if;
      when SCNTRL_TX_DATA =>
        if (si_active = '0') then
          -- End transaction.  Return to idle.
          scntrl_state <= SCNTRL_IDLE;
          so_byte_valid <= '0';  
        else
          -- Only send data for transmission after new ram address
          -- has had time to generate to ram contents.
          if so_wait > 0 then
            so_wait <= so_wait -1;
          else
            so_byte_valid <= '1';
            so_byte <= rd_byte;           
            if (si_byte_valid = '1') then 
              add_byte <= add_byte + x"0001";
              so_wait <= 1;
            end if;
          end if;
       end if;
      when SCNTRL_RDSR => 
         if (si_active = '0') then
          -- End transaction.  Return to idle.
          scntrl_state <= SCNTRL_IDLE;
          so_byte_valid <= '0';  
        else
          if si_byte_valid = '0' then
            so_byte_valid <= '1';
            so_byte <= reg_status;
          else
            -- Next byte.  Return to idle.
            scntrl_state <= SCNTRL_IDLE;
            so_byte_valid <= '0';  
          end if;
        end if;
      when SCNTRL_WRHF => 
        if (si_active = '0') then
          -- Transaction error.  Return to idle.
          scntrl_state <= SCNTRL_IDLE;
        elsif (si_byte_valid = '1') then 
          hf1_flag_strobe <= si_byte(7);
          hf2_flag_strobe <= si_byte(6);
          cfgrdy_strobe <= si_byte(5);
          transrdy_strobe <= si_byte(3);         
          set_flag <= si_byte(1);
          clear_flag <= si_byte(0);
          scntrl_state <= SCNTRL_IDLE;
        end if;
      when others =>
          scntrl_state <= SCNTRL_IDLE;
      end case;     

    end if;
  end process;


  so_byte_proc: process(clk, rst)
  begin
    if rst = '1' then
      tx_state <= TX_IDLE;
      so_finished <= '0';
      so_index <= 0;
      so_data <= '0';
      so_valid <= '0';
      so_error <= '0';
    elsif (clk'event and clk = '1') then
      case tx_state is
      when TX_IDLE => 
        -- Clear any status/error flags
        so_finished <= '0';
        so_error <= '0';
        so_index <= 0;
        so_valid <= '0';
        -- Check clk present and cs still asserted before starting transmission.
        if so_byte_valid = '1' and si_active = '1' and sck_falling_edge = '1' then
          tx_state <= TX_BYTE;
          so_data <= so_byte(7);
          so_valid <= '1';
          so_index <= 6;
        end if;
      when TX_BYTE => 
        if si_active = '0' then
          -- Abort transaction.  Master de-asserted CS
          -- Note that transaction will normally finish here
          -- because firmware has to assume that another read 
          -- requested in order to ensure data present on bus
          -- before master reads bus.  The only way to avoid 
          -- this is for the master to keep the spi_sck high while 
          -- deasserting CS. 
          tx_state <= TX_IDLE;
          so_finished <= '1';
        elsif sck_falling_edge = '1' then
          so_data <= so_byte(so_index);
          so_valid <= '1';
          if so_index = 0 then
            tx_state <= TX_END;
          else
            so_index <= so_index -1;
          end if;    
        end if;
      when TX_END => 
        if si_active = '0' then
          -- Abort transaction.  Master de-asserted CS
          tx_state <= TX_IDLE;
          so_finished <= '1';
          so_error <= '1';
        elsif sck_falling_edge = '1' then
          -- Do we need to send another byte?
          if so_byte_valid = '1' then
            -- Send next byte
            tx_state <= TX_BYTE;
            so_data <= so_byte(7);
            so_valid <= '1';
            so_index <= 6;
          else
            -- End of transaction
            tx_state <= TX_IDLE;
            so_finished <= '1';
            so_valid <= '0';
          end if;    
        end if;    
      when others =>
        tx_state <= TX_IDLE;
      end case;
    end if;
  end process;
  
  
  
  reg_status_proc: process(clk, rst)
    variable flags: std_logic_vector(1 downto 0);
  begin
    if rst = '1' then
      reg_status <= x"00";
    elsif (clk'event and clk = '1') then
      -- Indicate config required to uC
      reg_status(4) <= cfgreq;
      -- Indicate transaction finished
      reg_status(2) <= transdone;
      -- Set status flags
      flags := set_flag & clear_flag;
      case flags is
      when "00" =>
        null;
      when "01" =>
        -- Clear regs if strobe present
        if  hf1_flag_strobe = '1' then
          reg_status(7) <= '0';
        end if;
        if  hf2_flag_strobe = '1' then
          reg_status(6) <= '0';
        end if;
        if  cfgrdy_strobe = '1' then
          reg_status(5) <= '0';
        end if; 
        if  transrdy_strobe = '1' then
          reg_status(3) <= '0';
        end if; 
      when "10" =>  
        -- Set regs if strobe present     
        if  hf1_flag_strobe = '1' then
          reg_status(7) <= '1';
        end if;
        if  hf2_flag_strobe = '1' then
          reg_status(6) <= '1';
        end if;
        if  cfgrdy_strobe = '1' then
          reg_status(5) <= '1';
        end if; 
        if  transrdy_strobe = '1' then
          reg_status(3) <= '1';
        end if; 
      when "11" =>
        -- Do nowt.  Can't clear & set regs at the same time.
        null;
      when others =>
        null;
      end case;  
    end if;
  end process;
  
  cfgrdy <= reg_status(5);
  transrdy <= reg_status(3);
 
	rd_byte <= rd_byte_req when add_byte(12)='0' else rd_byte_resp;
	wea_req <= (not add_byte(12)) and wt_byte_valid;
	wea_resp <= add_byte(12) and wt_byte_valid;
 
  blkram_req: blkram_write_first_hard_code
  port map(
    -- PORT A
    clkA   => clk,
    enA    => '1',
    weA    => wea_req,
    ssrA   => rst,
    addrA  => add_byte(11 downto 0),
    diA    => wt_byte,
    doA    => rd_byte_req,
    -- PORT B
    clkB   => user_clk,
    enB    => '1',
    weB    => '0',
    ssrB   => user_rst,
    addrB  => buf_raddr_in,
    diB    => (others => '0'),
    doB    => buf_rdata_out);

  blkram_resp: blkram_write_first_hard_code
  port map(
    -- PORT A
    clkA   => clk,
    enA    => '1',
    weA    => wea_resp,
    ssrA   => rst,
    addrA  => add_byte(11 downto 0),
    diA    => wt_byte,
    doA    => rd_byte_resp,
    -- PORT B
    clkB   => user_clk,
    enB    => '1',
    weB    => buf_wen_in,
    ssrB   => user_rst,
    addrB  => buf_waddr_in,
    diB    => buf_wdata_in,
    doB    => open);

  -- Switch to user clk domain.
  to_user_clk_proc: process(user_clk, user_rst)
    variable transrdy_meta, cfgrdy_meta : std_logic;
  begin
    if user_rst = '1' then
      cfgrdy_out <= '0';
      cfgrdy_meta := '0';
      transrdy_out <= '0';
      transrdy_meta := '0';
    elsif (user_clk'event and user_clk = '1') then
      cfgrdy_meta := cfgrdy;
      cfgrdy_out <= cfgrdy_meta;
      transrdy_meta := transrdy;
      transrdy_out <= transrdy_meta;
    end if;
  end process;

  to_clk_proc: process(clk, rst)
    variable transdone_meta, cfgreq_meta : std_logic;
  begin
    if rst = '1' then
      cfgreq<= '0';
      cfgreq_meta := '0';
      transdone <= '0';
      transdone_meta := '0';
    elsif (clk'event and clk = '1') then
      cfgreq_meta := cfgreq_in;
      cfgreq<= cfgreq_meta;
      transdone_meta := transdone_in;
      transdone <= transdone_meta;
    end if;
  end process;

end behave;
