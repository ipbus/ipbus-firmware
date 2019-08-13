---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


-- enclustra_ax3_pm3_infra
--
-- All board-specific stuff goes here
--
-- Dave Newbold, June 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity enclustra_ax3_pm3_infra is
	generic (
		CLK_AUX_FREQ: real := 40.0 -- Default: 40 MHz clock - LHC
		);
	port(
		osc_clk: in std_logic; -- 50MHz board crystal clock
		clk_ipb_o: out std_logic; -- IPbus clock
		rst_ipb_o: out std_logic;
		clk125_o: out std_logic;
		rst125_o: out std_logic;
		clk_aux_o: out std_logic; -- 50MHz clock
		rst_aux_o: out std_logic;
		nuke: in std_logic; -- The signal of doom
		soft_rst: in std_logic; -- The signal of lesser doom
		leds: out std_logic_vector(1 downto 0); -- status LEDs
		rgmii_txd: out std_logic_vector(3 downto 0);
		rgmii_tx_ctl: out std_logic;
		rgmii_txc: out std_logic;
		rgmii_rxd: in std_logic_vector(3 downto 0);
		rgmii_rx_ctl: in std_logic;
		rgmii_rxc: in std_logic;
		mac_addr: in std_logic_vector(47 downto 0); -- MAC address
		ip_addr: in std_logic_vector(31 downto 0); -- IP address
		ipb_in: in ipb_rbus; -- ipbus
		ipb_out: out ipb_wbus
	);

end enclustra_ax3_pm3_infra;

architecture rtl of enclustra_ax3_pm3_infra is

	signal clk125_fr, clk125, clk125_90, clk200, clk_aux, clk_ipb, clk_ipb_i, locked, rst125, rst_aux, rst_ipb, rst_ipb_ctrl, rst_eth, onehz, pkt: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal led_p: std_logic_vector(0 downto 0);
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_7s_extphy_se
		generic map(
			CLK_AUX_FREQ => CLK_AUX_FREQ
			)
		port map(
			sysclk => osc_clk,
			clko_125 => clk125,
			clko_125_90 => clk125_90,
			clko_200 => clk200,
			clko_aux => clk_aux,
			clko_ipb => clk_ipb_i,
			locked => locked,
			nuke => nuke,
			soft_rst => soft_rst,
			rsto_125 => rst125,
			rsto_aux => rst_aux,
			rsto_ipb => rst_ipb,
			rsto_ipb_ctrl => rst_ipb_ctrl,
			onehz => onehz
		);

	clk_ipb <= clk_ipb_i; -- Best to align delta delays on all clocks for simulation
	clk_ipb_o <= clk_ipb_i;
	rst_ipb_o <= rst_ipb;
	clk125_o <= clk125;	
	rst125_o <= rst125;
	clk_aux_o <= clk_aux;	
	rst_aux_o <= rst_aux;

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
	
-- Ethernet MAC core and PHY interface
	
	eth: entity work.eth_7s_rgmii
		port map(
			clk125 => clk125,
			clk125_90 => clk125_90,
			clk200 => clk200,
			rst => rst125,
			rgmii_txd => rgmii_txd,
			rgmii_tx_ctl => rgmii_tx_ctl,
			rgmii_txc => rgmii_txc,
			rgmii_rxd => rgmii_rxd,
			rgmii_rx_ctl => rgmii_rx_ctl,
			rgmii_rxc => rgmii_rxc,
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
