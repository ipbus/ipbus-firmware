-- Top-level design for ipbus demo
--
-- This version is for simulation of the ipbus firmware and slaves
-- It instantiates behavioural models of the ethernet mac and clock generator
--
-- The sim ethernet mac allows the design to be stimulated with packet information from a file
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, March 2011

library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;

entity top is
end top;

architecture rtl of top is

	signal clk125, ipb_clk, rst: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready: std_logic;
	signal mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out: ipb_wbus;
	signal ipb_master_in: ipb_rbus;
	signal sys_rst: std_logic;
	
begin

--	Simulated clocks

  clocks: entity work.clock_sim
		port map(
			clko125 => clk125,
			clko25 => ipb_clk,
			nuke => sys_rst,
			rsto => rst
		 );

-- Simulated ethernet MAC
	
  eth: entity work.eth_mac_sim
		port map(
			clk => clk125,
			rst => rst,
			tx_data => mac_tx_data,
			tx_valid => mac_tx_valid,
			tx_last => mac_tx_last,
			tx_error => mac_tx_error,
			tx_ready => mac_tx_ready,
			rx_data => mac_rx_data,
			rx_valid => mac_rx_valid,
			rx_last => mac_rx_last,
			rx_error => mac_rx_error
		);
		
-- ipbus control logic

	ipbus: entity work.ipbus_ctrl
		port map(
			mac_clk => clk125,
			rst_macclk => rst,
			ipb_clk => ipb_clk,
			rst_ipb => rst,
			mac_rx_data => mac_rx_data,
			mac_rx_valid => mac_rx_valid,
			mac_rx_last => mac_rx_last,
			mac_rx_error => mac_rx_error,
			mac_tx_data => mac_tx_data,
			mac_tx_valid => mac_tx_valid,
			mac_tx_last => mac_tx_last,
			mac_tx_error => mac_tx_error,
			mac_tx_ready => mac_tx_ready,
			ipb_out => ipb_master_out,
			ipb_in => ipb_master_in,
			mac_addr => X"a0b0c0d1e1f1", -- Careful here, abitrary addresses do not necessarily work
			ip_addr => X"c0a8c902" -- 192.168.201.2
		);

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves
		port map(
			ipb_clk => ipb_clk,
			ipb_rst => rst,
			ipb_in => ipb_master_out,
			ipb_out => ipb_master_in,
			rst_out => sys_rst
		);

end rtl;
