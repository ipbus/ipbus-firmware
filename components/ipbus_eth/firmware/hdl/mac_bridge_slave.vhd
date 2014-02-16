-- mac_bridge_slave
--
-- Bridges MAC - ipbus interface to an external device via a serdes link
--
-- This is the slave side which lives in the device without physical ethernet link
--
-- Dave Newbold, May 2013

library ieee;
use ieee.std_logic_1164.all;

entity mac_bridge_slave is 
	port(
		gt_clk_p, gt_clk_n: in std_logic;
		gt_tx_p, gt_tx_n: out std_logic;
		gt_rx_p, gt_rx_n: in std_logic;
		clk125_out: out std_logic;
		clk125_fr: out std_logic;
		rsti: in std_logic;
		locked: out std_logic;
		tx_data: in std_logic_vector(7 downto 0);
		tx_valid: in std_logic;
		tx_last: in std_logic;
		tx_error: in std_logic;
		tx_ready: out std_logic;
		rx_data: out std_logic_vector(7 downto 0); -- AXI4 style MAC signals
		rx_valid: out std_logic;
		rx_last: out std_logic;
		rx_error: out std_logic
	);

end mac_bridge_slave;

architecture rtl of mac_bridge_slave is
  
begin

	gt_tx_p <= '0';
	gt_tx_n <= '0';

	clk125_out <= '0';
	clk125_fr <= '0';
	locked <= '0';

	tx_ready <= '0';
	rx_data <= X"00";
	rx_valid <= '0';
	rx_last <= '0';
	rx_error <= '0';
			
end rtl;

