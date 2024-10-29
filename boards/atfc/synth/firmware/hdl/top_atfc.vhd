-- Top-level design for ipbus demo
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 08/01/16

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity top is port(
		eth_clk_p: in std_logic; -- 125MHz MGT clock
		eth_clk_n: in std_logic;
		eth_rx_p: in std_logic; -- Ethernet MGT input
		eth_rx_n: in std_logic;
		eth_tx_p: out std_logic; -- Ethernet MGT output
		eth_tx_n: out std_logic;
		sfp_los: in std_logic;
		sfp_tx_disable: out std_logic;
		leds: out std_logic_vector(7 downto 0); -- TE712 LEDs
		dip_sw: in std_logic_vector(3 downto 0) -- carrier switches
	);

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, nuke, soft_rst, userled: std_logic;
	signal ipb_out: ipb_wbus;
	signal ipb_in: ipb_rbus;
	signal infra_leds: std_logic_vector(1 downto 0);
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	
begin

-- Infrastructure

	infra: entity work.atfc_infra -- Should work for artix also...
		port map(
			eth_clk_p => eth_clk_p,
			eth_clk_n => eth_clk_n,
			eth_tx_p => eth_tx_p,
			eth_tx_n => eth_tx_n,
			eth_rx_p => eth_rx_p,
			eth_rx_n => eth_rx_n,
			sfp_los => sfp_los,
			clk_ipb_o => clk_ipb,
			rst_ipb_o => rst_ipb,
			clk125_o => open,
			rst125_o => open,
			clk200 => open,
			pllclk => open,
			pllrefclk => open,
			nuke => nuke,
			soft_rst => soft_rst,
			leds => infra_leds,
			debug => open,
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			ipb_in => ipb_in,
			ipb_out => ipb_out
		);
		
	leds <= userled & "11" & "11" & userled & infra_leds; -- Turning on green LED will lead to blindness
	sfp_tx_disable <= '0';
	
	mac_addr <= X"020ddba1158" & dip_sw; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a8eb8" & dip_sw; -- 192.168.200.16+n
	
	slaves: entity work.ipbus_example
		port map(
			ipb_clk => clk_ipb,
			ipb_rst => rst_ipb,
			ipb_in => ipb_out,
			ipb_out => ipb_in,
			nuke => nuke,
			soft_rst => soft_rst,
			userled => userled
		);

end rtl;
