-- kc705_basex_infra
--
-- All board-specific stuff goes here.
--
-- Dave Newbold, June 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity pc051a_infra_sim is
	port(
		clk_ipb_o: out std_logic; -- IPbus clock
		rst_ipb_o: out std_logic;
		clk125_o: out std_logic;
		rst125_o: out std_logic;
		nuke: in std_logic; -- The signal of doom
		soft_rst: in std_logic; -- The signal of lesser doom
		mac_addr: in std_logic_vector(47 downto 0); -- MAC address
		ip_addr: in std_logic_vector(31 downto 0); -- IP address
		ipb_in: in ipb_rbus; -- ipbus
		ipb_out: out ipb_wbus
	);

end pc051a_infra_sim;

architecture rtl of pc051a_infra_sim is

	signal clk125_fr, clk125, clk_ipb, clk_ipb_i, rst125, rst_ipb, rst_ipb_ctrl: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clock_sim_7s
		port map(
			clko_125 => clk125,
			clko_ipb => clk_ipb_i,
			locked => open,
			nuke => nuke,
			soft_rst => soft_rst,
			rsto_125 => rst125,
			rsto_ipb => rst_ipb,
			rsto_ipb_ctrl => rst_ipb_ctrl
		);

	clk_ipb <= clk_ipb_i; -- Best to align delta delays on all clocks for simulation
	clk_ipb_o <= clk_ipb_i;
	rst_ipb_o <= rst_ipb;
	clk125_o <= clk125;
	rst125_o <= rst125;
	
-- Ethernet MAC core and PHY interface
	
	eth: entity work.eth_mac_sim
		generic map(
			MULTI_PACKET => true
		)			
		port map(
			clk => clk125,
			rst => rst125,
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
			rst_macclk => rst125,
			ipb_clk => clk_ipb,
			rst_ipb => rst_ipb_ctrl,
			mac_rx_data => mac_rx_data,
			mac_rx_valid => mac_rx_valid,
			mac_rx_last => mac_rx_last,
			mac_rx_error => mac_rx_error,
			mac_tx_data => mac_tx_data,
			mac_tx_valid => mac_tx_valid,
			mac_tx_last => mac_tx_last,
			mac_tx_error => mac_tx_error,
			mac_tx_ready => mac_tx_ready,
			ipb_out => ipb_out,
			ipb_in => ipb_in,
			mac_addr => mac_addr,
			ip_addr => ip_addr
		);

end rtl;
