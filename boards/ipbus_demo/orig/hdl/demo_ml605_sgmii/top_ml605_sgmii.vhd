-- Top-level design for ipbus demo
--
-- This version is for xc6slx45 on Digilent ATLYS board
-- Uses the s6 soft TEMAC core with GMII inteface to an external Gb PHY
-- You will need a license for the core
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 16/7/12

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;

entity top is port(
	sysclk_p, sysclk_n: in std_logic;
	leds: out std_logic_vector(7 downto 0);
	sgmii_clkp, sgmii_clkn: in std_logic;
	sgmii_txp, sgmii_txn: out std_logic;
	sgmii_rxp, sgmii_rxn: in std_logic;
	phy_rstb: out std_logic
	);
end top;

architecture rtl of top is

	signal clk125, clk200, ipb_clk, eth_locked, clk_locked, rst_125, rst_ipb, rst_eth, onehz: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal pkt_rx, pkt_tx, pkt_rx_led, pkt_tx_led, sys_rst: std_logic;	

begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_v6_serdes
		port map(
			sysclk_p => sysclk_p,
			sysclk_n => sysclk_n,
			clki_125 => clk125,
			sysclk_o => clk200,
			clko_ipb => ipb_clk,
			eth_locked => eth_locked,
			locked => clk_locked,
			nuke => sys_rst,
			rsto_125 => rst_125,
			rsto_ipb => rst_ipb,
			rsto_eth => rst_eth,
			onehz => onehz
		);
		
	leds <= "000" & eth_locked & pkt_rx_led & pkt_tx_led & clk_locked & onehz;
	
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
	
	phy_rstb <= '1';
	
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
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			pkt_rx => pkt_rx,
			pkt_tx => pkt_tx,
			pkt_rx_led => pkt_rx_led,
			pkt_tx_led => pkt_tx_led
		);
		
	mac_addr <= X"020ddba1159a"; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a80010"; -- 192.168.0.10

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		ipb_rst => rst_ipb,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
		rst_out => sys_rst,
		pkt_rx => pkt_rx,
		pkt_tx => pkt_tx
	);

end rtl;

