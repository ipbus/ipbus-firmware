-- Top-level design for ipbus demo
--
-- Dave Newbold, 16/7/12
-- modified by Kristian Harder to make use of GLIB v3 infrastructure
-- functionality such as MAC/IP address EEPROM, ICAP interface, flash memory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.mac_arbiter_decl.all;

entity top is port(
	leds: out std_logic_vector(2 downto 0);
	gt_clkp, gt_clkn: in std_logic;
	gt_txp, gt_txn: out std_logic;
	gt_rxp, gt_rxn: in std_logic;
	sda, scl: inout std_logic;
	v6_cpld : inout std_logic_vector(0 to 5)
	);
end top;

architecture rtl of top is

	signal clk125, clk125_fr, ipb_clk, eth_locked, clk_locked, rst_125, rst_ipb, rst_eth, onehz: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal ipb_master_out : ipb_wbus; 
	signal ipb_master_in : ipb_rbus; 
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal RARP_select, eeprom_done: std_logic;
	signal pkt_rx_led, pkt_tx_led, sys_rst: std_logic;	
	signal amc_slot: std_logic_vector(3 downto 0);

begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_v6_serdes_noxtal
		port map(
			clki_125_fr => clk125_fr,
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
		
	leds <= eth_locked & clk_locked & onehz;
	amc_slot(3) <= v6_cpld(3);
	amc_slot(2) <= v6_cpld(2);
	amc_slot(1) <= v6_cpld(1);
	amc_slot(0) <= v6_cpld(0);

--	Ethernet MAC core and PHY interface
	
	eth: entity work.eth_v6_basex
		port map(
			gt_clkp => gt_clkp,
			gt_clkn => gt_clkn,
			gt_txp => gt_txp,
			gt_txn => gt_txn,
			gt_rxp => gt_rxp,
			gt_rxn => gt_rxn,		
			clk125_o => clk125,
			clk125_fr => clk125_fr,
			rst => rst_eth,
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
	

-- ipbus control logic for example design slaves

	ipbus: entity work.ipbus_ctrl
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
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			enable => eeprom_done,
			RARP_select => RARP_select,
			pkt_rx_led => pkt_rx_led, 
			pkt_tx_led => pkt_tx_led			
		);

	RARP_select <= '1' when (ip_addr = x"00000000") else '0';

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.
	
	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		ipb_rst => rst_ipb,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
		rst_out => sys_rst
	);


	eeprom: entity work.i2c_eeprom_read
		port map(
			clk => ipb_clk,
			reset => sys_rst,
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			scl_wr => scl,
			sda => sda,
			eeprom_done => eeprom_done
		);

	-- the following MAC address is constructed for RAL GLIBs in B904, 
	-- to give the proper assigned CERN MAC addresses to boards in slots 3,4,9,10            
	--mac_addr <= X"080030f1003" & (not amc_slot(3) xor (amc_slot(0) xor amc_slot(1))) & amc_slot(2 downto 0); 
	--ip_addr <= X"00000000"; -- 0.0.0.0 means use RARP 
	--eeprom_done <= '1';
	

end rtl;

