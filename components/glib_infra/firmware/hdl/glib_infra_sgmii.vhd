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
use work.ipbus_trans_decl.all;

entity glib_infra is
	generic(
		MAC_FROM_PROM: boolean := false;
		IP_FROM_PROM: boolean := false;
		STATIC_MAC_ADDR: std_logic_vector(47 downto 0) := X"000000000000";
		STATIC_IP_ADDR: std_logic_vector(31 downto 0) := X"00000000"
	);
	port(
		gt_clkp: in std_logic; -- ethernet serdes clock
		gt_clkn: in std_logic;
		leds: out std_logic_vector(2 downto 0); -- status LEDs
		clk_ipb: out std_logic; -- ipbus clock (nominally ~30MHz) & reset
		rst_ipb: out std_logic;
		clk_payload: out std_logic; -- clock for running payload without external clock source
		clk_fr: out std_logic; -- 125MHz free-running clock & reset (for reset state machines)
		rst_fr: out std_logic;
		clk200: out std_logic;
		phy_rstb: out std_logic;
		nuke: in std_logic; -- The signal of doom
		soft_rst: in std_logic; -- The signal of lesser doom
		reconf: in std_logic; -- The signal of ultimate doom
		userled: in std_logic;
		scl: inout std_logic;
		sda: inout std_logic;
		ipb_in: in ipb_rbus;
		ipb_out: out ipb_wbus
	);

end glib_infra;

architecture rtl of glib_infra is

	signal clk125_fr, clk125, ipb_clk, clk_locked, locked, eth_locked, ipb_clk_n: std_logic;
	signal rsti_125, rsti_ipb, rsti_eth, rsti_ipb_ctrl, onehz, rsti_fr: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal pkt: std_logic;
	signal mac_addr, mac_addr_prom: std_logic_vector(47 downto 0);
	signal ip_addr, ip_addr_prom: std_logic_vector(31 downto 0);
	signal rarp_select, prom_done: std_logic;
	
	attribute KEEP: string;	
	attribute KEEP of clk125_fr: signal is "TRUE";	

begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_v6_serdes_noxtal
		port map(
			clki_125_fr => clk125_fr,
			clki_125 => clk125,
			clko_ipb => ipb_clk,
			clko_62_5 => clk_payload,
			clko_200 => clk200,
			eth_locked => eth_locked,
			locked => clk_locked,
			nuke => nuke,
			soft_rst => soft_rst,
			rsto_125 => rsti_125,
			rsto_ipb => rsti_ipb,
			rsto_ipb_ctrl => rsti_ipb_ctrl,
			rsto_eth => rsti_eth,
			rsto_fr => rsti_fr,
			onehz => onehz
		);
		
	locked <= clk_locked and eth_locked;
	
-- The Most Important Part: flashing lights
--
-- led(0) is good clock indicator
-- led(1) is packet indicator
-- led(2) is user-driven
	
	stretch: entity work.led_stretcher
		generic map(
			WIDTH => 2
		)
		port map(
			clk => clk125,
			d(0) => pkt,
			d(1) => userled,
			q(0) => leds(1),
			q(1) => leds(2)
		);

	leds(0) <= locked and onehz and prom_done;
	
-- Clocks for rest of logic

	clk_ipb <= ipb_clk;
	rst_ipb <= rsti_ipb;
	clk_fr <= clk125_fr;
	rst_fr <= rsti_fr;
	phy_rstb <= not rsti_eth;

-- Ethernet MAC core and PHY interface
	
	eth: entity work.eth_v6_sgmii
		port map(
			sgmii_clkp => gt_clkp,
			sgmii_clkn => gt_clkn,
			sgmii_txp => open,
			sgmii_txn => open,
			sgmii_rxp => '0', -- No need to wire up MGT pins to top level
			sgmii_rxn => '1',		
			clk125_o => clk125,
			clk125_fr => clk125_fr,
			rst => rsti_eth,
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

-- Network address

	prom: entity work.i2c_eeprom_read
		port map(
			clk => ipb_clk,
			reset => rsti_ipb_ctrl,
			mac_addr => mac_addr_prom,
			ip_addr => ip_addr_prom,
			scl_wr => scl,
			sda => sda,
			eeprom_done => prom_done
		);
		
	mac_addr <= mac_addr_prom when MAC_FROM_PROM else STATIC_MAC_ADDR;
	ip_addr <= ip_addr_prom when IP_FROM_PROM else STATIC_IP_ADDR;
	rarp_select <= '1' when (ip_addr = X"00000000") else '0';

-- ICAP interface

	ipb_clk_n <= not ipb_clk;

	icap: entity work.icap_interface_wrapper
		port map(
			reset_i => rsti_ipb,
			conf_trigg_i => reconf,
			fsm_conf_page_i => "00",
			ipbus_clk_i => ipb_clk,
			ipbus_inv_clk_i => ipb_clk_n,
			ipbus_i => IPB_WBUS_NULL, -- no ipbus connection for now
			ipbus_o => open
		);

-- ipbus control logic

	ipbus: entity work.ipbus_ctrl
		generic map(
			MAC_CFG => EXTERNAL,
			IP_CFG => EXTERNAL
		)
		port map(
			mac_clk => clk125,
			rst_macclk => rsti_125,
			ipb_clk => ipb_clk,
			rst_ipb => rsti_ipb_ctrl,
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
			enable => prom_done,
			rarp_select => rarp_select,
			pkt => pkt
		);

end rtl;

