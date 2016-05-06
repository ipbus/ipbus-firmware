-- UDP_master_if
--  Dave Sankey Oct 2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY UDP_master_if IS
  PORT( 
		mac_clk: IN std_logic;
		rst_macclk: IN std_logic;
-- local ports
--  MAC RX
		mac_rx_data: IN std_logic_vector(7 DOWNTO 0);
		mac_rx_error: IN std_logic;
		mac_rx_last: IN std_logic;
		mac_rx_valid: IN std_logic;
--  RARP stuffing
		rarp_rx_data: in std_logic_vector(7 downto 0);
		rarp_rx_last: in std_logic;
		rarp_rx_valid: in std_logic;
		Got_IP_addr: OUT std_logic;
--  TX FIFO
		FIFO_Full: IN std_logic;
		FIFO_data: OUT std_logic_vector(9 DOWNTO 0);
		FIFO_WriteEn: OUT std_logic;
-- remote ports
		master_rx_data: out std_logic_vector(8 DOWNTO 0);
		master_tx_data: in std_logic_vector(8 DOWNTO 0);
		master_tx_err: in std_logic
   );

END UDP_master_if;

architecture rtl of UDP_master_if is

-- Inter FPGA protocol is as follows:
-- a frame is defined from first valid data until last is asserted (i.e. no explicit BOF)
-- Format of the data between the FPGA is 8 bit data & 1 bit valid
-- valid set to 1 implies valid data, valid set to 0 that the data are a K character as below
-- Valid data are put into a FIFO and if a K character is sent the next tick then this is
-- used to assert last and error (corresponding to tuser in the AXI MAC) as follows:
-- K28.0  => last
-- K28.2  => last and error
-- If err is asserted during a frame error is automatically asserted at the end of the frame
--
-- Idle is indicated by K28.1 and K28.5
-- By default K28.5 is used, but in the direction from slave to master K28.1 is used to signify 
-- Got_IP_addr set to 0
--
-- N.B. assumption is that no other K chars are used so tests on K chars are not exhaustive
--
--        HGFEDCBA
-- K28.0 "00011100"
-- K28.1 "00111100"
-- K28.2 "01011100"
-- K28.5 "10111100"

Signal my_rx_data: std_logic_vector(7 DOWNTO 0);
Signal my_rx_error, my_rx_last, my_rx_valid, Got_IP_addr_sig: std_logic;

Begin

With Got_IP_addr_sig select my_rx_data <=
  mac_rx_data when '1',
  rarp_rx_data when Others;

With Got_IP_addr_sig select my_rx_valid <=
  mac_rx_valid when '1',
  rarp_rx_valid when Others;

With Got_IP_addr_sig select my_rx_last <=
  mac_rx_last when '1',
  rarp_rx_last when Others;

With Got_IP_addr_sig select my_rx_error <=
  mac_rx_error when '1',
  '0' when Others;

Got_IP_addr <= Got_IP_addr_sig;

rx_data_block:  process(mac_clk)
  variable next_last, next_error, valid, last, error: std_logic;
  variable data: std_logic_vector(7 DOWNTO 0);
  begin
    If rising_edge(mac_clk) then
      next_last := '0';
      next_error := '0';
      valid := '0';
      If rst_macclk = '1' then
	data := "10111100";
      ElsIf my_rx_valid = '1' then
        data := my_rx_data;
	next_last := my_rx_last;
	next_error := my_rx_error;
	valid := '1';
-- End of frame, send K28.0 or K28.2
      ElsIf last = '1' then
        data := "0" & error & "011100";
-- Idle, send K28.5
      Else
        data := "10111100";
      End If;
      master_rx_data <= data & valid
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      last := next_last;
      error := next_error;
    end if;
  end process rx_data_block;

tx_data_block:  process(mac_clk)
  variable next_valid, valid, error, last, error_pending, frame, Got_IP : std_logic;
  variable next_data, data: std_logic_vector(7 DOWNTO 0);
  begin
    If rising_edge(mac_clk) then
      next_valid := '0';
      next_data := (Others => '0');
      last := '0';
      error := '0';
      If rst_macclk = '1' then
        frame := '0';
	valid := '0';
	error_pending := '0';
	Got_IP := '0';
      ElsIf master_tx_data(0) = '1' then
-- Incoming Data from slave: ignore data until it's got its IP address...
        next_valid := Got_IP;
	frame := Got_IP;
	next_data := master_tx_data(8 downto 1);
      ElsIf master_tx_data(5 downto 1)= "11100" then
-- K28.n
        If (master_tx_data(8)= '0') and (master_tx_data(6) = '0') then
-- K28.0 or K28.2
          last := '1';
	  error := master_tx_data(7) or error_pending;  -- K28.2
	  frame := '0';
	  error_pending := '0';
	ElsIf master_tx_data(7 downto 6)= "01" then
-- K28.1 or K28.5...
          Got_IP := master_tx_data(8);
	End If;
      End If;
-- Capture transmission error during a packet.  This logic will ignore an 
-- error flagged on the K28.0 and K28.2 character, but that should be OK
      If (master_tx_err = '1') or (FIFO_Full = '1') then
        error_pending := frame;
      End If;
      FIFO_data <= data & error & last
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      FIFO_WriteEn <= valid
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      Got_IP_addr_sig <= Got_IP
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      data := next_data;
      valid := next_valid;
    end if;
  end process tx_data_block;

End rtl;
