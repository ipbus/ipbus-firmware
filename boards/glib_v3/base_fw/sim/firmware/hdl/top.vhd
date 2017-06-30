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

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, clkp, rstp: std_logic;
	signal ipb_in: ipb_wbus;
	signal ipb_out: ipb_rbus;
	signal nuke, soft_rst, userled: std_logic;

begin

	infra: entity work.glib_infra
		generic map(
			STATIC_MAC_ADDR => MAC_ADDR,
			STATIC_IP_ADDR => IP_ADDR
		)
		port map(
			clk_ipb => clk_ipb,
			rst_ipb => rst_ipb,
			clk_payload => clkp,
			nuke => nuke,
			soft_rst => soft_rst,
			userled => userled,
			ipb_in => ipb_out,
			ipb_out => ipb_in
		);

	payload: entity work.payload_sim
		port map(
			clk => clk_ipb,
			rst => rst_ipb,
			ipb_in => ipb_in,
			ipb_out => ipb_out,
			nuke => nuke,
			soft_rst => soft_rst,
			userled => userled,
			slot => "0000",
			clkp => clkp
		);

end rtl;

