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
		v6_cpld : in std_logic_vector(0 to 5)
	);

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, clkp, rstp, clk200: std_logic;
	signal ipb_in_ctrl, ipb_in_payload: ipb_wbus;
	signal ipb_out_ctrl, ipb_out_payload: ipb_rbus;

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
			nuke => '0',
			soft_rst => '0',
			userled => '0',
			scl => fpga_scl,
			sda => fpga_sda,
			ipb_in_ctrl => ipb_out_ctrl,
			ipb_out_ctrl => ipb_in_ctrl,
			ipb_in_payload => ipb_out_payload,
			ipb_out_payload => ipb_in_payload
		);
		
	ipb_out_ctrl <= IPB_RBUS_NULL;
	ipb_out_payload <= IPB_RBUS_NULL;

end rtl;

