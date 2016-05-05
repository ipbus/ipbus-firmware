-- Top-level design for ipbus demo
--
-- This version is for simulation purposes
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 23/2/11

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.ALL;

entity top is

-- Stand-alone design

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, nuke, soft_rst: std_logic;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal ipb_out: ipb_wbus;
	signal ipb_in: ipb_rbus;
	
begin

-- Infrastructure

	infra: entity work.sim_infra
		port map(
			clk_ipb_o => clk_ipb,
			rst_ipb_o => rst_ipb,
			nuke => nuke,
			soft_rst => soft_rst,
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			ipb_in => ipb_in,
			ipb_out => ipb_out
		);
		
	mac_addr <= X"020ddba1e780"; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a8e780"; -- 192.168.231.128

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.ipbus_example
		port map(
			ipb_clk => clk_ipb,
			ipb_rst => rst_ipb,
			ipb_in => ipb_out,
			ipb_out => ipb_in,
			nuke => nuke,
			soft_rst => soft_rst,
			userled => open
		);

end rtl;
