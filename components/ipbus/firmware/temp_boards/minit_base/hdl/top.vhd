-- Top-level design for ipbus demo
--
-- This version should work on the miniT-R2, all versions
-- Uses the v5 hard EMAC core with 1000basex interface
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, May 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.emac_hostbus_decl.all;

library unisim;
use unisim.VComponents.all;

entity top is port(
	osc_p, osc_n: in std_logic;
	leds: out std_logic_vector(3 downto 0);
	clk_cntrl: out std_logic_vector(23 downto 0);
	enet_clkp, enet_clkn: in std_logic;
	enet_txp, enet_txn: out std_logic;
	enet_rxp, enet_rxn: in std_logic;
	uc_spi_miso: out std_logic;
	uc_spi_mosi: in std_logic;
	uc_spi_sck: in std_logic;
	uc_spi_cs_b: in std_logic
	);
end top;

architecture rtl of top is

	signal clk125, clk100, ipb_clk, clk_locked, locked, eth_locked: std_logic;
	signal sysclk: std_logic;
	signal rst, rst_125, rst_ipb, onehz: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out: ipb_wbus;
	signal ipb_master_in: ipb_rbus;
	signal hostbus_in: emac_hostbus_in;
	signal hostbus_out: emac_hostbus_out;
	signal pkt_rx_led, pkt_tx_led: std_logic;
	
begin

--	DCM clock generation for internal bus, ethernet

	clkbuf: ibufds port map(
		i => osc_p,
		ib => osc_n,
		o => sysclk
	);

	clocks: entity work.clocks_v5_extphy port map(
		sysclk => sysclk,
		clko_125 => open,
		clko_ipb => ipb_clk,
		clko_200 => open,
		locked => locked,
		nuke => '0',
		rsto_125 => rst_125,
		rsto_ipb => rst_ipb,
		onehz => onehz
	);

	clk_cntrl <= X"004000";		
	leds(3 downto 0) <= (pkt_rx_led, pkt_tx_led, locked, onehz);
	
--	Ethernet MAC core and PHY interface
	
	eth: entity work.eth_v5_1000basex port map(
		basex_clkp => enet_clkp,
		basex_clkn => enet_clkn,
		basex_txp => enet_txp,
		basex_txn => enet_txn,
		basex_rxp => enet_rxp,
		basex_rxn => enet_rxn,
		locked => open,
		clk125_o => clk125,
		rst => rst_125,
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
			mac_addr => X"000a3501eaf1",
			ip_addr => X"c0a8c8e0",
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
