-- Top-level design for ipbus demo
--
-- Dave Newbold, July 2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;
use work.ipbus_decode_minit5_240.all;

entity top is port(
		sysclk_p, sysclk_n: in std_logic;
		gt_clkp, gt_clkn: in std_logic;
		gt_txp, gt_txn: out std_logic;
		gt_rxp, gt_rxn: in std_logic;
		leds: out std_logic_vector(3 downto 0);
		clk_cntrl: out std_logic_vector(23 downto 0)
	);
end top;

architecture rtl of top is

	signal clk125, clk125_fr, clk100, ipb_clk, clk_locked, locked, eth_locked: std_logic;
	signal rst_125, rst_ipb, rst_eth, onehz: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out: ipb_wbus;
	signal ipb_master_in: ipb_rbus;
	signal ipbw: ipb_wbus_array(N_SLAVES-1 downto 0);
	signal ipbr: ipb_rbus_array(N_SLAVES-1 downto 0);
	signal pkt_rx_led, pkt_tx_led, sys_rst: std_logic;
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_v5_serdes port map(
		sysclk_p => sysclk_p,
		sysclk_n => sysclk_n,
		clki_125 => clk125,
		clko_ipb => ipb_clk,
		eth_locked => eth_locked,
		locked => clk_locked,
		nuke => sys_rst,
		rsto_125 => rst_125,
		rsto_ipb => rst_ipb,
		rsto_eth => rst_eth,
		onehz => onehz
		);
		
	clk_cntrl <= X"004000";
		
	locked <= clk_locked and eth_locked;
	leds <= pkt_rx_led & pkt_tx_led & locked & onehz;
	
--	Ethernet MAC core and PHY interface
	
	eth: entity work.eth_v5_1000basex port map(
		gt_clkp => gt_clkp,
		gt_clkn => gt_clkn,
		gt_txp => gt_txp,
		gt_txn => gt_txn,
		gt_rxp => gt_rxp,
		gt_rxn => gt_rxn,
		clk125_o => clk125,
		rsti => rst_eth,
		locked => eth_locked,
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
	
-- ipbus control logic

	ipbus: entity work.ipbus_ctrl
                generic map(
                  -- MAC and IP address controlled via config space
                  MAC_CFG => EXTERNAL,
                  IP_CFG => EXTERNAL
                )
		port map(
			mac_clk => clk125,
			rst_macclk => rst_125,
			ipb_clk => ipb_clk,
			rst_ipb => rst_ipb,
			mac_rx_data => mac_rx_data,
			mac_rx_valid => mac_rx_valid,
			mac_rx_last => mac_rx_last,
			mac_rx_error => mac_rx_error,
			mac_tx_data => mac_tx_data,
			mac_tx_valid => mac_tx_valid,
			mac_tx_last => mac_tx_last,
			mac_tx_error => mac_tx_error,
			mac_tx_ready => mac_tx_ready,
			ipb_out => ipb_master_out,
			ipb_in => ipb_master_in,
			RARP_select => '1',
			mac_addr => X"08002bf10031",
			ip_addr => X"00000000",
			pkt_rx_led => pkt_rx_led,
			pkt_tx_led => pkt_tx_led
		);

		ipbus_fabric_sel: entity work.ipbus_fabric_sel
                generic map (
                  NSLV => N_SLAVES,
                  SEL_WIDTH => IPBUS_SEL_WIDTH
                )
                port map(
                  ipb_in => ipb_master_out,
                  ipb_out => ipb_master_in,      
                  sel => ipbus_sel_minit5_240(ipb_master_out.ipb_addr),
                  ipb_to_slaves => ipbw,
                  ipb_from_slaves => ipbr
                );


-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	ipbus_example: entity work.ipbus_example port map(
		ipb_clk => ipb_clk,
		ipb_rst => rst_ipb,
		ipb_in => ipbw(N_SLV_EXAMPLE),
		ipb_out => ipbr(N_SLV_EXAMPLE),
		rst_out => sys_rst
	);

end rtl;

