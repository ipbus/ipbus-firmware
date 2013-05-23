-- mac_bridge_master
--
-- Bridges MAC - ipbus interface to an external device via a serdes link
--
-- This is the master side which lives in the device with the physical ethernet link
--
-- Dave Newbold, May 2013

library ieee;
use ieee.std_logic_1164.all;

entity mac_bridge_master is 
	port(
		gt_clk_p, gt_clk_n: in std_logic; -- Needs to be frequency-locked to clk125
		gt_tx_p, gt_tx_n: out std_logic;
		gt_rx_p, gt_rx_n: in std_logic;
		clk125: in std_logic;
		rsti: in std_logic;
		locked: out std_logic;
		rx_data: in std_logic_vector(7 downto 0); -- AXI4 style MAC signals
		rx_valid: in std_logic;
		rx_last: in std_logic;
		rx_error: in std_logic;
		tx_data: out std_logic_vector(7 downto 0);
		tx_valid: out std_logic;
		tx_last: out std_logic;
		tx_error: out std_logic;
		tx_ready: in std_logic
	);

end mac_bridge_master;

architecture rtl of mac_bridge_master is
  
begin

	gt_tx_p < ='0';
	gt_tx_n < ='0';
	
	locked <= '0';
	
	tx_data <= X"00";
	tx_valid <= '0';
	tx_last <= '0';
	tx_error <= '0';
	
end rtl;

