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

