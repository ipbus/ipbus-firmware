-- (c) Copyright 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 
-- 
-- 
--------------------------------------------------------------------------------
-- Description: This is the top level VHDL example design for the
--              Ethernet SGMII core.  The block level wrapper for the
--              core is instantiated and the tranceiver clock circuitry is
--              created.  Additionally, the I/O of the GMII-style
--              interface is provided with IOB flip-flops (infered)
--              which enables this example design to be implemented
--              using the Xilinx tools.
--
--           * Please refer to the Getting Started User Guide for
--             details of the example design file hierarchy.


library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;


--------------------------------------------------------------------------------
-- The entity declaration for the example design
--------------------------------------------------------------------------------

entity gig_eth_pcs_pma_v11_5_example_design is
      port(

      -- An independent clock source used as the reference clock for an
      -- IDELAYCTRL (if present) and for the main GT transceiver reset logic.
      -- This example design assumes that this is of frequency 200MHz.
      independent_clock    : in std_logic;

      -- Tranceiver Interface
      -----------------------

      gtrefclk_p           : in std_logic;                     -- Differential +ve of reference clock for tranceiver: 125MHz, very high quality
      gtrefclk_n           : in std_logic;                     -- Differential -ve of reference clock for tranceiver: 125MHz, very high quality
      txp                  : out std_logic;                    -- Differential +ve of serial transmission from PMA to PMD.
      txn                  : out std_logic;                    -- Differential -ve of serial transmission from PMA to PMD.
      rxp                  : in std_logic;                     -- Differential +ve for serial reception from PMD to PMA.
      rxn                  : in std_logic;                     -- Differential -ve for serial reception from PMD to PMA.

      -- GMII Interface (client MAC <=> PCS)
      --------------------------------------
      gmii_tx_clk          : in std_logic;                     -- Transmit clock from client MAC.
      gmii_rx_clk          : out std_logic;                    -- Receive clock to client MAC.
      gmii_txd             : in std_logic_vector(7 downto 0);  -- Transmit data from client MAC.
      gmii_tx_en           : in std_logic;                     -- Transmit control signal from client MAC.
      gmii_tx_er           : in std_logic;                     -- Transmit control signal from client MAC.
      gmii_rxd             : out std_logic_vector(7 downto 0); -- Received Data to client MAC.
      gmii_rx_dv           : out std_logic;                    -- Received control signal to client MAC.
      gmii_rx_er           : out std_logic;                    -- Received control signal to client MAC.
      -- Management: Alternative to MDIO Interface
      --------------------------------------------

      configuration_vector : in std_logic_vector(4 downto 0);  -- Alternative to MDIO interface.

      -- General IO's
      ---------------
      status_vector        : out std_logic_vector(15 downto 0); -- Core status.
      reset                : in std_logic;                     -- Asynchronous reset for entire core.
      signal_detect        : in std_logic                      -- Input from PMD to indicate presence of optical input.
      );
end gig_eth_pcs_pma_v11_5_example_design;



architecture top_level of gig_eth_pcs_pma_v11_5_example_design is



   -----------------------------------------------------------------------------
   -- Component Declaration for the Transmitter Elastic Buffer
   -----------------------------------------------------------------------------
   component gig_eth_pcs_pma_v11_5_tx_elastic_buffer
   port (

      reset                : in std_logic;                     -- Asynchronous Reset.

      -- Signals received from the input gmii_tx_clk_wr domain.
      ---------------------------------------------------------

      gmii_tx_clk_wr       : in std_logic;                     -- Write clock domain.
      gmii_txd_wr          : in std_logic_vector(7 downto 0);  -- gmii_txd synchronous to gmii_tx_clk_wr.
      gmii_tx_en_wr        : in std_logic;                     -- gmii_tx_en synchronous to gmii_tx_clk_wr.
      gmii_tx_er_wr        : in std_logic;                     -- gmii_tx_er synchronous to gmii_tx_clk_wr.

      -- Signals transfered onto the new gmii_tx_clk_rd domain.
      ---------------------------------------------------------

      gmii_tx_clk_rd       : in std_logic;                     -- Read clock domain.
      gmii_txd_rd          : out std_logic_vector(7 downto 0); -- gmii_txd synchronous to gmii_tx_clk_rd.
      gmii_tx_en_rd        : out std_logic;                    -- gmii_tx_en synchronous to gmii_tx_clk_rd.
      gmii_tx_er_rd        : out std_logic                     -- gmii_tx_er synchronous to gmii_tx_clk_rd.
   );
   end component;


   -----------------------------------------------------------------------------
   -- Component declaration for the reset synchroniser
   -----------------------------------------------------------------------------
   component gig_eth_pcs_pma_v11_5_reset_sync
   port (
      reset_in             : in  std_logic;                    -- Active high asynchronous reset
      clk                  : in  std_logic;                    -- clock to be sync'ed to
      reset_out            : out std_logic                     -- "Synchronised" reset signal
   );
   end component;



  ------------------------------------------------------------------------------
  -- Component Declaration for the Core Block (core wrapper).
  ------------------------------------------------------------------------------
   component gig_eth_pcs_pma_v11_5_block
generic
(
    EXAMPLE_SIMULATION                      : integer   := 0          -- Set to 1 for simulation
);
      port(
      -- Transceiver Interface
      ------------------------
      drpaddr_in           : in   std_logic_vector(8 downto 0);
      drpclk_in            : in   std_logic;
      drpdi_in             : in   std_logic_vector(15 downto 0);
      drpdo_out            : out  std_logic_vector(15 downto 0);
      drpen_in             : in   std_logic;
      drprdy_out           : out  std_logic;
      drpwe_in             : in   std_logic;

      gtrefclk             : in std_logic;                     -- Very high quality 125MHz clock for GT transceiver
      txp                  : out std_logic;                    -- Differential +ve of serial transmission from PMA to PMD.
      txn                  : out std_logic;                    -- Differential -ve of serial transmission from PMA to PMD.
      rxp                  : in std_logic;                     -- Differential +ve for serial reception from PMD to PMA.
      rxn                  : in std_logic;                     -- Differential -ve for serial reception from PMD to PMA.

      txoutclk             : out std_logic;                    -- txoutclk from GT transceiver (62.5MHz)
      resetdone            : out std_logic;                    -- The GT transceiver has completed its reset cycle
      mmcm_locked          : in std_logic;                     -- Locked signal from MMCM
      userclk              : in std_logic;                     -- 62.5MHz clock.
      userclk2             : in std_logic;                     -- 125MHz clock.
      independent_clock_bufg: in std_logic;                    -- 200MHz clock.
      pma_reset            : in std_logic;                     -- transceiver PMA reset signal

      -- GMII Interface
      -----------------
      gmii_txd             : in std_logic_vector(7 downto 0);  -- Transmit data from client MAC.
      gmii_tx_en           : in std_logic;                     -- Transmit control signal from client MAC.
      gmii_tx_er           : in std_logic;                     -- Transmit control signal from client MAC.
      gmii_rxd             : out std_logic_vector(7 downto 0); -- Received Data to client MAC.
      gmii_rx_dv           : out std_logic;                    -- Received control signal to client MAC.
      gmii_rx_er           : out std_logic;                    -- Received control signal to client MAC.
      gmii_isolate         : out std_logic;                    -- Tristate control to electrically isolate GMII.

      -- Management: Alternative to MDIO Interface
      --------------------------------------------

      configuration_vector : in std_logic_vector(4 downto 0);  -- Alternative to MDIO interface.


      -- General IO's
      ---------------
      status_vector        : out std_logic_vector(15 downto 0); -- Core status.
      reset                : in std_logic;                     -- Asynchronous reset for entire core.
      signal_detect        : in std_logic                      -- Input from PMD to indicate presence of optical input.

      );

   end component;



  ------------------------------------------------------------------------------
  -- internal signals used in this top level example design.
  ------------------------------------------------------------------------------

  -- clock generation signals for tranceiver
  signal gtrefclk              : std_logic;                    -- Route gtrefclk through an IBUFG.
  signal txoutclk              : std_logic;                    -- txoutclk from GT transceiver
  signal resetdone             : std_logic;                    -- To indicate that the GT transceiver has completed its reset cycle
  signal mmcm_locked           : std_logic;                    -- MMCM locked signal.
  signal mmcm_reset            : std_logic;                    -- MMCM reset signal.
  signal clkfbout              : std_logic;                    -- MMCM feedback clock
  signal clkout0               : std_logic;                    -- MMCM clock0 output (62.5MHz).
  signal clkout1               : std_logic;                    -- MMCM clock1 output (125MHz).
  signal userclk               : std_logic;                    -- 62.5MHz clock for GT transceiver Tx/Rx user clocks
  signal userclk2              : std_logic;                    -- 125MHz clock for core reference clock.

  -- PMA reset generation signals for tranceiver
  signal pma_reset_pipe        : std_logic_vector(3 downto 0); -- flip-flop pipeline for reset duration stretch
  signal pma_reset             : std_logic;                    -- Synchronous transcevier PMA reset

  -- An independent clock source used as the reference clock for an
  -- IDELAYCTRL (if present) and for the main GT transceiver reset logic.
  signal independent_clock_bufg: std_logic;

  -- Signals used for an IDELAYCTRL
  signal idelayctrl_reset_sync : std_logic;                    -- Used to create a reset pulse in the IDELAYCTRL clock domain.
  signal idelay_reset_cnt      : std_logic_vector(3 downto 0); -- Counter to create a long IDELAYCTRL reset pulse.
  signal idelayctrl_reset      : std_logic;                    -- The reset pulse for the IDELAYCTRL.

  -- GMII signals
  signal gmii_tx_clk_bufio     : std_logic;                    -- gmii_tx_clk routed through an BUFIO.
  signal gmii_tx_clk_bufr      : std_logic;                    -- gmii_tx_clk_ibuf routed through a BUFR
  signal gmii_txd_delay        : std_logic_vector(7 downto 0); -- Internal gmii_txd signal after IDELAY.
  signal gmii_tx_en_delay      : std_logic;                    -- Internal gmii_tx_en signal after IDELAY.
  signal gmii_tx_er_delay      : std_logic;                    -- Internal gmii_tx_er signal after IDELAY.
  signal gmii_isolate          : std_logic;                    -- Internal gmii_isolate signal.
  signal gmii_txd_iff          : std_logic_vector(7 downto 0); -- gmii_txd signal for input IOB flip-flop.
  signal gmii_tx_en_iff        : std_logic;                    -- gmii_tx_en signal for input IOB flip-flop.
  signal gmii_tx_er_iff        : std_logic;                    -- gmii_tx_er signal for input IOB flip-flop.
  signal gmii_txd_reg          : std_logic_vector(7 downto 0); -- Internal gmii_txd signal.
  signal gmii_tx_en_reg        : std_logic;                    -- Internal gmii_tx_en signal.
  signal gmii_tx_er_reg        : std_logic;                    -- Internal gmii_tx_er signal.
  signal gmii_txd_fifo         : std_logic_vector(7 downto 0); -- gmii_txd signal after Tx Elastic Buffer.
  signal gmii_tx_en_fifo       : std_logic;                    -- gmii_tx_en signal after Tx Elastic Buffer.
  signal gmii_tx_er_fifo       : std_logic;                    -- gmii_tx_er signal after Tx Elastic Buffer.
  signal gmii_rxd_int          : std_logic_vector(7 downto 0); -- Internal gmii_rxd signal.
  signal gmii_rx_dv_int        : std_logic;                    -- Internal gmii_rx_dv signal.
  signal gmii_rx_er_int        : std_logic;                    -- Internal gmii_rx_er signal.
  signal gmii_rx_clk_obuf      : std_logic;                    -- gmii_rx_clk registered in IOBs prior to an OBUF.
  signal gmii_rxd_obuf         : std_logic_vector(7 downto 0); -- gmii_rxd registered in IOBs prior to an OBUF.
  signal gmii_rx_dv_obuf       : std_logic;                    -- gmii_rx_dv registered in IOBs prior to an OBUF.
  signal gmii_rx_er_obuf       : std_logic;                    -- gmii_rx_er registered in IOBs prior to an OBUF.

  -- Extra registers to ease IOB placement
  signal status_vector_int : std_logic_vector(15 downto 0);

  -- These attributes will stop timing errors being reported in back annotated
  -- SDF simulation.
  attribute ASYNC_REG                   : string;
  attribute ASYNC_REG of pma_reset_pipe : signal is "TRUE";



begin



   -----------------------------------------------------------------------------
   -- An independent clock source used as the reference clock for an
   -- IDELAYCTRL (if present) and for the main GT transceiver reset logic.
   -----------------------------------------------------------------------------

   -- Route independent_clock input through a BUFG
   bufg_independent_clock : BUFG
   port map (
      I         => independent_clock,
      O         => independent_clock_bufg
   );


   -----------------------------------------------------------------------------
   -- Instantiate an IDELAYCTRLL and its reset circuitry
   -----------------------------------------------------------------------------

   -- Instantiate the IDELAY Controller.
   dlyctrl : IDELAYCTRL
   port map (
      RDY       => open,
      REFCLK    => independent_clock_bufg,
      RST       => idelayctrl_reset
   );


   -- Create a synchronous reset in the IDELAYCTRL clock domain.
   idelayctrl_reset_gen : gig_eth_pcs_pma_v11_5_reset_sync
   port map(
      clk       => independent_clock_bufg,
      reset_in  => reset,
      reset_out => idelayctrl_reset_sync
   );


   -- Reset circuitry for the IDELAYCTRL reset.

   -- The IDELAYCTRL must experience a pulse which is at least 50 ns in
   -- duration.  This is ten clock cycles of the 200MHz independent_clock.
   --   Here we drive the reset pulse for 12 clock cycles.
   process (independent_clock_bufg)
   begin
      if independent_clock_bufg'event and independent_clock_bufg = '1' then
         if idelayctrl_reset_sync = '1' then
            idelay_reset_cnt <= "0000";
            idelayctrl_reset <= '1';
         else
            idelayctrl_reset <= '1';
            case idelay_reset_cnt is
            when "0000"  => idelay_reset_cnt <= "0001";
            when "0001"  => idelay_reset_cnt <= "0010";
            when "0010"  => idelay_reset_cnt <= "0011";
            when "0011"  => idelay_reset_cnt <= "0100";
            when "0100"  => idelay_reset_cnt <= "0101";
            when "0101"  => idelay_reset_cnt <= "0110";
            when "0110"  => idelay_reset_cnt <= "0111";
            when "0111"  => idelay_reset_cnt <= "1000";
            when "1000"  => idelay_reset_cnt <= "1001";
            when "1001"  => idelay_reset_cnt <= "1010";
            when "1010"  => idelay_reset_cnt <= "1011";
            when "1011"  => idelay_reset_cnt <= "1100";
            when "1100"  => idelay_reset_cnt <= "1101";
            when "1101"  => idelay_reset_cnt <= "1110";
            when others  => idelay_reset_cnt <= "1110";
                            idelayctrl_reset <= '0';
            end case;
         end if;
      end if;
   end process;



   -----------------------------------------------------------------------------
   -- Transceiver Clock Management
   -----------------------------------------------------------------------------

   -- Clock circuitry for the GT Transceiver uses a differential input clock.
   -- gtrefclk is routed to the tranceiver.
   ibufds_gtrefclk : IBUFDS_GTE2
   port map (
      I     => gtrefclk_p,
      IB    => gtrefclk_n,
      CEB   => '0',
      O     => gtrefclk,
      ODIV2 => open
   );


  -- The GT transceiver provides a 62.5MHz clock to the FPGA fabrix.  This is 
  -- routed to an MMCM module where it is used to create phase and frequency
  -- related 62.5MHz and 125MHz clock sources
  mmcm_adv_inst : MMCME2_ADV
  generic map
   (BANDWIDTH            => "OPTIMIZED",
    CLKOUT4_CASCADE      => FALSE,
    COMPENSATION         => "ZHOLD",
    STARTUP_WAIT         => FALSE,
    DIVCLK_DIVIDE        => 1,
    CLKFBOUT_MULT_F      => 16.000,
    CLKFBOUT_PHASE       => 0.000,
    CLKFBOUT_USE_FINE_PS => FALSE,
    CLKOUT0_DIVIDE_F     => 8.000,
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.5,
    CLKOUT0_USE_FINE_PS  => FALSE,
    CLKOUT1_DIVIDE       => 16,
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.5,
    CLKOUT1_USE_FINE_PS  => FALSE,
    CLKIN1_PERIOD        => 16.0,
    REF_JITTER1          => 0.010)
  port map
    -- Output clocks
   (CLKFBOUT             => clkfbout,
    CLKFBOUTB            => open,
    CLKOUT0              => clkout0,
    CLKOUT0B             => open,
    CLKOUT1              => clkout1,
    CLKOUT1B             => open,
    CLKOUT2              => open,
    CLKOUT2B             => open,
    CLKOUT3              => open,
    CLKOUT3B             => open,
    CLKOUT4              => open,
    CLKOUT5              => open,
    CLKOUT6              => open,
    -- Input clock control
    CLKFBIN              => clkfbout,
    CLKIN1               => txoutclk,
    CLKIN2               => '0',
    -- Tied to always select the primary input clock
    CLKINSEL             => '1',
    -- Ports for dynamic reconfiguration
    DADDR                => (others => '0'),
    DCLK                 => '0',
    DEN                  => '0',
    DI                   => (others => '0'),
    DO                   => open,
    DRDY                 => open,
    DWE                  => '0',
    -- Ports for dynamic phase shift
    PSCLK                => '0',
    PSEN                 => '0',
    PSINCDEC             => '0',
    PSDONE               => open,
    -- Other control and status signals
    LOCKED               => mmcm_locked,
    CLKINSTOPPED         => open,
    CLKFBSTOPPED         => open,
    PWRDWN               => '0',
    RST                  => mmcm_reset);

    mmcm_reset <= reset;

   -- This 62.5MHz clock is placed onto global clock routing and is then used
   -- for tranceiver TXUSRCLK/RXUSRCLK.
   bufg_userclk: BUFG
   port map (
      I     => clkout1,
      O     => userclk
   );    


   -- This 125MHz clock is placed onto global clock routing and is then used
   -- to clock all Ethernet core logic.
   bufg_userclk2: BUFG
   port map (
      I     => clkout0,
      O     => userclk2
   );    



   -----------------------------------------------------------------------------
   -- Transceiver PMA reset circuitry
   -----------------------------------------------------------------------------

   -- Create a reset pulse of a decent length
   process(reset, independent_clock_bufg)
   begin
     if (reset = '1') then
       pma_reset_pipe <= "1111";
     elsif independent_clock_bufg'event and independent_clock_bufg = '1' then
       pma_reset_pipe <= pma_reset_pipe(2 downto 0) & reset;
     end if;
   end process;

   pma_reset <= pma_reset_pipe(3);


  ------------------------------------------------------------------------------
  -- Instantiate the Core Block (core wrapper).
  ------------------------------------------------------------------------------

  core_wrapper : gig_eth_pcs_pma_v11_5_block
    generic map (
        EXAMPLE_SIMULATION              =>    1 

    )
    port map (
      drpaddr_in          => (others => '0') , 
      drpclk_in           => userclk2, 
      drpdi_in            => (others => '0') , 
      drpdo_out           => open , 
      drpen_in            => '0', 
      drprdy_out          => open, 
      drpwe_in            => '0', 

      gtrefclk             => gtrefclk,
      txp                  => txp,
      txn                  => txn,
      rxp                  => rxp,
      rxn                  => rxn,
      txoutclk             => txoutclk,
      resetdone            => resetdone,
      mmcm_locked          => mmcm_locked,
      userclk              => userclk,
      userclk2             => userclk2,
      independent_clock_bufg => independent_clock_bufg,
      pma_reset              => pma_reset,
      gmii_txd             => gmii_txd_fifo,
      gmii_tx_en           => gmii_tx_en_fifo,
      gmii_tx_er           => gmii_tx_er_fifo,
      gmii_rxd             => gmii_rxd_int,
      gmii_rx_dv           => gmii_rx_dv_int,
      gmii_rx_er           => gmii_rx_er_int,
      gmii_isolate         => gmii_isolate,
      configuration_vector => configuration_vector,
      status_vector        => status_vector_int,
      reset                => reset,
      signal_detect        => signal_detect
      );



   -----------------------------------------------------------------------------
   -- GMII transmitter clock logic
   -----------------------------------------------------------------------------

   -- Route gmii_tx_clk from PAD through a BUFIO Buffer
   receive_gmii_tx_clk : BUFIO
   port map (
      I   => gmii_tx_clk,
      O   => gmii_tx_clk_bufio
   );


   -- Route gmii_tx_clk through a BUFR onto regional clock routing
   drive_tx_clk : BUFR
   port map (
      I   => gmii_tx_clk,
      CE  => '1',
      CLR => '0',
      O   => gmii_tx_clk_bufr
   );



   -----------------------------------------------------------------------------
   -- GMII transmitter data logic
   -----------------------------------------------------------------------------

   -- An IOBDELAY is used with Series-7 devices to meet the GMII input
   -- setup and hold specifications. The data is delayed so to compensate for
   -- the clock routing delay so that the GMII input data will be correctly
   -- sampled at the IOB flip-flops

   -- Please modify the value of the IOBDELAY according to your design.
   -- The value in this file will be overridden with the value in the
   -- UCF.  For more information, please refer to the User Guide.

   -- The tap delay values can also be adjusted to compensate for PCB routing
   -- deskew.

   -- IODELAY for GMII_TXD
   gmii_data_bus: for I in 7 downto 0 generate
   begin
      delay_gmii_txd : IODELAYE1
      generic map (
         IDELAY_TYPE  => "FIXED",
         IDELAY_VALUE => 0
      )
      port map (
         IDATAIN      => gmii_txd(I),
         ODATAIN      => '0',
         DATAOUT      => gmii_txd_delay(I),
         DATAIN       => '0',
         CNTVALUEIN   => "00000",
         CNTVALUEOUT  => open,
         CLKIN        => '0',
         CINVCTRL     => '0',
         T            => '1',
         C            => '0',
         CE           => '0',
         INC          => '0',
         RST          => '0'
      );
   end generate;


   -- IODELAY for GMII_TX_EN
   delay_gmii_tx_en : IODELAYE1
   generic map (
      IDELAY_TYPE  => "FIXED",
      IDELAY_VALUE => 0
   )
   port map (
      IDATAIN      => gmii_tx_en,
      ODATAIN      => '0',
      DATAOUT      => gmii_tx_en_delay,
      DATAIN       => '0',
      CNTVALUEIN   => "00000",
      CNTVALUEOUT  => open,
      CLKIN        => '0',
      CINVCTRL     => '0',
      T            => '1',
      C            => '0',
      CE           => '0',
      INC          => '0',
      RST          => '0'
   );


   -- IODELAY for GMII_TX_ER
   delay_gmii_tx_er : IODELAYE1
   generic map (
      IDELAY_TYPE  => "FIXED",
      IDELAY_VALUE => 0
   )
   port map (
      IDATAIN      => gmii_tx_er,
      ODATAIN      => '0',
      DATAOUT      => gmii_tx_er_delay,
      DATAIN       => '0',
      CNTVALUEIN   => "00000",
      CNTVALUEOUT  => open,
      CLKIN        => '0',
      CINVCTRL     => '0',
      T            => '1',
      C            => '0',
      CE           => '0',
      INC          => '0',
      RST          => '0'
   );


   -- Drive input GMII signals through IOB input flip-flops (inferred).
   process (gmii_tx_clk_bufio)
   begin
      if gmii_tx_clk_bufio'event and gmii_tx_clk_bufio = '1' then
         gmii_txd_iff    <= gmii_txd_delay;
         gmii_tx_en_iff  <= gmii_tx_en_delay;
         gmii_tx_er_iff  <= gmii_tx_er_delay;

      end if;
   end process;


   -- Reclock onto regional clock routing.
   process (gmii_tx_clk_bufr)
   begin
      if gmii_tx_clk_bufr'event and gmii_tx_clk_bufr = '1' then
         gmii_txd_reg    <= gmii_txd_iff;
         gmii_tx_en_reg  <= gmii_tx_en_iff;
         gmii_tx_er_reg  <= gmii_tx_er_iff;

      end if;
   end process;


   -- Component Instantiation for the Transmitter Elastic Buffer
   tx_elastic_buffer_inst : gig_eth_pcs_pma_v11_5_tx_elastic_buffer
   port map (
      reset            => reset,
      gmii_tx_clk_wr   => gmii_tx_clk_bufr,
      gmii_txd_wr      => gmii_txd_reg,
      gmii_tx_en_wr    => gmii_tx_en_reg,
      gmii_tx_er_wr    => gmii_tx_er_reg,
      gmii_tx_clk_rd   => userclk2,
      gmii_txd_rd      => gmii_txd_fifo,
      gmii_tx_en_rd    => gmii_tx_en_fifo,
      gmii_tx_er_rd    => gmii_tx_er_fifo
   );



   -----------------------------------------------------------------------------
   -- GMII receiver clock logic
   -----------------------------------------------------------------------------

   -- This instantiates a DDR output register.  This is a nice way to
   -- drive the GMII output clock since the clock-to-PAD delay will the
   -- same as that of data driven from an IOB Ouput flip-flop.  This is
   -- set to produce an inverted clock w.r.t. userclk2 so that clock
   -- rising edge appears in the centre of GMII data.
   rx_clk_ddr_iob : ODDR
   port map (
      Q  => gmii_rx_clk_obuf,
      C  => userclk2,
      CE => '1',
      D1 => '0',
      D2 => '1',
      R  => '0',
      S  => '0'
   );


   -- Finally the clock is driven onto the PAD from an Output Buffer.
   drive_gmii_gtx_clk: OBUFT
   port map (
      I  => gmii_rx_clk_obuf,
      O  => gmii_rx_clk,
      T  => gmii_isolate
   );



   -----------------------------------------------------------------------------
   -- GMII receiver data logic
   -----------------------------------------------------------------------------


   -- Drive Rx GMII signals through IOB output flip-flops (inferred).
   process (userclk2)
   begin
      if userclk2'event and userclk2 = '1' then
         gmii_rxd_obuf   <= gmii_rxd_int;
         gmii_rx_dv_obuf <= gmii_rx_dv_int;
         gmii_rx_er_obuf <= gmii_rx_er_int;

      end if;
   end process;


   --  drive GMII Rx signals through output PADS.
   rx_data_valid : OBUFT
   port map (
      I => gmii_rx_dv_obuf,
      O => gmii_rx_dv,
      T => gmii_isolate
   );

   rx_data_error : OBUFT
   port map (
      I => gmii_rx_er_obuf,
      O => gmii_rx_er,
      T => gmii_isolate
   );

   rx_data_bus: for I in 7 downto 0 generate
      rx_data_bits : OBUFT
      port map (
         I => gmii_rxd_obuf(I),
         O => gmii_rxd(I),
         T => gmii_isolate
      );
   end generate;



   -----------------------------------------------------------------------------
   -- Extra registers to ease IOB placement
   -----------------------------------------------------------------------------
   process (userclk2)
   begin
      if userclk2'event and userclk2 = '1' then
         status_vector <= status_vector_int;
      end if;
   end process;


end top_level;
