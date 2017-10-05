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
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 08/01/16

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;
use work.top_decl.all;

entity top is

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, nuke, soft_rst, userled, clk200: std_logic;
	signal ipb_out: ipb_wbus;
	signal ipb_in: ipb_rbus;
	
begin

-- Infrastructure

	infra: entity work.pc051a_infra_sim -- Should work for artix also...
		port map(
			clk_ipb_o => clk_ipb,
			rst_ipb_o => rst_ipb,
			nuke => nuke,
			soft_rst => soft_rst,
			mac_addr => MAC_ADDR,
			ip_addr => IP_ADDR,
			ipb_in => ipb_in,
			ipb_out => ipb_out
		);

	payload: entity work.payload_sim
		port map(
			ipb_clk => clk_ipb,
			ipb_rst => rst_ipb,
			ipb_in => ipb_out,
			ipb_out => ipb_in,
			nuke => nuke,
			soft_rst => soft_rst
		);

end rtl;
