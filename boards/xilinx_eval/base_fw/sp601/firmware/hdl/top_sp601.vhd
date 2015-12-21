-- Top-level design for ipbus demo
--
-- This version is for xc6slx16 on Xilinx SP601 eval board
-- Uses the s6 soft TEMAC core with GMII inteface to an external Gb PHY
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 23/2/11

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.ALL;

entity top is port(
		sysclk_p: in std_logic;
		sysclk_n: in std_logic;
		leds: out std_logic_vector(3 downto 0);
		gmii_gtx_clk, gmii_tx_en, gmii_tx_er: out std_logic;
		gmii_txd: out std_logic_vector(7 downto 0);
		gmii_rx_clk, gmii_rx_dv, gmii_rx_er: in std_logic;
		gmii_rxd: in std_logic_vector(7 downto 0);
		phy_rstb: out std_logic;
		dip_switch: in std_logic_vector(3 downto 0)
	);

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, nuke, soft_rst, userled: std_logic;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal ipb_out: ipb_wbus;
	signal ipb_in: ipb_rbus;
	
begin

-- Infrastructure

	infra: entity work.sp601_infra
		port map(
			sysclk_p => sysclk_p,
			sysclk_n => sysclk_n,
			clk_ipb_o => clk_ipb,
			rst_ipb_o => rst_ipb,
			nuke => nuke,
			soft_rst => soft_rst,
			leds => leds(1 downto 0),
			gmii_gtx_clk => gmii_gtx_clk,
			gmii_txd => gmii_txd,
			gmii_tx_en => gmii_tx_en,
			gmii_tx_er => gmii_tx_er,
			gmii_rx_clk => gmii_rx_clk,
			gmii_rxd => gmii_rxd,
			gmii_rx_dv => gmii_rx_dv,
			gmii_rx_er => gmii_rx_er,
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			ipb_in => ipb_in,
			ipb_out => ipb_out
		);
		
	leds(3 downto 2) <= '0' & userled;
	phy_rstb <= '1';
		
	mac_addr <= X"020ddba115e680"; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a8e680"; -- 192.168.230.128

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
			userled => userled
		);

end rtl;
