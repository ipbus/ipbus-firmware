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
		slave_rx_data: in std_logic_vector(7 DOWNTO 0);
		slave_rx_kchar: in std_logic;
		slave_rx_err: in std_logic;
		slave_tx_ready: in std_logic;
		slave_tx_data: out std_logic_vector(7 DOWNTO 0);
		slave_tx_kchar: out std_logic
   );

END UDP_slave_if;
