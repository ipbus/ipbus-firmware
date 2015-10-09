-- UDP_master_slave_shim
-- (dummy) interface between master and slave
--
-- In reality you would add your preferred means of transporting these 
-- between the two FPGA.
--
-- The _data ports can be interpreted as input to 8B/10B
-- _err should be asserted if a transmission error is detected
--
-- _pause is the sloppy FIFO signal
--
-- FIFO depth in UDP_master_fifo needs to be set large enough that it can 
-- accommodate the latency on these transfers

--  Dave Sankey Oct 2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY UDP_master_slave_shim IS
  PORT( 
		mac_clk: IN std_logic;
-- master ports
		master_rx_data: in std_logic_vector(8 DOWNTO 0);
		master_tx_pause: in std_logic;

		master_tx_data: out std_logic_vector(8 DOWNTO 0);
		master_tx_err: out std_logic;
-- slave ports
		slave_tx_data: in std_logic_vector(8 DOWNTO 0);

		slave_rx_data: out std_logic_vector(8 DOWNTO 0);
		slave_rx_err: out std_logic;

		slave_tx_pause: out std_logic
   );

END UDP_master_slave_shim;
