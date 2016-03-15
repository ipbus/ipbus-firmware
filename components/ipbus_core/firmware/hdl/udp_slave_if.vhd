-- UDP_slave_if
--  Dave Sankey Oct 2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY UDP_slave_if IS
  PORT( 
		mac_clk: IN std_logic;
		rst_macclk: IN std_logic;
-- local ports
--  MAC RX
		mac_rx_data: out std_logic_vector(7 DOWNTO 0);
		mac_rx_error: out std_logic;
		mac_rx_last: out std_logic;
		mac_rx_valid: out std_logic;
--  RARP stuffing
		Got_IP_addr: in std_logic;
--  MAC TX
		mac_tx_ready: out std_logic;
		mac_tx_data: in std_logic_vector(7 DOWNTO 0);
		mac_tx_error: in std_logic;
		mac_tx_last: in std_logic;
		mac_tx_valid: in std_logic;
-- remote ports
		slave_rx_data: in std_logic_vector(8 DOWNTO 0);
		slave_rx_err: in std_logic;
		slave_tx_pause: in std_logic;
		slave_tx_data: out std_logic_vector(8 DOWNTO 0)
   );

END UDP_slave_if;

architecture rtl of UDP_slave_if is

-- Inter FPGA protocol is as follows:
-- a frame is defined from first valid data until last is asserted (i.e. no explicit BOF)
-- Valid data are sent as data with kchar set to 0 (i.e. kchar 0 implies valid data)
-- Valid data are put into a FIFO and if a kchar is sent the next tick then this is
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
-- Got_IP_addr set to 0
--        HGFEDCBA
-- K28.0 "00011100"
-- K28.1 "00111100"
-- K28.2 "01011100"
-- K28.5 "10111100"

Begin

rx_data_block:  process(mac_clk)
  variable next_valid, valid, error, last, error_pending, frame: std_logic;
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
      ElsIf slave_rx_data(0) = '0' then
        next_valid := '1';
	next_data := slave_rx_data(8 downto 1);
	frame := '1';
-- K char.  Only K28.n have these bits not all set to 1 so only check for K28.0 and K28.2
      ElsIf (slave_rx_data(8) = '0') and (slave_rx_data(6 downto 1)= "011100") then
	last := '1';
	error := slave_rx_data(7) or error_pending;  -- K28.2
	frame := '0';
	error_pending := '0';
      End If;
-- Capture transmission error during a packet.  This logic will ignore an 
-- error flagged on  the K28.0 and K28.2 character, but that should be OK
      If slave_rx_err = '1' then
        error_pending := frame;
      End If;
      mac_rx_data <= data
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      mac_rx_error <= error
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      mac_rx_last <= last
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      mac_rx_valid <= valid
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      data := next_data;
      valid := next_valid;
    end if;
  end process rx_data_block;

tx_data_block:  process(mac_clk)
  variable next_last, next_error, kchar, last, error, ready, last_ready: std_logic;
  variable data: std_logic_vector(7 DOWNTO 0);
  begin
    If rising_edge(mac_clk) then
      next_last := '0';
      next_error := '0';
      ready := '0';
      kchar := '1';
      If rst_macclk = '1' then
	data := "00111100";
-- Captured data
      ElsIf mac_tx_valid = '1' and last_ready = '1' then
        data := mac_tx_data;
	next_last := mac_tx_last;
	next_error := mac_tx_error;
	kchar := '0';
-- End of frame, send K28.0 or K28.2
      ElsIf last = '1' then
        data := "0" & error & "011100";
-- Idle, send K28.1 (no IP address) or K28.5 (got IP address)
      Else
        data := Got_IP_addr & "0111100";
      End If;
      If rst_macclk = '0' and mac_tx_valid = '1' and slave_tx_pause = '0' then
	ready := '1';
      End If;
      slave_tx_data <= data & kchar
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      mac_tx_ready <= ready
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      last := next_last;
      error := next_error;
      last_ready := ready;
    end if;
  end process tx_data_block;

End rtl;