-- Top-level design for ipbus demo
--
-- This version is for xc7vx485t on //MP7
-- Uses the 7series soft MAC core with GMII interface to an external Gb PHY
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, July 2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.emac_hostbus_decl.all;

entity top is port(
		sysclk_p, sysclk_n: in std_logic;
		gt_clkp, gt_clkn: in std_logic;
		gt_txp, gt_txn: out std_logic;
		gt_rxp, gt_rxn: in std_logic;
		leds: out std_logic_vector(3 downto 0)
	);
end top;

architecture rtl of top is

	signal clk125, clk100, ipb_clk, clk_locked, locked, eth_locked: std_logic;
	signal rst, rst_125, rst_ipb, onehz: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out: ipb_wbus;
	signal ipb_master_in: ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal hostbus_in: emac_hostbus_in;
	signal hostbus_out: emac_hostbus_out;
	signal pkt_rx_led, pkt_tx_led: std_logic;
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_7s_serdes port map(
		sysclk_p => sysclk_p,
		sysclk_n => sysclk_n,
		sysclk_o => clk100,
		clko_ipb => ipb_clk,
		locked => clk_locked,
		nuke => '0',
		rsto => rst,
		rsto_ipb => rst_ipb,
		onehz => onehz
		);
		
	locked <= clk_locked and eth_locked;
	leds(3 downto 0) <= (pkt_rx_led, pkt_tx_led, locked, onehz);
	
--	Ethernet MAC core and PHY interface
	
	eth: entity work.eth_7s_1000basex port map(
		gt_clkp => gt_clkp,
		gt_clkn => gt_clkn,
		gt_txp => gt_txp,
		gt_txn => gt_txn,
		gt_rxp => gt_rxp,
		gt_rxn => gt_rxn,
		clk125_out => clk125,
		rsto => rst_125,
		rsti => rst,
		fr_clk => clk100,
		locked => eth_locked,
		tx_data => mac_tx_data,
		tx_valid => mac_tx_valid,
		tx_last => mac_tx_last,
		tx_error => mac_tx_error,
		tx_ready => mac_tx_ready,
		rx_data => mac_rx_data,
		rx_valid => mac_rx_valid,
		rx_last => mac_rx_last,
		rx_error => mac_rx_error,
		hostbus_in => hostbus_in,
		hostbus_out => hostbus_out
	);
	
-- ipbus control logic

	ipbus: entity work.ipbus_ctrl
		port map(
			mac_clk => clk125,
			rst_macclk => rst_125,
			ipb_clk => ipb_clk,
			rst_ipb => rst_ipb,
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
			mac_addr => X"000A3501EAF2",
			ip_addr => X"c0a80040",
			pkt_rx_led => pkt_rx_led,
			pkt_tx_led => pkt_tx_led
		);

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		ipb_rst => rst_ipb,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
-- Top level ports from here
		hostbus_out => hostbus_in,
		hostbus_in => hostbus_out
	);

end rtl;

