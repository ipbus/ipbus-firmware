--------------------------------------------------------------------------------
-- Title      : Top-level Transceiver GT wrapper for Ethernet
-- Project    : Ethernet 1000BASE-X PCS/PMA or SGMII LogiCORE
--------------------------------------------------------------------------------
-- File       : gig_eth_pcs_pma_v11_4_transceiver.vhd
-- Author     : Xilinx
--------------------------------------------------------------------------------
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
-- Description:  This is the top-level Transceiver GT wrapper. It
--               instantiates the lower-level wrappers produced by
--               the Series-7 FPGA Transceiver GT Wrapper Wizard.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library unisim;
use unisim.vcomponents.all;


entity gig_eth_pcs_pma_v11_4_transceiver is
   port (
      data_valid        : in std_logic; -- Core status.
      independent_clock    : in std_logic;
      encommaalign        : in    std_logic;
      loopback            : in    std_logic;
      powerdown           : in    std_logic;
      usrclk              : in    std_logic;
      usrclk2             : in    std_logic;
      txreset             : in    std_logic;
      txdata              : in    std_logic_vector (7 downto 0);
      txchardispmode      : in    std_logic;
      txchardispval       : in    std_logic;
      txcharisk           : in    std_logic;
      rxreset             : in    std_logic;
      rxchariscomma       : out   std_logic;
      rxcharisk           : out   std_logic;
      rxclkcorcnt         : out   std_logic_vector (2 downto 0);
      rxdata              : out   std_logic_vector (7 downto 0);
      rxdisperr           : out   std_logic;
      rxnotintable        : out   std_logic;
      rxrundisp           : out   std_logic;
      rxbuferr            : out   std_logic;
      txbuferr            : out   std_logic;
      plllkdet            : out   std_logic;
      txoutclk            : out   std_logic;
      rxelecidle          : out   std_logic;
      txn                 : out   std_logic;
      txp                 : out   std_logic;
      rxn                 : in    std_logic;
      rxp                 : in    std_logic;
      gtrefclk            : in    std_logic;
      pmareset            : in    std_logic;
      mmcm_locked         : in    std_logic;
      resetdone           : out   std_logic
   );
end gig_eth_pcs_pma_v11_4_transceiver;


architecture wrapper of gig_eth_pcs_pma_v11_4_transceiver is
   component gig_eth_pcs_pma_v11_4_sync_block
   generic (
     INITIALISE : bit_vector(1 downto 0) := "00"
   );
   port  (
             clk           : in  std_logic;
             data_in       : in  std_logic;
             data_out      : out std_logic
          );
   end component;


   -----------------------------------------------------------------------------
   -- Component declatarion for the gig_eth_pcs_pma_v11_4_Transceiver GT file
   -- (generated by the GT Wizard)
   -----------------------------------------------------------------------------

  component gtwizard_v2_3_gbe_init
  generic
  (
    -- Simulation attributes
    EXAMPLE_SIM_GTRESET_SPEEDUP    : string   := "false" -- Set to "true" to speed up sim reset
  );
  port
  (

    SYSCLK_IN                               : in   std_logic;
    SOFT_RESET_IN                           : in   std_logic;
    GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_DATA_VALID_IN                       : in   std_logic;
    --_________________________________________________________________________
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT1  (X0ERROR)
    --____________________________CHANNEL PORTS________________________________
    ------------------------- Channel - Ref Clock Ports ------------------------
    GT0_GTREFCLK0_IN                        : in   std_logic;
    -------------------------------- Channel PLL -------------------------------
    GT0_CPLLFBCLKLOST_OUT                   : out  std_logic;
    GT0_CPLLLOCK_OUT                        : out  std_logic;
    GT0_CPLLLOCKDETCLK_IN                   : in   std_logic;
    --GT0_CPLLREFCLKLOST_OUT                  : out  std_logic;
    GT0_CPLLRESET_IN                        : in   std_logic;
    ------------------------------- Eye Scan Ports -----------------------------
    GT0_EYESCANDATAERROR_OUT                : out  std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT0_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT0_RXPD_IN                             : in   std_logic_vector(1 downto 0);
    GT0_TXPD_IN                             : in   std_logic_vector(1 downto 0);
    ------------------------------- Receive Ports ------------------------------
    GT0_RXUSERRDY_IN                        : in   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT0_RXCHARISCOMMA_OUT                   : out  std_logic_vector(1 downto 0);
    GT0_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT0_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT0_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT0_RXCLKCORCNT_OUT                     : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT0_RXMCOMMAALIGNEN_IN                  : in   std_logic;
    GT0_RXPCOMMAALIGNEN_IN                  : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT0_GTRXRESET_IN                        : in   std_logic;
    GT0_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT0_RXOUTCLK_OUT                        : out  std_logic;
    --GT0_RXPCSRESET_IN                       : in   std_logic;
    GT0_RXUSRCLK_IN                         : in   std_logic;
    GT0_RXUSRCLK2_IN                        : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT0_GTXRXN_IN                           : in   std_logic;
    GT0_GTXRXP_IN                           : in   std_logic;
    GT0_RXCDRLOCK_OUT                       : out  std_logic;
    GT0_RXELECIDLE_OUT                      : out  std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT0_RXBUFRESET_IN                       : in   std_logic;
    GT0_RXBUFSTATUS_OUT                     : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT0_RXRESETDONE_OUT                     : out  std_logic;
    ------------------------------- Transmit Ports -----------------------------
    GT0_TXUSERRDY_IN                        : in   std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT0_TXCHARDISPMODE_IN                   : in   std_logic_vector(1 downto 0);
    GT0_TXCHARDISPVAL_IN                    : in   std_logic_vector(1 downto 0);
    GT0_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT0_GTTXRESET_IN                        : in   std_logic;
    GT0_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT0_TXOUTCLK_OUT                        : out  std_logic;
    GT0_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT0_TXOUTCLKPCS_OUT                     : out  std_logic;
    --GT0_TXPCSRESET_IN                       : in   std_logic;
    GT0_TXUSRCLK_IN                         : in   std_logic;
    GT0_TXUSRCLK2_IN                        : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT0_GTXTXN_OUT                          : out  std_logic;
    GT0_GTXTXP_OUT                          : out  std_logic;
    ----------- Transmit Ports - TX Elastic Buffer and Phase Alignment ---------
    GT0_TXBUFSTATUS_OUT                     : out  std_logic_vector(1 downto 0);
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT0_TXRESETDONE_OUT                     : out  std_logic;
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    --GT0_TXELECIDLE_IN                       : in   std_logic
	 
	 --____________________________COMMON PORTS________________________________
    ---------------------- Common Block  - Ref Clock Ports ---------------------
    GT0_GTREFCLK0_COMMON_IN                 : in   std_logic;
    ------------------------- Common Block - QPLL Ports ------------------------
    GT0_QPLLLOCK_OUT                        : out  std_logic;
    GT0_QPLLLOCKDETCLK_IN                   : in   std_logic;
    GT0_QPLLRESET_IN                        : in   std_logic
	 
  );
  end component;


   -----------------------------------------------------------------------------
   -- Component declaration for the reset synchroniser
   -----------------------------------------------------------------------------
   component gig_eth_pcs_pma_v11_4_reset_sync
   port (
      reset_in                   : in  std_logic;
      clk                        : in  std_logic;
      reset_out                  : out std_logic
   );
   end component;


   signal  data_valid_reg           : std_logic;
   signal  data_valid_reg2          : std_logic;
   -----------------------------------------------------------------------------
   -- Signal declarations
   -----------------------------------------------------------------------------

   signal cplllock               : std_logic;
   signal gt_reset_rx            : std_logic;
   signal gt_reset_tx            : std_logic;
   signal resetdone_tx           : std_logic;
   signal resetdone_rx           : std_logic;
   signal pcsreset               : std_logic;

   signal rxbufstatus            : std_logic_vector(2 downto 0);
   signal txbufstatus            : std_logic_vector(1 downto 0);
   signal rxbufstatus_reg        : std_logic_vector(2 downto 0);
   signal txbufstatus_reg        : std_logic_vector(1 downto 0);
   signal rxclkcorcnt_int        : std_logic_vector(1 downto 0);

    -- signal used to control sampling during bus width conversions
   signal toggle                 : std_logic;

   -- signals reclocked onto the 62.5MHz userclk source of the GT transceiver
   signal encommaalign_int       : std_logic;
   signal txreset_int            : std_logic;
   signal rxreset_int            : std_logic;

   -- Register transmitter signals from the core
   signal txdata_reg            : std_logic_vector (7 downto 0);
   signal txchardispmode_reg    : std_logic;
   signal txchardispval_reg     : std_logic;
   signal txcharisk_reg         : std_logic;

   -- Signals for data bus width doubling on the transmitter path from the core
   -- to the GT transceiver
   signal txdata_double          : std_logic_vector (15 downto 0);
   signal txchardispmode_double  : std_logic_vector (1 downto 0);
   signal txchardispval_double   : std_logic_vector (1 downto 0);
   signal txcharisk_double       : std_logic_vector (1 downto 0);

   -- Double width signals reclocked onto the 62.5MHz userclk source of the GT
   -- transceiver
   signal txdata_int             : std_logic_vector (15 downto 0);
   signal txchardispmode_int     : std_logic_vector (1 downto 0);
   signal txchardispval_int      : std_logic_vector (1 downto 0);
   signal txcharisk_int          : std_logic_vector (1 downto 0);

   -- Double width signals output from the GT transceiver on the 62.5MHz clock
   -- source
   signal rxchariscomma_int      : std_logic_vector (1 downto 0);
   signal rxcharisk_int          : std_logic_vector (1 downto 0);
   signal rxdata_int             : std_logic_vector (15 downto 0);
   signal rxdisperr_int          : std_logic_vector (1 downto 0);
   signal rxnotintable_int       : std_logic_vector (1 downto 0);
   signal rxrundisp_int          : std_logic_vector (1 downto 0);

   -- Double width signals reclocked on the GT's 62.5MHz clock source
   signal rxchariscomma_reg      : std_logic_vector (1 downto 0);
   signal rxcharisk_reg          : std_logic_vector (1 downto 0);
   signal rxdata_reg             : std_logic_vector (15 downto 0);
   signal rxdisperr_reg          : std_logic_vector (1 downto 0);
   signal rxnotintable_reg       : std_logic_vector (1 downto 0);
   signal rxrundisp_reg          : std_logic_vector (1 downto 0);

   -- Double width signals reclocked onto the 125MHz clock source
   signal rxchariscomma_double   : std_logic_vector (1 downto 0);
   signal rxcharisk_double       : std_logic_vector (1 downto 0);
   signal rxdata_double          : std_logic_vector (15 downto 0);
   signal rxdisperr_double       : std_logic_vector (1 downto 0);
   signal rxnotintable_double    : std_logic_vector (1 downto 0);
   signal rxrundisp_double       : std_logic_vector (1 downto 0);


   -- Signals for powerdown
   signal txpowerdown_int        : std_logic_vector(1 downto 0);
   signal rxpowerdown_int        : std_logic_vector(1 downto 0);
   signal txpowerdown_reg        : std_logic := '0';
   signal txpowerdown_double     : std_logic := '0';
   signal txpowerdown            : std_logic := '0';
   signal rxpowerdown_reg        : std_logic := '0';
   signal rxpowerdown_double     : std_logic := '0';
   signal rxpowerdown            : std_logic := '0';

begin

   txpowerdown_int <= txpowerdown & txpowerdown;
   rxpowerdown_int <= rxpowerdown & rxpowerdown;

   -----------------------------------------------------------------------------
   -- The core works from a 125MHz clock source, the GT transceiver fabric
   -- interface works from a 62.5MHz clock source.  The following signals
   -- sourced by the core therefore need to be reclocked onto the 62.5MHz
   -- clock
   -----------------------------------------------------------------------------

   -- Reclock encommaalign
   reclock_encommaalign : gig_eth_pcs_pma_v11_4_reset_sync
   port map(
      clk       => usrclk,
      reset_in  => encommaalign,
      reset_out => encommaalign_int
   );


   -- Reclock txreset
   reclock_txreset : gig_eth_pcs_pma_v11_4_reset_sync
   port map(
      clk       => usrclk,
      reset_in  => txreset,
      reset_out => txreset_int
   );


   -- Reclock rxreset
   reclock_rxreset : gig_eth_pcs_pma_v11_4_reset_sync
   port map(
      clk       => usrclk,
      reset_in  => rxreset,
      reset_out => rxreset_int
   );


   -----------------------------------------------------------------------------
   -- toggle signal used to control sampling during bus width conversions
   -----------------------------------------------------------------------------

  process (usrclk2)
  begin
    if usrclk2'event and usrclk2= '1' then
      if txreset = '1' then
        toggle      <= '0';
      else
        toggle      <= not toggle;
      end if;
    end if;
  end process;


   -----------------------------------------------------------------------------
   -- The core works from a 125MHz clock source, the GT transceiver fabric
   -- interface works from a 62.5MHz clock source.  The following signals
   -- sourced by the core therefore need to be converted to double width, then
   -- resampled on the GT's 62.5MHz clock
   -----------------------------------------------------------------------------

  -- Reclock the transmitter signals
  process (usrclk2)
  begin
    if usrclk2'event and usrclk2= '1' then
      if txreset = '1' then
        txdata_reg         <= X"00";
        txchardispmode_reg <= '0';
        txchardispval_reg  <= '0';
        txcharisk_reg      <= '0';
        txpowerdown_reg    <= '0';
      else
        txdata_reg         <= txdata;
        txchardispmode_reg <= txchardispmode;
        txchardispval_reg  <= txchardispval;
        txcharisk_reg      <= txcharisk;
        txpowerdown_reg    <= powerdown;
      end if;
    end if;
  end process;


  -- Double the data width
  process (usrclk2)
  begin
    if usrclk2'event and usrclk2= '1' then
      if txreset = '1' then
        txdata_double                <= X"0000";
        txchardispmode_double        <= "00";
        txchardispval_double         <= "00";
        txcharisk_double             <= "00";
        txpowerdown_double           <= '0';
      else
        if toggle = '0' then
          txdata_double(7 downto 0)  <= txdata_reg;
          txchardispmode_double(0)   <= txchardispmode_reg;
          txchardispval_double(0)    <= txchardispval_reg;
          txcharisk_double(0)        <= txcharisk_reg;
          txdata_double(15 downto 8) <= txdata;
          txchardispmode_double(1)   <= txchardispmode;
          txchardispval_double(1)    <= txchardispval;
          txcharisk_double(1)        <= txcharisk;
        end if;
        txpowerdown_double           <= txpowerdown_reg;
      end if;
    end if;
  end process;


  -- Cross the clock domain.  Both clock domains are frequency related and are
  -- derived from the same MMCM: the Xilinx tools will accont for this
  process (usrclk)
  begin
    if usrclk'event and usrclk= '1' then
      txdata_int         <= txdata_double;
      txchardispmode_int <= txchardispmode_double;
      txchardispval_int  <= txchardispval_double;
      txcharisk_int      <= txcharisk_double;
      txbufstatus_reg    <= txbufstatus;
      txpowerdown        <= txpowerdown_double;
    end if;
  end process;



   -----------------------------------------------------------------------------
   -- The core works from a 125MHz clock source, the GT transceiver fabric
   -- interface works from a 62.5MHz clock source.  The following signals
   -- sourced by the GT transceiver therefore need to converted to half width
   -----------------------------------------------------------------------------

  -- Sample the double width received data from the GT transsciever on the GT's
  -- 62.5MHz clock
  process (usrclk)
  begin
    if usrclk'event and usrclk= '1' then
      rxchariscomma_reg  <= rxchariscomma_int;
      rxcharisk_reg      <= rxcharisk_int;
      rxdata_reg         <= rxdata_int;
      rxdisperr_reg      <= rxdisperr_int;
      rxnotintable_reg   <= rxnotintable_int;
      rxrundisp_reg      <= rxrundisp_int;
      rxbufstatus_reg    <= rxbufstatus;
      rxpowerdown        <= rxpowerdown_double;
    end if;
  end process;


  -- Reclock the double width received data from the GT transsciever onto the
  -- 125MHz clock source.   Both clock domains are frequency related and are
  -- derived from the same MMCM: the Xilinx tools will accont for this.

  process (usrclk2)
  begin
    if usrclk2'event and usrclk2= '1' then
      if rxreset = '1' then
        rxchariscomma_double  <= "00";
        rxcharisk_double      <= "00";
        rxdata_double         <= X"0000";
        rxdisperr_double      <= "00";
        rxnotintable_double   <= "00";
        rxrundisp_double      <= "00";
        rxpowerdown_double    <= '0';
      elsif toggle = '1' then
        rxchariscomma_double  <= rxchariscomma_reg;
        rxcharisk_double      <= rxcharisk_reg;
        rxdata_double         <= rxdata_reg;
        rxdisperr_double      <= rxdisperr_reg;
        rxnotintable_double   <= rxnotintable_reg;
        rxrundisp_double      <= rxrundisp_reg;
        rxpowerdown_double    <= rxpowerdown_reg;
      end if;
    end if;
  end process;


  -- Halve the bus width
  process (usrclk2)
  begin
    if usrclk2'event and usrclk2= '1' then
      if rxreset = '1' then
        rxchariscomma    <= '0';
        rxcharisk        <= '0';
        rxdata           <= X"00";
        rxdisperr        <= '0';
        rxnotintable     <= '0';
        rxrundisp        <= '0';
        rxpowerdown_reg  <= '0';
      else
        if toggle = '0' then
          rxchariscomma  <= rxchariscomma_double(0);
          rxcharisk      <= rxcharisk_double(0);
          rxdata         <= rxdata_double(7 downto 0);
          rxdisperr      <= rxdisperr_double(0);
          rxnotintable   <= rxnotintable_double(0);
          rxrundisp      <= rxrundisp_double(0);
        else
          rxchariscomma  <= rxchariscomma_double(1);
          rxcharisk      <= rxcharisk_double(1);
          rxdata         <= rxdata_double(15 downto 8);
          rxdisperr      <= rxdisperr_double(1);
          rxnotintable   <= rxnotintable_double(1);
          rxrundisp      <= rxrundisp_double(1);
        end if;
        rxpowerdown_reg  <= powerdown;
      end if;
    end if;
  end process;

   -----------------------------------------------------------------------------
   -- Instantiate the Series-7 GT transceiver
   -----------------------------------------------------------------------------

   -- Direct from the Transceiver Wizard output
    gtwizard_inst : gtwizard_v2_3_gbe_init
    generic map (
        EXAMPLE_SIM_GTRESET_SPEEDUP      =>     "TRUE"
    )
    port map (
   SYSCLK_IN                           => independent_clock,  --  : in   std_logic;
    SOFT_RESET_IN                       => pmareset,  --  : in   std_logic;
    GT0_TX_FSM_RESET_DONE_OUT           => open,  --  : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT           => open,  --  : out  std_logic;
    GT0_DATA_VALID_IN                   => data_valid_reg2,
        ------------------------- Channel - Ref Clock Ports --------------------
        GT0_GTREFCLK0_IN                =>      gtrefclk,
        -------------------------------- Channel PLL ---------------------------
        GT0_CPLLFBCLKLOST_OUT           =>      open,
        GT0_CPLLLOCK_OUT                =>      cplllock,
        GT0_CPLLLOCKDETCLK_IN           =>      independent_clock,
        --GT0_CPLLREFCLKLOST_OUT          =>      open,
        GT0_CPLLRESET_IN                =>      pmareset,
        ------------------------------- Eye Scan Ports -------------------------
        GT0_EYESCANDATAERROR_OUT        =>      open,
        ------------------------ Loopback and Powerdown Ports ------------------
        GT0_LOOPBACK_IN                 =>      "000",
        GT0_RXPD_IN                     =>      rxpowerdown_int,
        GT0_TXPD_IN                     =>      txpowerdown_int,
        ------------------------------- Receive Ports --------------------------
        GT0_RXUSERRDY_IN                =>      mmcm_locked,
        ----------------------- Receive Ports - 8b10b Decoder ------------------
        GT0_RXCHARISCOMMA_OUT           =>      rxchariscomma_int,
        GT0_RXCHARISK_OUT               =>      rxcharisk_int,
        GT0_RXDISPERR_OUT               =>      rxdisperr_int,
        GT0_RXNOTINTABLE_OUT            =>      rxnotintable_int,
        ------------------- Receive Ports - Clock Correction Ports -------------
        GT0_RXCLKCORCNT_OUT             =>      rxclkcorcnt_int,
        --------------- Receive Ports - Comma Detection and Alignment ----------
        GT0_RXMCOMMAALIGNEN_IN          =>      encommaalign_int,
        GT0_RXPCOMMAALIGNEN_IN          =>      encommaalign_int,
        ------------------- Receive Ports - RX Data Path interface -------------
        GT0_GTRXRESET_IN                =>      gt_reset_rx,
--        GT0_GTRXRESET_IN                =>      rxreset_int,
        GT0_RXDATA_OUT                  =>      rxdata_int,
        GT0_RXOUTCLK_OUT                =>      open,
        ----GT0_RXPCSRESET_IN               =>      pcsreset,
        GT0_RXUSRCLK_IN                 =>      usrclk,
        GT0_RXUSRCLK2_IN                =>      usrclk,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR --
        GT0_GTXRXN_IN                   =>      rxn,
        GT0_GTXRXP_IN                   =>      rxp,
        GT0_RXCDRLOCK_OUT               =>      open,
        GT0_RXELECIDLE_OUT              =>      rxelecidle,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports ---
        GT0_RXBUFRESET_IN               =>      rxreset_int,
        GT0_RXBUFSTATUS_OUT             =>      rxbufstatus,
        ------------------------ Receive Ports - RX PLL Ports ------------------
        GT0_RXRESETDONE_OUT             =>      resetdone_rx,
        ------------------------------- Transmit Ports -------------------------
        GT0_TXUSERRDY_IN                =>      mmcm_locked,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports ----------
        GT0_TXCHARDISPMODE_IN           =>      txchardispmode_int,
        GT0_TXCHARDISPVAL_IN            =>      txchardispval_int,
        GT0_TXCHARISK_IN                =>      txcharisk_int,
        ------------------ Transmit Ports - TX Data Path interface -------------
        GT0_GTTXRESET_IN                =>      gt_reset_tx,
--        GT0_GTTXRESET_IN                =>      txreset_int,
        GT0_TXDATA_IN                   =>      txdata_int,
        GT0_TXOUTCLK_OUT                =>      txoutclk,
        GT0_TXOUTCLKFABRIC_OUT          =>      open,
        GT0_TXOUTCLKPCS_OUT             =>      open,
        --GT0_TXPCSRESET_IN               =>      pcsreset,
        GT0_TXUSRCLK_IN                 =>      usrclk,
        GT0_TXUSRCLK2_IN                =>      usrclk,
        ---------------- Transmit Ports - TX Driver and OOB signaling ----------
        GT0_GTXTXN_OUT                  =>      txn,
        GT0_GTXTXP_OUT                  =>      txp,
        ----------- Transmit Ports - TX Elastic Buffer and Phase Alignment -----
        GT0_TXBUFSTATUS_OUT             =>      txbufstatus,
        ----------------------- Transmit Ports - TX PLL Ports ------------------
        GT0_TXRESETDONE_OUT             =>      resetdone_tx,
        ----------------- Transmit Ports - TX Ports for PCI Express ------------
--GT0_TXELECIDLE_IN               =>      txpowerdown
			GT0_GTREFCLK0_COMMON_IN => gtrefclk,
			------------------------- Common Block - QPLL Ports ------------------------
			GT0_QPLLLOCK_OUT => open,
			GT0_QPLLLOCKDETCLK_IN => independent_clock,
			GT0_QPLLRESET_IN => '0'
    );


   -- Hold the transmitter and receiver paths of the GT transceiver in reset
   -- until the PLL has locked.
   gt_reset_rx <= (rxreset_int and resetdone_rx);
   gt_reset_tx <= (txreset_int and resetdone_tx);

   -- Output the PLL locked status
   plllkdet <= cplllock;


   -- Report overall status for both transmitter and receiver reset done signals
   resetdone <= cplllock ;

   -- reset to PCS part of GT
   pcsreset <= not mmcm_locked;

   -- temporary
   rxrundisp_int <= "00";


   -- Decode the GT transceiver buffer status signals
   process (usrclk2)
   begin
     if usrclk2'event and usrclk2= '1' then
       rxbuferr    <= rxbufstatus_reg(2);
       txbuferr    <= txbufstatus_reg(1);
       rxclkcorcnt <= '0' & rxclkcorcnt_int;
     end if;
   end process;
  -----------------------------------------------------------------------------
   -- The core works from a 125MHz clock source userclk2, the init statemachines 
   -- work at 200 MHz. 
   -----------------------------------------------------------------------------

   -- Cross the clock domain
   process (usrclk2)
   begin
      if usrclk2'event and usrclk2= '1' then
          data_valid_reg    <= data_valid;
      end if;
   end process;


   sync_block_data_valid : gig_eth_pcs_pma_v11_4_sync_block
   port map
          (
             clk             =>  independent_clock,
             data_in         =>  data_valid_reg,
             data_out        =>  data_valid_reg2
          );




end wrapper;
