-- Contains the instantiation of the Xilinx MAC & 1000baseX pcs/pma & GTP transceiver cores
--
-- Do not change signal names in here without corresponding alteration to the timing contraints file
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
	Generic (
		constant POLARITY_SWAP: std_logic := '0'
	);
	port(
		gt_clkp, gt_clkn: in std_logic;
		gt_txp, gt_txn: out std_logic;
		gt_rxp, gt_rxn: in std_logic;
		clk125_out: out std_logic;
		clk125_fr: out std_logic;
		refclk_out: out std_logic;
		rsti: in std_logic;
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
		hostbus_in: in emac_hostbus_in := ('0', "00", "0000000000", X"00000000", '0', '0', '0');
		hostbus_out: out emac_hostbus_out
	);

end eth_7s_1000basex;

architecture rtl of eth_7s_1000basex is

	COMPONENT temac_gbe_v9_0
		PORT (
			gtx_clk : IN STD_LOGIC;
			glbl_rstn : IN STD_LOGIC;
			rx_axi_rstn : IN STD_LOGIC;
			tx_axi_rstn : IN STD_LOGIC;
			rx_statistics_vector : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
			rx_statistics_valid : OUT STD_LOGIC;
			rx_mac_aclk : OUT STD_LOGIC;
			rx_reset : OUT STD_LOGIC;
			rx_axis_mac_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			rx_axis_mac_tvalid : OUT STD_LOGIC;
			rx_axis_mac_tlast : OUT STD_LOGIC;
			rx_axis_mac_tuser : OUT STD_LOGIC;
			tx_ifg_delay : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			tx_statistics_vector : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			tx_statistics_valid : OUT STD_LOGIC;
			tx_mac_aclk : OUT STD_LOGIC;
			tx_reset : OUT STD_LOGIC;
			tx_axis_mac_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			tx_axis_mac_tvalid : IN STD_LOGIC;
			tx_axis_mac_tlast : IN STD_LOGIC;
			tx_axis_mac_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			tx_axis_mac_tready : OUT STD_LOGIC;
			pause_req : IN STD_LOGIC;
			pause_val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			speedis100 : OUT STD_LOGIC;
			speedis10100 : OUT STD_LOGIC;
			gmii_txd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			gmii_tx_en : OUT STD_LOGIC;
			gmii_tx_er : OUT STD_LOGIC;
			gmii_rxd : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			gmii_rx_dv : IN STD_LOGIC;
			gmii_rx_er : IN STD_LOGIC;
			rx_configuration_vector : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
			tx_configuration_vector : IN STD_LOGIC_VECTOR(79 DOWNTO 0)
		);
	END COMPONENT;

	signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0);
	signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic;
	signal gmii_rx_clk: std_logic;
	signal clkin, clk125, txoutclk_ub, txoutclk, clk125_ub, clk_fr: std_logic;
	signal clk62_5_ub, clk62_5, clkfb: std_logic;
	signal rstn, phy_done, mmcm_locked, locked_int: std_logic;
	signal decoupled_clk: std_logic := '0';

begin
	
	ibuf0: IBUFDS_GTE2 port map(
		i => gt_clkp,
		ib => gt_clkn,
		o => clkin,
		ceb => '0'
	);
	
	bufg_fr: BUFG port map(
		i => clkin,
		o => clk_fr
	);
	
	refclk_out <= clkin;
	clk125_fr <= clk_fr;
	
	bufh_tx: BUFH port map(
		i => txoutclk_ub,
		o => txoutclk
	);
	
	mmcm: MMCME2_BASE
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
			rst => rsti,
			pwrdwn => '0',
			locked => mmcm_locked);
	
	bufr_125: BUFH
		port map(
			i => clk125_ub,
			o => clk125
		);

	clk125_out <= clk125;

	bufr_62_5: BUFH
		port map(
			i => clk62_5_ub,
			o => clk62_5
		);

	process(clk_fr)
	begin
		if rising_edge(clk_fr) then
			locked_int <= mmcm_locked and phy_done;
		end if;
	end process;

	locked <= locked_int;
	rstn <= not (not locked_int or rsti);

	mac: temac_gbe_v9_0
		port map(
			gtx_clk => clk125,
			glbl_rstn => rstn,
			rx_axi_rstn => '1',
			tx_axi_rstn => '1',
			rx_statistics_vector => open,
			rx_statistics_valid => open,
			rx_mac_aclk => open,
			rx_reset => open,
			rx_axis_mac_tdata => rx_data,
			rx_axis_mac_tvalid => rx_valid,
			rx_axis_mac_tlast => rx_last,
			rx_axis_mac_tuser => rx_error,
			tx_ifg_delay => X"00",
			tx_statistics_vector => open,
			tx_statistics_valid => open,
			tx_mac_aclk => open,
			tx_reset => open,
			tx_axis_mac_tdata => tx_data,
			tx_axis_mac_tvalid => tx_valid,
			tx_axis_mac_tlast => tx_last,
			tx_axis_mac_tuser(0) => tx_error,
			tx_axis_mac_tready => tx_ready,
			pause_req => '0',
			pause_val => X"0000",
			gmii_txd => gmii_txd,
			gmii_tx_en => gmii_tx_en,
			gmii_tx_er => gmii_tx_er,
			gmii_rxd => gmii_rxd,
			gmii_rx_dv => gmii_rx_dv,
			gmii_rx_er => gmii_rx_er,
			rx_configuration_vector => X"0000_0000_0000_0000_0812",
			tx_configuration_vector => X"0000_0000_0000_0000_0012"
		);

	hostbus_out.hostrddata <= (others => '0');
	hostbus_out.hostmiimrdy <= '0';

	-- Vivado generates a CRC error if you drive the CPLLLOCKDET circuitry with
	-- the same clock used to drive the transceiver PLL.  While this makes sense
	-- if the clk is derved from the CPLL (e.g. TXOUTCLK) it is less clear is 
	-- essential if you use the clock raw from the input pins.  The short story
	-- is that it has always worked in the past with ISE, but Vivado generates 
	-- DRC error.  Can be bypassed by decoupling the clock from the perpective 
	-- of the tools by just toggling a flip flop, which is what is done below.

	process(clk_fr)
	begin
		if rising_edge(clk_fr) then
			decoupled_clk <= not decoupled_clk;
		end if;
	end process;

	phy: entity work.gig_eth_pcs_pma_basex_v15_0
		port map(
			gtrefclk => clkin,
			gtrefclk_bufg => clk_fr,
			txp => gt_txp,
			txn => gt_txn,
			rxp => gt_rxp,
			rxn => gt_rxn,
			txoutclk => txoutclk_ub,
			rxoutclk => open,
			resetdone => phy_done,
			mmcm_reset => open,
			mmcm_locked => mmcm_locked,
			userclk => clk62_5,
			userclk2 => clk125,
			rxuserclk => clk62_5,
			rxuserclk2 => clk125,
			independent_clock_bufg => decoupled_clk,
			pma_reset => rsti,
			gmii_txd => gmii_txd,
			gmii_tx_en => gmii_tx_en,
			gmii_tx_er => gmii_tx_er,
			gmii_rxd => gmii_rxd,
			gmii_rx_dv => gmii_rx_dv,
			gmii_rx_er => gmii_rx_er,
			gmii_isolate => open,
			configuration_vector => "00000",
			status_vector => open,
			reset => rsti,
			signal_detect => '1',
			gt0_qplloutclk_in => '0',
			gt0_qplloutrefclk_in => '0',			
-- Addtional debug ports
			gt0_txpmareset_in         => '0',
			gt0_txpcsreset_in         => '0',
			gt0_rxpmareset_in         => '0',
			gt0_rxpcsreset_in         => '0',
			gt0_rxbufreset_in         => '0',
			gt0_drpaddr_in            => (others=>'0'),

			gt0_drpclk_in                => clk_fr,

			gt0_drpdi_in              => (others=>'0'),
			gt0_drpen_in              => '0',
			gt0_drpwe_in              => '0',
			gt0_rxdfeagcovrden_in     => '0',
			gt0_rxmonitorsel_in       => (others=>'0'),
			gt0_txpolarity_in         => '1',
			gt0_txdiffctrl_in         => "1000",
			gt0_txinhibit_in          => '0',
			gt0_txpostcursor_in       => (others=>'0'),
			gt0_txprecursor_in        => (others=>'0'),
			gt0_rxpolarity_in         => POLARITY_SWAP,
			gt0_rxdfelpmreset_in      => '0',
			gt0_rxlpmen_in            => POLARITY_SWAP,
			gt0_txprbssel_in          => (others=>'0'),
			gt0_txprbsforceerr_in     => '0',
			gt0_rxprbscntreset_in     => '0',
			gt0_rxprbssel_in          => (others=>'0'),
			gt0_loopback_in           => (others=>'0'),
			gt0_eyescanreset_in       => '0',
			gt0_eyescantrigger_in     => '0',
			gt0_rxcdrhold_in          => '0'
		);

end rtl;
