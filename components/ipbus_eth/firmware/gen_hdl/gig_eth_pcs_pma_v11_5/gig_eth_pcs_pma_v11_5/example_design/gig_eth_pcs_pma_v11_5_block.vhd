--------------------------------------------------------------------------------
-- File       : gig_eth_pcs_pma_v11_5_block.vhd
-- Author     : Xilinx Inc.
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
-- Description: This Core Block Level wrapper connects the core to a
--              Series-7 Transceiver.
--
--
--   ------------------------------------------------------------
--   |                      Core Block wrapper                  |
--   |                                                          |
--   |        ------------------          -----------------     |
--   |        |      Core      |          | Transceiver   |     |
--   |        |                |          |               |     |
--   |        |                |          |               |     |
--   |        |                |          |               |     |
-- ---------->| GMII           |--------->|           TXP |-------->
--   |        | Tx             |          |           TXN |     |
--   |        |                |          |               |     |
--   |        |                |          |               |     |
--   |        |                |          |               |     |
--   |        |                |          |               |     |
--   |        |                |          |               |     |
--   |        | GMII           |          |           RXP |     |
-- <----------| Rx             |<---------|           RXN |<--------
--   |        |                |          |               |     |
--   |        ------------------          -----------------     |
--   |                                                          |
--   ------------------------------------------------------------
--
--


library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;


--------------------------------------------------------------------------------
-- The entity declaration for the Core Block wrapper.
--------------------------------------------------------------------------------

entity gig_eth_pcs_pma_v11_5_block is
generic
(
    EXAMPLE_SIMULATION                      : integer   := 0          -- Set to 1 for simulation
);
      port(
      -- Transceiver Interface
      ---------------------
      drpaddr_in           : in   std_logic_vector(8 downto 0);
      drpclk_in            : in   std_logic;
      drpdi_in             : in   std_logic_vector(15 downto 0);
      drpdo_out            : out  std_logic_vector(15 downto 0);
      drpen_in             : in   std_logic;
      drprdy_out           : out  std_logic;
      drpwe_in             : in   std_logic;
 
      gtrefclk             : in std_logic;                     -- Very high quality 125MHz clock for GT transceiver.
      txp                  : out std_logic;                    -- Differential +ve of serial transmission from PMA to PMD.
      txn                  : out std_logic;                    -- Differential -ve of serial transmission from PMA to PMD.
      rxp                  : in std_logic;                     -- Differential +ve for serial reception from PMD to PMA.
      rxn                  : in std_logic;                     -- Differential -ve for serial reception from PMD to PMA.

      txoutclk             : out std_logic;                    -- txoutclk from GT transceiver (62.5MHz)
      resetdone            : out std_logic;                    -- The GT transceiver has completed its reset cycle
      mmcm_locked          : in std_logic;                     -- Locked indication from MMCM
      userclk              : in std_logic;                     -- 62.5MHz global clock.
      userclk2             : in std_logic;                     -- 125MHz global clock.
      independent_clock_bufg : in std_logic;                   -- 200MHz independent cloc,
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
end gig_eth_pcs_pma_v11_5_block;


architecture block_level of gig_eth_pcs_pma_v11_5_block is



   -----------------------------------------------------------------------------
   -- Component Declaration for the Transceiver wrapper
   -----------------------------------------------------------------------------

   component gig_eth_pcs_pma_v11_5_transceiver
generic
(
    EXAMPLE_SIMULATION                      : integer   := 0          -- Set to 1 for simulation
);
   port (
      drpaddr_in          : in   std_logic_vector(8 downto 0);
      drpclk_in           : in   std_logic;
      drpdi_in            : in   std_logic_vector(15 downto 0);
      drpdo_out           : out  std_logic_vector(15 downto 0);
      drpen_in            : in   std_logic;
      drprdy_out          : out  std_logic;
      drpwe_in            : in   std_logic;
      encommaalign        : in    std_logic;
      loopback            : in    std_logic;
      powerdown           : in    std_logic;
      usrclk              : in    std_logic;
      usrclk2             : in    std_logic;
      data_valid          : in  std_logic;
      independent_clock   : in  std_logic;
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
      txn                 : out   std_logic;
      txp                 : out   std_logic;
      rxn                 : in    std_logic;
      rxp                 : in    std_logic;
      gtrefclk            : in    std_logic;
      pmareset            : in    std_logic;
      mmcm_locked         : in    std_logic;
      resetdone           : out   std_logic
   );
   end component;



   -----------------------------------------------------------------------------
   -- Component Declaration for the 1000BASE-X PCS/PMA sublayer core.
   -----------------------------------------------------------------------------
   component gig_eth_pcs_pma_v11_5
      port(
      -- Core <=> Transceiver Interface
      ------------------------------

      mgt_rx_reset         : out std_logic;                    -- Transceiver connection: reset for the receiver half of the Transceiver
      mgt_tx_reset         : out std_logic;                    -- Transceiver connection: reset for the transmitter half of the Transceiver
      userclk              : in std_logic;                     -- Routed to TXUSERCLK and RXUSERCLK of Transceiver.
      userclk2             : in std_logic;                     -- Routed to TXUSERCLK2 and RXUSERCLK2 of Transceiver.
      dcm_locked           : in std_logic;                     -- LOCKED signal from DCM.

      rxbufstatus          : in std_logic_vector (1 downto 0); -- Transceiver connection: Elastic Buffer Status.
      rxchariscomma        : in std_logic_vector (0 downto 0); -- Transceiver connection: Comma detected in RXDATA.
      rxcharisk            : in std_logic_vector (0 downto 0); -- Transceiver connection: K character received (or extra data bit) in RXDATA.
      rxclkcorcnt          : in std_logic_vector (2 downto 0); -- Transceiver connection: Indicates clock correction.
      rxdata               : in std_logic_vector (7 downto 0); -- Transceiver connection: Data after 8B/10B decoding.
      rxdisperr            : in std_logic_vector (0 downto 0); -- Transceiver connection: Disparity-error in RXDATA.
      rxnotintable         : in std_logic_vector (0 downto 0); -- Transceiver connection: Non-existent 8B/10 code indicated.
      rxrundisp            : in std_logic_vector (0 downto 0); -- Transceiver connection: Running Disparity of RXDATA (or extra data bit).
      txbuferr             : in std_logic;                     -- Transceiver connection: TX Buffer error (overflow or underflow).

      powerdown            : out std_logic;                    -- Transceiver connection: Powerdown the Transceiver
      txchardispmode       : out std_logic;                    -- Transceiver connection: Set running disparity for current byte.
      txchardispval        : out std_logic;                    -- Transceiver connection: Set running disparity value.
      txcharisk            : out std_logic;                    -- Transceiver connection: K character transmitted in TXDATA.
      txdata               : out std_logic_vector(7 downto 0); -- Transceiver connection: Data for 8B/10B encoding.
      enablealign          : out std_logic;                    -- Allow the transceivers to serially realign to a comma character.

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
  -- internal signals used in this block level wrapper.
  ------------------------------------------------------------------------------

  -- Core <=> Transceiver interconnect
  signal plllock           : std_logic;                        -- The PLL Locked status of the Transceiver
  signal mgt_rx_reset      : std_logic;                        -- Reset for the receiver half of the Transceiver
  signal mgt_tx_reset      : std_logic;                        -- Reset for the transmitter half of the Transceiver
  signal rxbufstatus       : std_logic_vector (1 downto 0);    -- Elastic Buffer Status (bit 1 asserted indicates overflow or underflow).
  signal rxchariscomma     : std_logic_vector (0 downto 0);    -- Comma detected in RXDATA.
  signal rxcharisk         : std_logic_vector (0 downto 0);    -- K character received (or extra data bit) in RXDATA.
  signal rxclkcorcnt       : std_logic_vector (2 downto 0);    -- Indicates clock correction.
  signal rxdata            : std_logic_vector (7 downto 0);    -- Data after 8B/10B decoding.
  signal rxdisperr         : std_logic_vector (0 downto 0);    -- Disparity-error in RXDATA.
  signal rxnotintable      : std_logic_vector (0 downto 0);    -- Non-existent 8B/10 code indicated.
  signal rxrundisp         : std_logic_vector (0 downto 0);    -- Running Disparity after current byte, becomes 9th data bit when RXNOTINTABLE='1'.
  signal txbuferr          : std_logic;                        -- TX Buffer error (overflow or underflow).
  signal loopback          : std_logic;                        -- Set the Transceiver for loopback.
  signal powerdown         : std_logic;                        -- Powerdown the Transceiver
  signal txchardispmode    : std_logic;                        -- Set running disparity for current byte.
  signal txchardispval     : std_logic;                        -- Set running disparity value.
  signal txcharisk         : std_logic;                        -- K character transmitted in TXDATA.
  signal txdata            : std_logic_vector(7 downto 0);     -- Data for 8B/10B encoding.
  signal enablealign       : std_logic;                        -- Allow the transceivers to serially realign to a comma character.
  signal status_vector_i   : std_logic_vector(15 downto 0);


begin


  ------------------------------------------------------------------------------
  -- Instantiate the core
  ------------------------------------------------------------------------------

  gig_eth_pcs_pma_core : gig_eth_pcs_pma_v11_5
    port map (
      mgt_rx_reset         => mgt_rx_reset,
      mgt_tx_reset         => mgt_tx_reset,
      userclk              => userclk2,
      userclk2             => userclk2,
      dcm_locked           => mmcm_locked,
      rxbufstatus          => rxbufstatus,
      rxchariscomma        => rxchariscomma,
      rxcharisk            => rxcharisk,
      rxclkcorcnt          => rxclkcorcnt,
      rxdata               => rxdata,
      rxdisperr            => rxdisperr,
      rxnotintable         => rxnotintable,
      rxrundisp            => rxrundisp,
      txbuferr             => txbuferr,
      powerdown            => powerdown,
      txchardispmode       => txchardispmode,
      txchardispval        => txchardispval,
      txcharisk            => txcharisk,
      txdata               => txdata,
      enablealign          => enablealign,
      gmii_txd             => gmii_txd,
      gmii_tx_en           => gmii_tx_en,
      gmii_tx_er           => gmii_tx_er,
      gmii_rxd             => gmii_rxd,
      gmii_rx_dv           => gmii_rx_dv,
      gmii_rx_er           => gmii_rx_er,
      gmii_isolate         => gmii_isolate,
      configuration_vector => configuration_vector,
      status_vector        => status_vector_i,
      reset                => reset,
      signal_detect        => signal_detect

   );


  status_vector <= status_vector_i;
  ------------------------------------------------------------------------------
  -- Component Instantiation for the Series-7 Transceiver wrapper
  ------------------------------------------------------------------------------

   transceiver_inst : gig_eth_pcs_pma_v11_5_transceiver
    generic map (
        EXAMPLE_SIMULATION              =>     EXAMPLE_SIMULATION

    )
   port map (
      drpaddr_in           => drpaddr_in, 
      drpclk_in            => drpclk_in , 
      drpdi_in             => drpdi_in  , 
      drpdo_out            => drpdo_out , 
      drpen_in             => drpen_in  , 
      drprdy_out           => drprdy_out, 
      drpwe_in             => drpwe_in  ,
      encommaalign         => enablealign,
      loopback             => loopback,
      powerdown            => powerdown,
      usrclk               => userclk,
      usrclk2              => userclk2,
      data_valid           => status_vector_i(1),
      independent_clock    => independent_clock_bufg,
      txreset              => mgt_tx_reset,
      txchardispmode       => txchardispmode,
      txchardispval        => txchardispval,
      txcharisk            => txcharisk,
      txdata               => txdata,
      rxreset              => mgt_rx_reset,
      rxchariscomma        => rxchariscomma(0),
      rxcharisk            => rxcharisk(0),
      rxclkcorcnt          => rxclkcorcnt,
      rxdata               => rxdata,
      rxdisperr            => rxdisperr(0),
      rxnotintable         => rxnotintable(0),
      rxrundisp            => rxrundisp(0),
      rxbuferr             => rxbufstatus(1),
      txbuferr             => txbuferr,
      plllkdet             => plllock,
      txoutclk             => txoutclk,
      txn                  => txn,
      txp                  => txp,
      rxn                  => rxn,
      rxp                  => rxp,
      gtrefclk             => gtrefclk,
      pmareset             => pma_reset,
      mmcm_locked          => mmcm_locked,
      resetdone            => resetdone
   );


   -- Unused
   rxbufstatus(0) <= '0';



   -- Loopback is performed in the core itself.  To alternatively use
   -- Transceiver loopback, please drive this port appropriately.
   loopback <= '0';



end block_level;

