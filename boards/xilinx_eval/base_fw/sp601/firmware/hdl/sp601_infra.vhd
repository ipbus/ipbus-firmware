-- sp601_infra
--
-- All board-specific stuff goes here.
--
-- Dave Newbold, June 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity sp601_infra is
	port(
		sysclk_p: in std_logic; -- 200MHz board crystal clock
		sysclk_n: in std_logic;
		clk_ipb_o: out std_logic; -- IPbus clock
		rst_ipb_o: out std_logic;
		clk_aux_o: out std_logic; -- 40MHz generated clock
		rst_aux_o: out std_logic;
		nuke: in std_logic; -- The signal of doom
		soft_rst: in std_logic; -- The signal of lesser doom
		leds: out std_logic_vector(1 downto 0); -- status LEDs
		gmii_gtx_clk: out std_logic; -- GMII interface to ethernet PHY
		gmii_txd: out std_logic_vector(7 downto 0);
		gmii_tx_en: out std_logic;
		gmii_tx_er: out std_logic;
		gmii_rx_clk: in std_logic;
		gmii_rxd: in std_logic_vector(7 downto 0);
		gmii_rx_dv: in std_logic;
		gmii_rx_er: in std_logic;
		mac_addr: in std_logic_vector(47 downto 0); -- MAC address
		ip_addr: in std_logic_vector(31 downto 0); -- IP address
		ipb_in: in ipb_rbus; -- ipbus
		ipb_out: out ipb_wbus
	);

end sp601_infra;

architecture rtl of sp601_infra is

	signal clk125, clk_ipb, clk_ipb_i, locked, rst125, rst_ipb, onehz, pkt: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal led_p: std_logic_vector(0 downto 0);
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_s6_extphy
		port map(
			sysclk_p => sysclk_p,
			sysclk_n => sysclk_n,
			clko_125 => clk125,
			clko_ipb => clk_ipb_i,
			locked => locked,
			nuke => nuke,
			soft_rst => soft_rst,
			rsto_125 => rst125,
			rsto_ipb => rst_ipb,
			onehz => onehz
		);

	clk_ipb <= clk_ipb_i; -- Best to align delta delays on all clocks for simulation
	clk_ipb_o <= clk_ipb_i;
	rst_ipb_o <= rst_ipb;

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
	
-- Ethernet MAC

	eth: entity work.eth_s6_gmii
		port map(
			clk125 => clk125,
			rst => rst125,
			gmii_gtx_clk => gmii_gtx_clk,
			gmii_txd => gmii_txd,
			gmii_tx_en => gmii_tx_en,
			gmii_tx_er => gmii_tx_er,
			gmii_rx_clk => gmii_rx_clk,
			gmii_rxd => gmii_rxd,
			gmii_rx_dv => gmii_rx_dv,
			gmii_rx_er => gmii_rx_er,
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
