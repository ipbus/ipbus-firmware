-- Top-level design for ipbus demo
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 16/7/12

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;

entity top is port(
	leds: out std_logic_vector(2 downto 0);
	sgmii_clkp, sgmii_clkn: in std_logic;
	sgmii_txp, sgmii_txn: out std_logic;
	sgmii_rxp, sgmii_rxn: in std_logic;
	phy_rstb: out std_logic;
	gt_txp, gt_txn: out std_logic;
	gt_rxp, gt_rxn: in std_logic
	);

end top;

architecture rtl of top is

	signal clk125, clk125_fr, ipb_clk, eth_locked, clk_locked, rst_125, rst_ipb, rst_eth, onehz: std_logic;
	signal clk125b, eth_lockedb, rst_125b: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_req, ipb_grant: std_logic;
	signal mac_tx_datab, mac_rx_datab: std_logic_vector(7 downto 0);
	signal mac_tx_validb, mac_tx_lastb, mac_tx_errorb, mac_tx_readyb, mac_rx_validb, mac_rx_lastb, mac_rx_errorb: std_logic;
	signal ipb_reqb, ipb_grantb: std_logic;
	signal ipb_master_out, ipb_master_outb, ipb_out: ipb_wbus;
	signal ipb_master_in, ipb_master_inb, ipb_in: ipb_rbus;
	signal sys_rst: std_logic;	

begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_v6_serdes_noxtal
		port map(
			clki_125_fr => clk125_fr,
			clki_125 => clk125,
			clki_125b => clk125b,
			clko_ipb => ipb_clk,
			eth_locked => eth_locked,
			eth_lockedb => eth_lockedb,
			locked => clk_locked,
			nuke => sys_rst,
			rsto_125 => rst_125,
			rsto_125b => rst_125b,
			rsto_ipb => rst_ipb,
			rsto_eth => rst_eth,
			onehz => onehz
		);
		
	leds <= eth_locked or eth_lockedb & clk_locked & onehz;
	
--	Ethernet MAC core and PHY interface
	
	eth: entity work.eth_v6_sgmii
		port map(
			sgmii_clkp => sgmii_clkp,
			sgmii_clkn => sgmii_clkn,
			sgmii_txp => sgmii_txp,
			sgmii_txn => sgmii_txn,
			sgmii_rxp => sgmii_rxp,
			sgmii_rxn => sgmii_rxn,		
			clk125_o => clk125,
			clk125_fr => clk125_fr,
			rst => rst_eth,
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
	
	phy_rstb <= not rst_ipb;
	
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
			ipb_req => ipb_req,
			ipb_grant => ipb_grant,
			mac_addr => X"020ddba1159a",
			ip_addr => X"c0a80010", -- 192.168.0.16
			pkt_rx_led => open,
			pkt_tx_led => open
		);
		
--	Ethernet MAC core and PHY interface
	
	ethb: entity work.eth_v6_basex
		port map(
			gt_clkp => sgmii_clkp,
			gt_clkn => sgmii_clkn,
			gt_txp => gt_txp,
			gt_txn => gt_txn,
			gt_rxp => gt_rxp,
			gt_rxn => gt_rxn,		
			clk125_o => clk125b,
			clk125_fr => open,
			rst => rst_eth,
			locked => eth_lockedb,
			tx_data => mac_tx_datab,
			tx_valid => mac_tx_validb,
			tx_last => mac_tx_lastb,
			tx_error => mac_tx_errorb,
			tx_ready => mac_tx_readyb,
			rx_data => mac_rx_datab,
			rx_valid => mac_rx_validb,
			rx_last => mac_rx_lastb,
			rx_error => mac_rx_errorb
		);

-- ipbus control logic

	ipbusb: entity work.ipbus_ctrl
		port map(
			mac_clk => clk125b,
			rst_macclk => rst_125b,
			ipb_clk => ipb_clk,
			rst_ipb => rst_ipb,
			mac_rx_data => mac_rx_datab,
			mac_rx_valid => mac_rx_validb,
			mac_rx_last => mac_rx_lastb,
			mac_rx_error => mac_rx_errorb,
			mac_tx_data => mac_tx_datab,
			mac_tx_valid => mac_tx_validb,
			mac_tx_last => mac_tx_lastb,
			mac_tx_error => mac_tx_errorb,
			mac_tx_ready => mac_tx_readyb,
			ipb_out => ipb_master_outb,
			ipb_in => ipb_master_inb,
			ipb_req => ipb_reqb,
			ipb_grant => ipb_grantb,
			mac_addr => X"020ddba1159b",
			ip_addr => X"c0a80011", -- 192.168.0.17
			pkt_rx_led => open,
			pkt_tx_led => open
		);
		
-- ipbus arbitrator

	arb: entity work.ipbus_arb
		port map(
			clk => ipb_clk,
			rst => rst_ipb,
			ipb_m_out(0) => ipb_master_out,
			ipb_m_in(0) => ipb_master_in,
			ipb_req(0) => ipb_req,
			ipb_grant(0) => ipb_grant,
			ipb_m_out(1) => ipb_master_outb,
			ipb_m_in(1) => ipb_master_inb,
			ipb_req(1) => ipb_reqb,
			ipb_grant(1) => ipb_grantb,
			ipb_out => ipb_out,
			ipb_in => ipb_in
		);

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		ipb_rst => rst_ipb,
		ipb_in => ipb_out,
		ipb_out => ipb_in,
		rst_out => sys_rst
	);

end rtl;

