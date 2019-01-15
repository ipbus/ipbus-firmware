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
-- Dave Newbold, 16/7/12

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;
use work.top_decl.all;

entity top is
	port(
		leds: out std_logic_vector(2 downto 0);
		eth_clkp: in std_logic;
		eth_clkn: in std_logic;
		phy_rstb: out std_logic;
		fpga_sda: inout std_logic;
		fpga_scl: inout std_logic;
		v6_cpld: inout std_logic_vector(5 downto 0);
		clk_in_p: in std_logic;
		clk_in_n: in std_logic;
		xpoint_ctrl: out std_logic_vector(9 downto 0);
		d_p: in std_logic_vector(N_IN - 1 downto 0);
		d_n: in std_logic_vector(N_IN - 1 downto 0);
		q_p: out std_logic_vector(N_OUT - 1 downto 0);
		q_n: out std_logic_vector(N_OUT - 1 downto 0)
	);

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, clkp, rstp, clk200: std_logic;
	signal ipb_in: ipb_wbus;
	signal ipb_out: ipb_rbus;
	signal prog, nuke, soft_rst, userled, reconf: std_logic;

begin

	infra: entity work.glib_infra
		generic map(
			MAC_FROM_PROM => MAC_FROM_PROM,
			IP_FROM_PROM => IP_FROM_PROM,
			STATIC_MAC_ADDR => MAC_ADDR,
			STATIC_IP_ADDR => IP_ADDR
		)
		port map(
			gt_clkp => eth_clkp,
			gt_clkn => eth_clkn,
			leds => leds,
			clk_ipb => clk_ipb,
			rst_ipb => rst_ipb,
			clk_payload => clkp,
			clk200 => clk200,
			phy_rstb => phy_rstb,
			nuke => nuke,
			soft_rst => soft_rst,
			reconf => reconf,
			userled => userled,
			scl => fpga_scl,
			sda => fpga_sda,
			ipb_in => ipb_out,
			ipb_out => ipb_in
		);

	payload: entity work.payload
		port map(
			clk => clk_ipb,
			rst => rst_ipb,
			ipb_in => ipb_in,
			ipb_out => ipb_out,
			nuke => nuke,
			soft_rst => soft_rst,
			reconf => reconf,
			userled => userled,
			slot => v6_cpld(3 downto 0),
			clkp => clkp,
			clk200 => clk200,
			clk_in_p => clk_in_p,
			clk_in_n => clk_in_n,
			d_p => d_p,
			d_n => d_n,
			q_p => q_p,
			q_n => q_n
		);

	xpoint_ctrl <= "0000000000";
	v6_cpld <= "1ZZZZZ";
		
end rtl;

