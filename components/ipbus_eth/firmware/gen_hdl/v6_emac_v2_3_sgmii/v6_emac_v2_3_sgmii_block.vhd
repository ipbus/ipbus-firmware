--------------------------------------------------------------------------------
-- Project    : Xilinx LogiCORE Virtex-6 Embedded Tri-Mode Ethernet MAC
-- File       : v6_emac_v2_3_sgmii_block.vhd
-- Version    : 2.3
-------------------------------------------------------------------------------
--
-- (c) Copyright 2004-2011 Xilinx, Inc. All rights reserved.
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
-- Description: This is the block level Verilog design for the Virtex-6
--              Embedded Tri-Mode Ethernet MAC Example Design.
--
--              This block level:
--
--              Please refer to the Datasheet, Getting Started Guide, and
--              the Virtex-6 Embedded Tri-Mode Ethernet MAC User Gude for further information.
--
--
--              -----------------------------------------|
--              | BLOCK LEVEL WRAPPER                    |
--              |                                        |
--              |    ---------------------               |
--              |    | V6 MAC            |               |
--              |    | CORE              |               |
--              |    |                   |               |
--            --|--->| Tx            Tx  |-------------->|
--              |    | AXI           PHY |               |
--              |    | I/F           I/F |               |
--              |    |                   |               |
--              |    |                   |               |
--              |    |                   |               |
--              |    | Rx            Rx  |               |
--              |    | AXI           PHY |               |
--            <-|----| I/F           I/F |<--------------|
--              |    |                   |               |
--              |    ---------------------               |
--              |                                        |
--              -----------------------------------------|
--
library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;


--------------------------------------------------------------------------------
-- The entity declaration for the block level example design.
--------------------------------------------------------------------------------

entity v6_emac_v2_3_sgmii_block is
   port(
      gtx_clk                       : in std_logic;
      clk125_out                    : out std_logic;

      -- Receiver Interface
      ----------------------------
      rx_statistics_vector          : out std_logic_vector(27 downto 0);
      rx_statistics_valid           : out std_logic;

      user_mac_aclk                 : out std_logic;
      rx_reset                      : out std_logic;
      rx_axis_mac_tdata             : out std_logic_vector(7 downto 0);
      rx_axis_mac_tvalid            : out std_logic;
      rx_axis_mac_tlast             : out std_logic;
      rx_axis_mac_tuser             : out std_logic;

      -- Transmitter Interface
      -------------------------------
      tx_ifg_delay                  : in std_logic_vector(7 downto 0);
      tx_statistics_vector          : out std_logic_vector(31 downto 0);
      tx_statistics_valid           : out std_logic;

      tx_reset                      : out std_logic;
      tx_axis_mac_tdata             : in std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid            : in std_logic;
      tx_axis_mac_tlast             : in std_logic;
      tx_axis_mac_tuser             : in std_logic;
      tx_axis_mac_tready            : out std_logic;
      tx_collision                  : out std_logic;
      tx_retransmit                 : out std_logic;

      -- MAC Control Interface
      ------------------------
      pause_req                     : in std_logic;
      pause_val                     : in std_logic_vector(15 downto 0);

    -- SGMII interface
      txp                           : out std_logic;
      txn                           : out std_logic;
      rxp                           : in std_logic;
      rxn                           : in std_logic;
      phyad                         : in std_logic_vector(4 downto 0);
      resetdone                     : out std_logic;
      syncacqstatus                 : out std_logic;
    -- SGMII transceiver clock buffer input
      clk_ds                        : in std_logic;


      -- MDIO Interface
      -----------------
      mdio_i                        : in std_logic;
      mdio_o                        : out std_logic;
      mdio_t                        : out std_logic;
      mdc_in                        : in std_logic;

      -- asynchronous reset
      -----------------
      glbl_rstn                     : in std_logic;
      rx_axi_rstn                   : in std_logic;
      tx_axi_rstn                   : in std_logic

      );
end v6_emac_v2_3_sgmii_block;

architecture TOP_LEVEL of v6_emac_v2_3_sgmii_block is

-------------------------------------------------------------------------------
-- Component declarations for lower hierarchial level entities
-------------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Component Declaration for V6 Hard EMAC Core.
   -----------------------------------------------------------------------------
   component v6_emac_v2_3_sgmii
    port(
      -- Clock signals
      ----------------------------
      gtx_clk                     : in  std_logic;
      tx_axi_clk_out              : out std_logic;

      -- Receiver Interface
      ----------------------------
      rx_axi_clk                  : in  std_logic;
      rx_reset_out                : out std_logic;
      rx_axis_mac_tdata           : out std_logic_vector(7 downto 0);
      rx_axis_mac_tvalid          : out std_logic;
      rx_axis_mac_tlast           : out std_logic;
      rx_axis_mac_tuser           : out std_logic;

      rx_statistics_vector        : out std_logic_vector(27 downto 0);
      rx_statistics_valid         : out std_logic;

      -- Transmitter Interface
      -------------------------------
      tx_axi_clk                  : in  std_logic;
      tx_reset_out                : out std_logic;
      tx_axis_mac_tdata           : in std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid          : in  std_logic;
      tx_axis_mac_tlast           : in  std_logic;
      tx_axis_mac_tuser           : in  std_logic;
      tx_axis_mac_tready          : out std_logic;

      tx_retransmit               : out std_logic;
      tx_collision                : out std_logic;
      tx_ifg_delay                : in  std_logic_vector(7 downto 0);
      tx_statistics_vector        : out std_logic_vector(31 downto 0);
      tx_statistics_valid         : out std_logic;

      -- MAC Control Interface
      ------------------------
      pause_req                   : in  std_logic;
      pause_val                   : in  std_logic_vector(15 downto 0);

      -- Current Speed Indication
      ---------------------------
      speed_is_10_100             : out std_logic;

      -- Physical Interface of the core
      --------------------------------
      gmii_txd                    : out std_logic_vector(7 downto 0);
      gmii_rxd                    : in  std_logic_vector(7 downto 0);
      gmii_rx_dv                  : in  std_logic;

      -- SGMII interface
      --------------------------------
      dcm_locked                  : in  std_logic;
      an_interrupt                : out std_logic;
      signal_det                  : in  std_logic;
      phy_ad                      : in  std_logic_vector(4 downto 0);
      en_comma_align              : out std_logic;
      loopback_msb                : out std_logic;
      mgt_rx_reset                : out std_logic;
      mgt_tx_reset                : out std_logic;
      powerdown                   : out std_logic;
      sync_acq_status             : out std_logic;
      rx_clk_cor_cnt              : in  std_logic_vector(2 downto 0);
      rx_buf_status               : in  std_logic;
      rx_char_is_comma            : in  std_logic;
      rx_char_is_k                : in  std_logic;
      rx_disp_err                 : in  std_logic;
      rx_not_in_table             : in  std_logic;
      rx_run_disp                 : in  std_logic;
      tx_buf_err                  : in  std_logic;
      tx_char_disp_mode           : out std_logic;
      tx_char_disp_val            : out std_logic;
      tx_char_is_k                : out std_logic;

      -- MDIO Interface
      -----------------
      mdc_in                      : in  std_logic;
      mdio_in                     : in  std_logic;
      mdio_out                    : out std_logic;
      mdio_tri                    : out std_logic;


      glbl_rstn                   : in  std_logic;
      rx_axi_rstn                 : in  std_logic;
      tx_axi_rstn                 : in  std_logic

   );
   end component;


  -- Component declaration for the GTX wrapper
  component v6_gtxwizard_top
    port (
      RESETDONE      : out   std_logic;
      ENMCOMMAALIGN  : in    std_logic;
      ENPCOMMAALIGN  : in    std_logic;
      LOOPBACK       : in    std_logic;
      POWERDOWN      : in    std_logic;
      RXUSRCLK2      : in    std_logic;
      RXRESET        : in    std_logic;
      TXCHARDISPMODE : in    std_logic;
      TXCHARDISPVAL  : in    std_logic;
      TXCHARISK      : in    std_logic;
      TXDATA         : in    std_logic_vector (7 downto 0);
      TXUSRCLK2      : in    std_logic;
      TXRESET        : in    std_logic;
      RXCHARISCOMMA  : out   std_logic;
      RXCHARISK      : out   std_logic;
      RXCLKCORCNT    : out   std_logic_vector (2 downto 0);
      RXDATA         : out   std_logic_vector (7 downto 0);
      RXDISPERR      : out   std_logic;
      RXNOTINTABLE   : out   std_logic;
      RXRUNDISP      : out   std_logic;
      RXBUFERR       : out   std_logic;
      TXBUFERR       : out   std_logic;
      PLLLKDET       : out   std_logic;
      TXOUTCLK       : out   std_logic;
      RXELECIDLE     : out   std_logic;
      TXN            : out   std_logic;
      TXP            : out   std_logic;
      RXN            : in    std_logic;
      RXP            : in    std_logic;
      CLK_DS         : in    std_logic;
      PMARESET       : in    std_logic
    );
  end component;

  ------------------------------------------------------------------------------
  -- Component declaration for the synchronisation flip-flop pair
  ------------------------------------------------------------------------------
  component sync_block
  port (
    clk                    : in  std_logic;    -- clock to be sync'ed to
    data_in                : in  std_logic;    -- Data to be 'synced'
    data_out               : out std_logic     -- synced data
    );
  end component;


  ------------------------------------------------------------------------------
  -- Component declaration for the reset synchroniser
  ------------------------------------------------------------------------------
  component reset_sync
  port (
    reset_in               : in  std_logic;    -- Active high asynchronous reset
    enable                 : in  std_logic;
    clk                    : in  std_logic;    -- clock to be sync'ed to
    reset_out              : out std_logic     -- "Synchronised" reset signal
    );
  end component;


  ------------------------------------------------------------------------------
  -- internal signals used in this block level wrapper.
  ------------------------------------------------------------------------------

   signal gmii_txd_int                    : std_logic_vector(7 downto 0); -- Internal gmii_txd signal.
   signal gmii_rx_dv_int                  : std_logic;                    -- gmii_rx_dv registered in IOBs.
   signal gmii_rxd_int                    : std_logic_vector(7 downto 0); -- gmii_rxd registered in IOBs.


   -- Physical interface signals
   signal plllock_i                       : std_logic;
   signal emac_locked_i                   : std_logic;
   signal mgt_rx_data_i                   : std_logic_vector(7 downto 0);
   signal signal_detect_i                 : std_logic;
   signal rxelecidle_i                    : std_logic;
   signal resetdone_i                     : std_logic;
   signal encommaalign_i                  : std_logic;
   signal loopback_i                      : std_logic;
   signal mgt_rx_reset_i                  : std_logic;
   signal mgt_tx_reset_i                  : std_logic;
   signal powerdown_i                     : std_logic;
   signal rxclkcorcnt_i                   : std_logic_vector(2 downto 0);
   signal rxchariscomma_i                 : std_logic;
   signal rxcharisk_i                     : std_logic;
   signal rxdisperr_i                     : std_logic;
   signal rxnotintable_i                  : std_logic;
   signal rxrundisp_i                     : std_logic;
   signal txbuferr_i                      : std_logic;
   signal txchardispmode_i                : std_logic;
   signal txchardispval_i                 : std_logic;
   signal txcharisk_i                     : std_logic;
   signal rxbufstatus_i                   : std_logic;
   
   signal rxchariscomma_r                 : std_logic;
   signal rxcharisk_r                     : std_logic;
   signal rxclkcorcnt_r                   : std_logic_vector(2 downto 0);
   signal rxdisperr_r                     : std_logic;
   signal rxnotintable_r                  : std_logic;
   signal rxrundisp_r                     : std_logic;
   signal txchardispmode_r                : std_logic;
   signal txchardispval_r                 : std_logic;
   signal txcharisk_r                     : std_logic;
   signal mgt_tx_data_r                   : std_logic_vector(7 downto 0);

   signal speedis10100_int                : std_logic;                    -- Asserted when speed is 10Mb/s or 100Mb/s.

   signal tx_axi_clk_out                  : std_logic;
   signal rx_mac_aclk_int                 : std_logic;                    -- Internal receive gmii/mii clock signal.
   signal tx_mac_aclk_int                 : std_logic;                    -- Internal transmit gmii/mii clock signal.

   signal glbl_rst                        : std_logic;
   signal gtx_reset_in                    : std_logic;
   signal gtx_clk_reset_int               : std_logic;
   signal gtx_pre_resetn                  : std_logic := '0';
   signal gtx_reset                       : std_logic := '1';
   signal gtx_resetn                      : std_logic := '0';
   signal tx_reset_int                    : std_logic;                    -- Synchronous reset in the MAC and gmii Tx domain
   signal rx_reset_int                    : std_logic;                    -- Synchronous reset in the MAC and gmii Rx domain

   signal rx_statistics_vector_int        : std_logic_vector(27 downto 0);
   signal rx_statistics_valid_int         : std_logic;
   signal tx_statistics_vector_int        : std_logic_vector(31 downto 0);
   signal tx_statistics_valid_int         : std_logic;
-------------------------------------------------------------------------------
-- Attribute declarations
-------------------------------------------------------------------------------
  attribute keep : string;
  attribute keep of tx_mac_aclk_int     : signal is "true";
  attribute keep of rx_mac_aclk_int     : signal is "true";
  attribute keep of gmii_rxd_int        : signal is "true";
  attribute keep of rxchariscomma_r     : signal is "true";
  attribute keep of rxcharisk_r         : signal is "true";
  attribute keep of rxclkcorcnt_r       : signal is "true";
  attribute keep of rxdisperr_r         : signal is "true";
  attribute keep of rxnotintable_r      : signal is "true";
  attribute keep of rxrundisp_r         : signal is "true";

  attribute ASYNC_REG                   : string;
  attribute ASYNC_REG of gtx_pre_resetn : signal is "TRUE";
  attribute ASYNC_REG of gtx_resetn     : signal is "TRUE";
  attribute keep      of gtx_resetn     : signal is "TRUE";

-------------------------------------------------------------------------------
-- Main body of code
-------------------------------------------------------------------------------

begin

   glbl_rst <= not glbl_rstn;
   gtx_reset_in <= glbl_rst;

   gtx_reset_gen : reset_sync
   port map (
      clk              => gtx_clk,
      enable           => plllock_i,
      reset_in         => gtx_reset_in,
      reset_out        => gtx_clk_reset_int
   );

   -- Create fully synchronous reset in the gtx_clk domain.
   process (gtx_clk)
   begin
      if gtx_clk'event and gtx_clk = '1' then
         if gtx_clk_reset_int = '1' then
           gtx_pre_resetn  <= '0';
           gtx_resetn      <= '0';
         else
           gtx_pre_resetn  <= '1';
           gtx_resetn      <= gtx_pre_resetn;
         end if;
      end if;
   end process;

   gtx_reset <= not gtx_resetn;

   -- assign outputs
   rx_reset <= rx_reset_int;
   tx_reset <= tx_reset_int;
   -- Assign the internal clock signals to output ports.
   user_mac_aclk   <= tx_mac_aclk_int;
   rx_mac_aclk_int <= tx_mac_aclk_int;

-- DMN CHANGE

   -----------------------------------------------------------------------------
   -- Instantiate a BUFG for tx phy and user side logic
   -----------------------------------------------------------------------------

--    bufg_tx_axi_clk : BUFG
--    port map (
--      I                => tx_axi_clk_out,
--      O                => tx_mac_aclk_int
--   );

		tx_mac_aclk_int <= gtx_clk;

    ---------------------------------------------------------------------------
    -- Instantiate GTX for SGMII or 1000BASE-X PCS/PMA physical interface
    ---------------------------------------------------------------------------
    v6_gtxwizard_top_inst : v6_gtxwizard_top
      PORT MAP (
         RESETDONE      => resetdone_i,
         ENMCOMMAALIGN  => encommaalign_i,
         ENPCOMMAALIGN  => encommaalign_i,
         LOOPBACK       => loopback_i,
         POWERDOWN      => powerdown_i,
         RXUSRCLK2      => gtx_clk,
         RXRESET        => mgt_rx_reset_i,
         TXCHARDISPMODE => txchardispmode_r,
         TXCHARDISPVAL  => txchardispval_r,
         TXCHARISK      => txcharisk_r,
         TXDATA         => mgt_tx_data_r,
         TXUSRCLK2      => gtx_clk,
         TXRESET        => mgt_tx_reset_i,
         RXCHARISCOMMA  => rxchariscomma_i,
         RXCHARISK      => rxcharisk_i,
         RXCLKCORCNT    => rxclkcorcnt_i,
         RXDATA         => mgt_rx_data_i,
         RXDISPERR      => rxdisperr_i,
         RXNOTINTABLE   => rxnotintable_i,
         RXRUNDISP      => rxrundisp_i,
         RXBUFERR       => rxbufstatus_i,
         TXBUFERR       => txbuferr_i,
         PLLLKDET       => plllock_i,
         TXOUTCLK       => clk125_out,
         RXELECIDLE     => rxelecidle_i,
         TXN            => txn,
         TXP            => txp,
         RXN            => rxn,
         RXP            => rxp,
         CLK_DS         => clk_ds,
         PMARESET       => glbl_rst
    );

    resetdone <= resetdone_i;

    -- Detect when there has been a disconnect
    signal_detect_i <= not rxelecidle_i;

    -- PLL lock
    emac_locked_i <= plllock_i;

   --------------------------------------------------------------------------
   -- Register the signals between EMAC and transceiver for timing purposes
   --------------------------------------------------------------------------
   regrx : process (gtx_clk)
   begin
      if gtx_clk'event and gtx_clk = '1' then
         if gtx_reset = '1' then
            rxchariscomma_r  <= '0';
            rxcharisk_r      <= '0';
            rxclkcorcnt_r    <= (others => '0');
            gmii_rxd_int     <= (others => '0');
            gmii_rx_dv_int   <= '0';
            rxdisperr_r      <= '0';
            rxnotintable_r   <= '0';
            rxrundisp_r      <= '0';
            txchardispmode_r <= '0';
            txchardispval_r  <= '0';
            txcharisk_r      <= '0';
            mgt_tx_data_r    <= (others => '0');
         else
            rxchariscomma_r  <= rxchariscomma_i;
            rxcharisk_r      <= rxcharisk_i;
            rxclkcorcnt_r    <= rxclkcorcnt_i;
            gmii_rxd_int     <= mgt_rx_data_i;
            gmii_rx_dv_int   <= '0'; -- RXREALIGN
            rxdisperr_r      <= rxdisperr_i;
            rxnotintable_r   <= rxnotintable_i;
            rxrundisp_r      <= rxrundisp_i;
            txchardispmode_r <= txchardispmode_i;
            txchardispval_r  <= txchardispval_i;
            txcharisk_r      <= txcharisk_i;
            mgt_tx_data_r    <= gmii_txd_int;
         end if;
      end if;
   end process regrx;


   rx_statistics_vector <= rx_statistics_vector_int;
   rx_statistics_valid  <= rx_statistics_valid_int;
   tx_statistics_vector <= tx_statistics_vector_int;
   tx_statistics_valid  <= tx_statistics_valid_int;

   -----------------------------------------------------------------------------
   -- Instantiate the V6 Hard Mac core
   -----------------------------------------------------------------------------
    v6emac_core : v6_emac_v2_3_sgmii
    port map (

      ---------------------------------------------------------------------------
      -- Clock signals - used in rgmii and serial modes
      ---------------------------------------------------------------------------
      gtx_clk                => gtx_clk,
      tx_axi_clk_out         => tx_axi_clk_out, -- only in rgmii or sgmii

      ---------------------------------------------------------------------------
      -- Receiver Interface.
      ---------------------------------------------------------------------------
      rx_axi_clk             => rx_mac_aclk_int,
      rx_reset_out           => rx_reset_int,
      rx_axis_mac_tdata      => rx_axis_mac_tdata,
      rx_axis_mac_tvalid     => rx_axis_mac_tvalid,
      rx_axis_mac_tlast      => rx_axis_mac_tlast,
      rx_axis_mac_tuser      => rx_axis_mac_tuser,

      -- RX sideband signals
      rx_statistics_vector   => rx_statistics_vector_int,
      rx_statistics_valid    => rx_statistics_valid_int,

      ---------------------------------------------------------------------------
      -- Transmitter Interface
      ---------------------------------------------------------------------------
      tx_axi_clk             => tx_mac_aclk_int,
      tx_reset_out           => tx_reset_int,
      tx_axis_mac_tdata      => tx_axis_mac_tdata,
      tx_axis_mac_tvalid     => tx_axis_mac_tvalid,
      tx_axis_mac_tlast      => tx_axis_mac_tlast,
      tx_axis_mac_tuser      => tx_axis_mac_tuser,
      tx_axis_mac_tready     => tx_axis_mac_tready,

      -- TX sideband signals
      tx_retransmit          => tx_retransmit,
      tx_collision           => tx_collision,
      tx_ifg_delay           => tx_ifg_delay,
      tx_statistics_vector   => tx_statistics_vector_int,
      tx_statistics_valid    => tx_statistics_valid_int,

      ---------------------------------------------------------------------------
      -- Flow Control
      ---------------------------------------------------------------------------
      pause_req              => pause_req,
      pause_val              => pause_val,

      ---------------------------------------------------------------------------
      -- Speed interface
      ---------------------------------------------------------------------------
      speed_is_10_100        => speedis10100_int,

      ---------------------------------------------------------------------------
      -- GMII/MII Interface
      ---------------------------------------------------------------------------
      gmii_txd               => gmii_txd_int,
      gmii_rxd               => gmii_rxd_int,
      gmii_rx_dv             => gmii_rx_dv_int,

      ---------------------------------------------------------------------------
      -- SGMII interface
      ---------------------------------------------------------------------------
      dcm_locked             => emac_locked_i,
      an_interrupt           => open,
      signal_det             => signal_detect_i,
      phy_ad                 => phyad,
      en_comma_align         => encommaalign_i,
      loopback_msb           => loopback_i,
      mgt_rx_reset           => mgt_rx_reset_i,
      mgt_tx_reset           => mgt_tx_reset_i,
      powerdown              => powerdown_i,
      sync_acq_status        => syncacqstatus,
      rx_clk_cor_cnt         => rxclkcorcnt_r,
      rx_buf_status          => rxbufstatus_i,
      rx_char_is_comma       => rxchariscomma_r,
      rx_char_is_k           => rxcharisk_r,
      rx_disp_err            => rxdisperr_r,
      rx_not_in_table        => rxnotintable_r,
      rx_run_disp            => rxrundisp_r,
      tx_buf_err             => txbuferr_i,
      tx_char_disp_mode      => txchardispmode_i,
      tx_char_disp_val       => txchardispval_i,
      tx_char_is_k           => txcharisk_i,
      ---------------------------------------------------------------------------
      -- MDIO Interface
      ---------------------------------------------------------------------------
      mdc_in                 => mdc_in,
      mdio_in                => mdio_i,
      mdio_out               => mdio_o,
      mdio_tri               => mdio_t,



      ---------------------------------------------------------------------------
      -- Resets
      ---------------------------------------------------------------------------

      glbl_rstn              => gtx_resetn,
      rx_axi_rstn            => rx_axi_rstn,
      tx_axi_rstn            => tx_axi_rstn

   );

end TOP_LEVEL;
