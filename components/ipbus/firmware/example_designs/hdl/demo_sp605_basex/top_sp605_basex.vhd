-- Top-level design for ipbus demo
--
-- This version is for xc6slx45t on SP605 eval board
-- Uses the s6 soft TEMAC core with baseX inteface to an SFP
-- You will need a license for the core
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 17/7/12

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.emac_hostbus_decl.all;

entity top is port(
		sysclk_p, sysclk_n: in STD_LOGIC;
		gtp_clkp, gtp_clkn: in std_logic;
		gtp_txp, gtp_txn: out std_logic;
		gtp_rxp, gtp_rxn: in std_logic;
		sfp_los: in std_logic;
		leds: out STD_LOGIC_VECTOR(3 downto 0);
		dip_switch: in std_logic_vector(3 downto 0);
		sdram_a: out std_logic_vector(12 downto 0);
		sdram_ba: out std_logic_vector(2 downto 0);
		sdram_cas_n: out std_logic;
		sdram_ck, sdram_ck_n: out std_logic;
		sdram_cke: out std_logic;
		sdram_dm: out std_logic;
		sdram_odt: out std_logic;
		sdram_ras_n: out std_logic;
		sdram_reset_n: out std_logic;
		sdram_udm: out std_logic;
		sdram_we_n: out std_logic;
		sdram_dq: inout std_logic_vector(15 downto 0);
		sdram_dqs, sdram_dqs_n: inout std_logic;
		sdram_udqs, sdram_udqs_n: inout std_logic;
		sdram_rzq: inout std_logic;
		sdram_zio: inout std_logic
	);
end top;

architecture rtl of top is

	signal sys_clk, clk125, ipb_clk, locked, rst_125, rst_ipb, onehz : STD_LOGIC;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal hostbus_in: emac_hostbus_in;
	signal hostbus_out: emac_hostbus_out;
	signal pkt_rx_led, pkt_tx_led: std_logic;
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_s6_basex port map(
		sysclk_p => sysclk_p,
		sysclk_n => sysclk_n,		
		clki_125 => clk125,
		clko_ipb => ipb_clk,
		sysclko => sys_clk,
		locked => locked,
		nuke => '0',
		rsto_125 => rst_125,
		rsto_ipb => rst_ipb,
		onehz => onehz
	);
		
	leds <= (pkt_rx_led, pkt_tx_led, locked, onehz);
	
--	Ethernet MAC core and PHY interface
	
	eth: entity work.eth_s6_1000basex port map(
		gtp_clkp => gtp_clkp,
		gtp_clkn => gtp_clkn,
		gtp_txp => gtp_txp,
		gtp_txn => gtp_txn,
		gtp_rxp => gtp_rxp,
		gtp_rxn => gtp_rxn,
		clk125_out => clk125,
		rst => rst_125,
		locked => locked,
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
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			pkt_rx_led => pkt_rx_led,
			pkt_tx_led => pkt_tx_led
		);
		
	mac_addr <= X"020ddba115" & dip_switch & X"0"; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a8c8" & dip_switch & X"0"; -- 192.168.200.X

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		ipb_rst => rst_ipb,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
		hostbus_out => hostbus_in,
		hostbus_in => hostbus_out
	);

end rtl;
