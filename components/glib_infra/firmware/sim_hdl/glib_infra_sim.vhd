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


-- glib_infra
--
-- Wrapper for ethernet, ipbus, and associated clock / system reset
--
-- All clocks are derived from 125MHz xtal clock for ethernet serdes
--
-- Dave Newbold, September 2014

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity glib_infra is
	generic(
		STATIC_MAC_ADDR: std_logic_vector(47 downto 0) := X"000000000000";
		STATIC_IP_ADDR: std_logic_vector(31 downto 0) := X"00000000"
	);
	port(
		clk_ipb: out std_logic; -- ipbus clock (nominally ~30MHz) & reset
		rst_ipb: out std_logic;
		clk_payload: out std_logic; -- clock for running payload without external clock source
		clk_fr: out std_logic; -- 125MHz free-running clock & reset (for reset state machines)
		rst_fr: out std_logic;
		nuke: in std_logic; -- The signal of doom
		soft_rst: in std_logic; -- The signal of lesser doom
		userled: in std_logic;
		ipb_in: in ipb_rbus;
		ipb_out: out ipb_wbus
	);

end glib_infra;

architecture rtl of glib_infra is

	signal clk125_fr, clk125, ipb_clk: std_logic;
	signal rst, rst_ctrl: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal pkt: std_logic;
	signal mac_addr, mac_addr_prom: std_logic_vector(47 downto 0);
	signal ip_addr, ip_addr_prom: std_logic_vector(31 downto 0);
	signal rarp_select, prom_done: std_logic;
	
	attribute KEEP: string;	
	attribute KEEP of clk125_fr: signal is "TRUE";

begin

-- Clock generation for ipbus, ethernet, POR

	clocks: entity work.clock_sim
		port map(
			clko125 => clk125,
			clko25 => ipb_clk,
			clko62_5 => clk_payload,
			nuke => nuke,
			soft_rst => soft_rst,
			rsto => rst,
			rsto_ctrl => rst_ctrl
		);

-- Clocks for rest of logic

	clk_ipb <= ipb_clk;
	rst_ipb <= rst;
	clk_fr <= clk125;
	rst_fr <= rst;

--	Ethernet MAC core and PHY interface

	eth: entity work.eth_mac_sim
		generic map(
			MULTI_PACKET => true
		)
		port map(
			clk => clk125,
			rst => rst_ctrl,
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
		generic map(
			MAC_CFG => EXTERNAL,
			IP_CFG => EXTERNAL
		)
		port map(
			mac_clk => clk125,
			rst_macclk => rst_ctrl,
			ipb_clk => ipb_clk,
			rst_ipb => rst_ctrl,
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
			mac_addr => STATIC_MAC_ADDR,
			ip_addr => STATIC_IP_ADDR
		);

end rtl;

