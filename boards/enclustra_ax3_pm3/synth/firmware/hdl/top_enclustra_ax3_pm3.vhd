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


-- Top-level design for ipbus demo
--
-- This version is for Enclustra AX3 module, using the RGMII PHY on the PM3 baseboard
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 4/10/16

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.ALL;

entity top is port(
		osc_clk: in std_logic;
		leds: out std_logic_vector(3 downto 0); -- status LEDs
		cfg: in std_logic_vector(3 downto 0); -- switches
		rgmii_txd: out std_logic_vector(3 downto 0);
		rgmii_tx_ctl: out std_logic;
		rgmii_txc: out std_logic;
		rgmii_rxd: in std_logic_vector(3 downto 0);
		rgmii_rx_ctl: in std_logic;
		rgmii_rxc: in std_logic;
		phy_rstn: out std_logic
	);

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, clk_aux, rst_aux, nuke, soft_rst, phy_rst_e, userled: std_logic;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal ipb_out: ipb_wbus;
	signal ipb_in: ipb_rbus;
	signal inf_leds: std_logic_vector(1 downto 0);
	
begin

-- Infrastructure

	infra: entity work.enclustra_ax3_pm3_infra
		port map(
			osc_clk => osc_clk,
			clk_ipb_o => clk_ipb,
			rst_ipb_o => rst_ipb,
			rst125_o => phy_rst_e,
			clk_aux_o => clk_aux,
			rst_aux_o => rst_aux,
			nuke => nuke,
			soft_rst => soft_rst,
			leds => inf_leds,
			rgmii_txd => rgmii_txd,
			rgmii_tx_ctl => rgmii_tx_ctl,
			rgmii_txc => rgmii_txc,
			rgmii_rxd => rgmii_rxd,
			rgmii_rx_ctl => rgmii_rx_ctl,
			rgmii_rxc => rgmii_rxc,
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			ipb_in => ipb_in,
			ipb_out => ipb_out
		);
		
	leds <= not ('0' & userled & inf_leds);
	phy_rstn <= not phy_rst_e;
		
	mac_addr <= X"020ddba1151" & not cfg; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a8c81" & not cfg; -- 192.168.200.16+n

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	payload: entity work.payload
		port map(
			ipb_clk => clk_ipb,
			ipb_rst => rst_ipb,
			ipb_in => ipb_out,
			ipb_out => ipb_in,
			clk => clk_aux,
			rst => rst_aux,
			nuke => nuke,
			soft_rst => soft_rst,
			userled => userled
		);

end rtl;
