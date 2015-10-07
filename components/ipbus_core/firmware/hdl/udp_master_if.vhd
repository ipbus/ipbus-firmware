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
		rarp_rx_valid: in std_logic
		Got_IP_addr: OUT std_logic;
--  MAC TX
		mac_tx_ready: IN std_logic;
		mac_tx_data: OUT std_logic_vector(7 DOWNTO 0);
		mac_tx_error: OUT std_logic;
		mac_tx_last: OUT std_logic;
		mac_tx_valid: OUT std_logic;
-- remote ports
		master_rx_data: out std_logic_vector(7 DOWNTO 0);
		master_rx_kchar: out std_logic;
		master_tx_ready: out std_logic;
		master_tx_data: in std_logic_vector(7 DOWNTO 0);
		master_tx_kchar: in std_logic;
		master_tx_err: in std_logic
   );

END UDP_master_if;
