-- Contains the instantiation of the Xilinx MAC & 1000baseX pcs/pma & GTP transceiver cores
--
-- Do not change signal names in here without correspondig alteration to the timing contraints file
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.VComponents.all;
use work.emac_hostbus_decl.all;

entity eth_7s_1000basex is
	port(
		gt_clkp, gt_clkn: in std_logic;
		gt_txp, gt_txn: out std_logic;
		gt_rxp, gt_rxn: in std_logic;
		clk125_out: out std_logic;
		rsti: in std_logic;
		fr_clk: in std_logic;
		locked: out std_logic;
		tx_data: in std_logic_vector(7 downto 0);
		tx_valid: in std_logic;
		tx_last: in std_logic;
		tx_error: in std_logic;
		tx_ready: out std_logic;
		rx_data: out std_logic_vector(7 downto 0);
		rx_valid: out std_logic;
		rx_last: out std_logic;
		rx_error: out std_logic;
		hostbus_in: in emac_hostbus_in;
		hostbus_out: out emac_hostbus_out
	);

end eth_7s_1000basex;

architecture rtl of eth_7s_1000basex is

	signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0);
	signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic;
	signal gmii_rx_clk: std_logic;
	signal clkin, clk125, txoutclk_ub, txoutclk, clk125_ub: std_logic;
	signal clk62_5_ub, clk62_5, clkfb: std_logic;
	signal rstn, phy_done, mmcm_locked, locked_int, mmcm_reset, mmcm_reset_phy: std_logic;
	signal status: std_logic_vector(15 downto 0);

begin
	
	ibuf0: IBUFDS_GTE2 port map(
		i => gt_clkp,
		ib => gt_clkn,
		o => clkin,
		ceb => '0'
	);
	
	bufg_tx: BUFG port map(
		i => txoutclk_ub,
		o => txoutclk
	);
	
	mmcm_reset <= rsti or mmcm_reset_phy;
	
	mcmm: MMCME2_BASE
		generic map(
			CLKIN1_PERIOD => 16.0,
			CLKFBOUT_MULT_F => 16.0,
			CLKOUT1_DIVIDE => 16,
			CLKOUT2_DIVIDE => 8)
		port map(
			clkin1 => txoutclk,
			clkout1 => clk62_5_ub,
			clkout2 => clk125_ub,
			clkfbout => clkfb,
			clkfbin => clkfb,
			rst => mmcm_reset,
			pwrdwn => '0',
			locked => mmcm_locked);
	
	bufg_125: BUFG port map(
		i => clk125_ub,
		o => clk125);

	clk125_out <= clk125;

	bufg_62_5: BUFG port map(
		i => clk62_5_ub,
		o => clk62_5);

	process(fr_clk)
	begin
		if rising_edge(fr_clk) then
			locked_int <= mmcm_locked and phy_done;
		end if;
	end process;

	locked <= locked_int;
	rstn <= not (not locked_int or rsti);

	mac: entity work.emac_serdes_5_4 port map(
		glbl_rstn => rstn,
		rx_axi_rstn => '1',
		tx_axi_rstn => '1',
		rx_axi_clk => clk125,
		rx_reset_out => open,
		rx_axis_mac_tdata => rx_data,
		rx_axis_mac_tvalid => rx_valid,
		rx_axis_mac_tlast => rx_last,
		rx_axis_mac_tuser => rx_error,
		rx_statistics_vector => open,
		rx_statistics_valid => open,
		tx_axi_clk => clk125,
		tx_reset_out => open,
		tx_axis_mac_tdata => tx_data,
		tx_axis_mac_tvalid => tx_valid,
		tx_axis_mac_tlast => tx_last,
		tx_axis_mac_tuser => tx_error,
		tx_axis_mac_tready => tx_ready,
		tx_ifg_delay => X"00",
		tx_statistics_vector => open,
		tx_statistics_valid => open,
		pause_req => '0',
		pause_val => X"0000",
		speed_is_100 => open,
		speed_is_10_100 => open,
		gmii_txd => gmii_txd,
		gmii_tx_en => gmii_tx_en,
		gmii_tx_er => gmii_tx_er,
		gmii_rxd => gmii_rxd,
		gmii_rx_dv => gmii_rx_dv,
		gmii_rx_er => gmii_rx_er,
		rx_mac_config_vector => X"0000_0000_0000_0000_0802",
		tx_mac_config_vector => X"0000_0000_0000_0000_0002"
	);

	hostbus_out.hostrddata <= (others => '0');
	hostbus_out.hostmiimrdy <= '0';

	phy: entity work.gig_eth_pcs_pma_v11_4_block
		port map(
			gtrefclk => clkin,
			txp => gt_txp,
			txn => gt_txn,
			rxp => gt_rxp,
			rxn => gt_rxn,
			txoutclk => txoutclk_ub,
			resetdone => phy_done,
			userclk => clk62_5,
			userclk2 => clk125,
			independent_clock_bufg => fr_clk,
			pma_reset => rsti,
			mmcm_reset => mmcm_reset_phy,
			mmcm_locked => mmcm_locked,
			gmii_txd => gmii_txd,
			gmii_tx_en => gmii_tx_en,
			gmii_tx_er => gmii_tx_er,
			gmii_rxd => gmii_rxd,
			gmii_rx_dv => gmii_rx_dv,
			gmii_rx_er => gmii_rx_er,
			gmii_isolate => open,
			configuration_vector => "00000",
			status_vector => status,
			reset => rsti,
			signal_detect => '1'
		);

end rtl;

