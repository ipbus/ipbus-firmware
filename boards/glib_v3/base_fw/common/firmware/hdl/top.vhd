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
		v6_cpld: in std_logic_vector(5 downto 0)
	);

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, clkp, rstp, clk200: std_logic;
	signal ipb_in_payload: ipb_wbus;
	signal ipb_out_payload: ipb_rbus;
	signal nuke, soft_rst, userled: std_logic;

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
			userled => userled,
			scl => fpga_scl,
			sda => fpga_sda,
			ipb_in_payload => ipb_out_payload,
			ipb_out_payload => ipb_in_payload
		);

	payload: entity work.payload
		port map(
			clk => clk_ipb,
			rst => rst_ipb,
			ipb_in => ipb_in_payload,
			ipb_out => ipb_out_payload,
			nuke => nuke,
			soft_rst => soft_rst,
			userled => userled,
			slot => v6_cpld(3 downto 0),
			clkp => clkp,
			clk200 => clk200
		);

end rtl;

