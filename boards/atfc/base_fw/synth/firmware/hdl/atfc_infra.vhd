-- atfc_infra
--
-- All board-specific stuff goes here.
--
-- Dave Newbold, June 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity atfc_infra is
	port(
		eth_clk_p: in std_logic; -- 125MHz MGT clock
		eth_clk_n: in std_logic;
		eth_rx_p: in std_logic; -- Ethernet MGT input
		eth_rx_n: in std_logic;
		eth_tx_p: out std_logic; -- Ethernet MGT output
		eth_tx_n: out std_logic;
		sfp_los: in std_logic;
		clk_ipb_o: out std_logic; -- IPbus clock
		rst_ipb_o: out std_logic;
		clk125_o: out std_logic;
		rst125_o: out std_logic;
		clk200: out std_logic; -- 200MHz unbuffered clock for IDELAYCTRL
		pllclk: out std_logic;
		pllrefclk: out std_logic;
		nuke: in std_logic; -- The signal of doom
		soft_rst: in std_logic; -- The signal of lesser doom
		leds: out std_logic_vector(1 downto 0); -- status LEDs
		debug: out std_logic_vector(3 downto 0);
		mac_addr: in std_logic_vector(47 downto 0); -- MAC address
		ip_addr: in std_logic_vector(31 downto 0); -- IP address
		ipb_in: in ipb_rbus; -- ipbus
		ipb_out: out ipb_wbus
	);

end atfc_infra;

architecture rtl of atfc_infra is

	signal clk125_fr, clk125, clk_ipb, clk_ipb_i, locked, clk_locked, eth_locked, rst125, rst_ipb, rst_ipb_ctrl, rst_eth, onehz, pkt: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal led_p: std_logic_vector(0 downto 0);
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_7s_serdes
		port map(
			clki_fr => clk125_fr,
			clki_125 => clk125,
			clko_ipb => clk_ipb_i,
			clko_200 => clk200,
			eth_locked => eth_locked,
			locked => clk_locked,
			nuke => nuke,
			soft_rst => soft_rst,
			rsto_125 => rst125,
			rsto_ipb => rst_ipb,
			rsto_eth => rst_eth,
			rsto_ipb_ctrl => rst_ipb_ctrl,
			onehz => onehz
		);

	clk_ipb <= clk_ipb_i; -- Best to align delta delays on all clocks for simulation
	clk_ipb_o <= clk_ipb_i;
	rst_ipb_o <= rst_ipb;
	clk125_o <= clk125;
	rst125_o <= rst125;

	locked <= clk_locked and eth_locked;
	
	stretch: entity work.led_stretcher
		generic map(
			WIDTH => 1
		)
		port map(
			clk => clk125,
			d(0) => pkt,
			q => led_p
		);

	leds <= (led_p(0), locked and onehz);
	
	debug <= (others => '0');
	
-- Ethernet MAC core and PHY interface
	
	eth: entity work.eth_7s_1000basex_gtp
		port map(
			gt_clkp => eth_clk_p,
			gt_clkn => eth_clk_n,
			gt_txp => eth_tx_p,
			gt_txn => eth_tx_n,
			gt_rxp => eth_rx_p,
			gt_rxn => eth_rx_n,
			sfp_los => sfp_los,
			clk125_out => clk125,
			clk125_fr => clk125_fr,
			pllclk_out => pllclk,
			pllrefclk_out => pllrefclk,
			rsti => rst_eth,
			locked => eth_locked,
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
			ip_addr => ip_addr,
			pkt => pkt
		);

end rtl;
