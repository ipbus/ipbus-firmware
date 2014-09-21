-- Top-level design for ipbus demo
--
-- Dave Newbold, 16/7/12

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.ALL;

entity top is
	port(
		leds: out std_logic_vector(2 downto 0);
		eth_clkp: in std_logic;
		eth_clkn: in std_logic;
		phy_rstb: out std_logic;
		sda: inout std_logic;
		scl: inout std_logic
	);

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, clkp, rstp, clk200: std_logic;
	signal ipb_in_ctrl, ipb_in_payload: ipb_wbus;
	signal ipb_out_ctrl, ipb_out_payload: ipb_rbus;

begin

	infra: entity work.glib_infra
		generic map(
			ETH_BP => false,
			MAC_FROM_PROM => false,
			IP_FROM_PROM => false,
			STATIC_MAC_ADDR => X"020ddba1159a",
			STATIC_IP_ADDR => X"c0a80010"
		)
		port map(
			gt_clkp => eth_clkp,
			gt_clkn => eth_clkn,
			leds => leds,
			clk_ipb => clk_ipb,
			rst_ipb => rst_ipb,
			clk_payload => clkp,
			clk200 => clk200,
			nuke => '0',
			soft_rst => '0',
			userled => '0',
			scl => scl,
			sda => sda,
			ipb_in_ctrl => ipb_out_ctrl,
			ipb_out_ctrl => ipb_in_ctrl,
			ipb_in_payload => ipb_out_payload,
			ipb_out_payload => ipb_in_payload
		);
	
	ipb_out_ctrl <= IPB_RBUS_NULL;
	ipb_out_payload <= IPB_RBUS_NULL;

end rtl;

