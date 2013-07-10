-- Top-level design for ipbus demo
--
-- This version is for xc5vfx30t on Avnet V5FXT demo board
-- Uses the v5 hard ethernet MAC with GMII inteface to an external Gb PHY
--
-- If you want to do performance testing, you can configure this design to
-- have up to 16 seperate IPbus controllers sharing the same MAC block.
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 23/2/11

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus.ALL;
use work.mac_arbiter_decl.all;

entity top is port(
	sys_clk_pin : in STD_LOGIC;
	leds: out STD_LOGIC_VECTOR(3 downto 0);
	gmii_tx_clk, gmii_tx_en, gmii_tx_er : out STD_LOGIC;
	gmii_txd : out STD_LOGIC_VECTOR(7 downto 0);
	gmii_rx_clk, gmii_rx_dv, gmii_rx_er: in STD_LOGIC;
	gmii_rxd : in STD_LOGIC_VECTOR(7 downto 0);
	phy_rstb : out STD_LOGIC;
	dip_switch: in std_logic_vector(3 downto 0)
	);

end top;

architecture rtl of top is

	constant N_IPB: integer := 8;
	signal clk125, clk200, ipb_clk, locked, rst_125, rst_ipb, onehz: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal mac_tx_data_bus: mac_arbiter_slv_array(N_IPB-1 downto 0);
	signal mac_tx_valid_bus, mac_tx_last_bus, mac_tx_error_bus, mac_tx_ready_bus: mac_arbiter_sl_array(N_IPB-1 downto 0);
	signal pkt_rx_bus, pkt_tx_bus, pkt_rx_led_bus, pkt_tx_led_bus: mac_arbiter_sl_array(N_IPB-1 downto 0);
	signal sys_rst_array: std_logic_vector(N_IPB-1 downto 0);
	signal pkt_rx_led, pkt_tx_led: std_logic;
	
begin

-- DCM clock generation for internal bus, ethernet, IO delay logic
-- Input clock 100MHz

	clocks: entity work.clocks_v5_extphy port map(
		sysclk => sys_clk_pin,
		clko_125 => clk125,
		clko_200 => clk200,
		clko_ipb => ipb_clk,
		locked => locked,
		nuke => sys_rst_array(0),
		rsto_125 => rst_125,
		rsto_ipb => rst_ipb,
		onehz => onehz
		);
		
	leds <= (pkt_rx_led, pkt_tx_led, locked, onehz);
	pkt_rx_led <= '0' when pkt_rx_led_bus = (pkt_rx_led_bus'range => '0') else '1';
	pkt_tx_led <= '0' when pkt_tx_led_bus = (pkt_tx_led_bus'range => '0') else '1';

	
-- Ethernet MAC core and PHY interface
-- In this version, consists of hard MAC core and GMII interface to external PHY
-- Can be replaced by any other MAC / PHY combination
	
	eth: entity work.eth_v5_gmii port map(
		clk125 => clk125,
		clk200 => clk200,
		rst => rst_125,
		locked => locked,
		gmii_tx_clk => gmii_tx_clk,
		gmii_tx_en => gmii_tx_en,
		gmii_tx_er => gmii_tx_er,
		gmii_txd => gmii_txd,
		gmii_rx_clk => gmii_rx_clk,
		gmii_rx_dv => gmii_rx_dv,
		gmii_rx_er => gmii_rx_er,
		gmii_rxd => gmii_rxd,
		tx_data => mac_tx_data,
		tx_valid => mac_tx_valid,
		tx_last => mac_tx_last,
		tx_error => mac_tx_error,
		tx_ready => mac_tx_ready,
		rx_data => mac_rx_data,
		rx_valid => mac_rx_valid,
		rx_last => mac_rx_last,
		rx_error => mac_rx_error
	);
	
	phy_rstb <= '1';
	
	arb: entity work.mac_arbiter
		generic map(
			NSRC => N_IPB
		)
		port map(
			clk => clk125,
			rst => rst_125,
			src_tx_data_bus => mac_tx_data_bus,
			src_tx_valid_bus => mac_tx_valid_bus,
			src_tx_last_bus => mac_tx_last_bus,
			src_tx_error_bus => mac_tx_error_bus,
			src_tx_ready_bus => mac_tx_ready_bus,
			mac_tx_data => mac_tx_data,
			mac_tx_valid => mac_tx_valid,
			mac_tx_last => mac_tx_last,
			mac_tx_error => mac_tx_error,
			mac_tx_ready => mac_tx_ready
		);
	
	ipbus_gen: for i in N_IPB-1 downto 0 generate

		signal ipb_master_out: ipb_wbus;
		signal ipb_master_in: ipb_rbus;
		signal mac_addr: std_logic_vector(47 downto 0);
		signal ip_addr: std_logic_vector(31 downto 0);

	begin
    
		ipbus: entity work.ipbus_ctrl
			port map(
				ipb_clk => ipb_clk,
				rst_ipb => rst_ipb,
				rst_macclk => rst_125,
				mac_clk => clk125,
				mac_rx_data => mac_rx_data,
				mac_rx_valid => mac_rx_valid,
				mac_rx_last => mac_rx_last,
				mac_rx_error => mac_rx_error,
				mac_tx_data => mac_tx_data_bus(i),
				mac_tx_valid => mac_tx_valid_bus(i),
				mac_tx_last => mac_tx_last_bus(i),
				mac_tx_error => mac_tx_error_bus(i),
				mac_tx_ready => mac_tx_ready_bus(i),
				ipb_out => ipb_master_out,
				ipb_in => ipb_master_in,
				mac_addr => mac_addr,
				ip_addr => ip_addr,
				pkt_rx => pkt_rx_bus(i),
				pkt_tx => pkt_tx_bus(i),
				pkt_rx_led => pkt_rx_led_bus(i),
				pkt_tx_led => pkt_tx_led_bus(i)
			);
		
		mac_addr <= X"020ddba115" & dip_switch & std_logic_vector(to_unsigned(i, 4));
		ip_addr <= X"c0a8c8" & dip_switch & std_logic_vector(to_unsigned(i, 4));
		
		slaves: entity work.slaves port map(
			ipb_clk => ipb_clk,
			ipb_rst => rst_ipb,
			ipb_in => ipb_master_out,
			ipb_out => ipb_master_in,
			rst_out => sys_rst_array(i),
			pkt_rx => pkt_rx_bus(i),
			pkt_tx => pkt_tx_bus(i)
		);
	 
	end generate;-- ipbus control logic

end rtl;

