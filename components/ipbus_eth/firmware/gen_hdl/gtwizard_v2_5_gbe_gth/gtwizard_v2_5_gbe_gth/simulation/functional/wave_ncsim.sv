###############################################################################
##
## (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
## 
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.

  window new WaveWindow  -name  "Waves for 7 Series FPGAs Transceivers Wizard Example Design"
  waveform  using  "Waves for 7 Series FPGAs Transceivers Wizard Example Design"
   waveform  add  -label FRAME_CHECK_MODULE -comment gt0_frame_check
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gt0_frame_check.begin_r
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gt0_frame_check.track_data_r
  waveform  add  -siganls  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gt0_frame_check.data_error_detected_r
  wavefrom  add  -siganls  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gt0_frame_check.start_of_packet_detected_r
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gt0_frame_check.RX_DATA
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gt0_frame_check.ERROR_COUNT
  waveform  add  -label GT0_gtwizard_v2_5_gbe_gth -comment GT0_gtwizard_v2_5_gbe_gth
  waveform  add  -label CPLL_Ports  -comment  CPLL_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.CPLLFBCLKLOST_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.CPLLLOCK_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.CPLLLOCKDETCLK_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.CPLLREFCLKLOST_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.CPLLRESET_IN
  waveform  add  -label Channel_-_Clocking_Ports  -comment  Channel_-_Clocking_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.GTREFCLK0_IN
  waveform  add  -label Channel_-_DRP_Ports_  -comment  Channel_-_DRP_Ports_
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.DRPADDR_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.DRPCLK_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.DRPDI_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.DRPDO_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.DRPEN_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.DRPRDY_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.DRPWE_IN
  waveform  add  -label Clocking_Ports  -comment  Clocking_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.QPLLCLK_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.QPLLREFCLK_IN
  waveform  add  -label Loopback_Ports  -comment  Loopback_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.LOOPBACK_IN
  waveform  add  -label Power-Down_Ports  -comment  Power-Down_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXPD_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXPD_IN
  waveform  add  -label RX_Initialization_and_Reset_Ports  -comment  RX_Initialization_and_Reset_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXUSERRDY_IN
  waveform  add  -label RX_Margin_Analysis_Ports  -comment  RX_Margin_Analysis_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.EYESCANDATAERROR_OUT
  waveform  add  -label Receive_Ports_-_CDR_Ports  -comment  Receive_Ports_-_CDR_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXCDRLOCK_OUT
  waveform  add  -label Receive_Ports_-_Clock_Correction_Ports  -comment  Receive_Ports_-_Clock_Correction_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXCLKCORCNT_OUT
  waveform  add  -label Receive_Ports_-_FPGA_RX_Interface_Ports  -comment  Receive_Ports_-_FPGA_RX_Interface_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXUSRCLK_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXUSRCLK2_IN
  waveform  add  -label Receive_Ports_-_FPGA_RX_interface_Ports  -comment  Receive_Ports_-_FPGA_RX_interface_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXDATA_OUT
  waveform  add  -label Receive_Ports_-_RX_8B/10B_Decoder_Ports  -comment  Receive_Ports_-_RX_8B/10B_Decoder_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXDISPERR_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXNOTINTABLE_OUT
  waveform  add  -label Receive_Ports_-_RX_AFE_Ports  -comment  Receive_Ports_-_RX_AFE_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.GTHRXN_IN
  waveform  add  -label Receive_Ports_-_RX_Buffer_Bypass_Ports  -comment  Receive_Ports_-_RX_Buffer_Bypass_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXBUFRESET_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXBUFSTATUS_OUT
  waveform  add  -label Receive_Ports_-_RX_Byte_and_Word_Alignment_Ports  -comment  Receive_Ports_-_RX_Byte_and_Word_Alignment_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXMCOMMAALIGNEN_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXPCOMMAALIGNEN_IN
  waveform  add  -label Receive_Ports_-_RX_Equilizer_Ports  -comment  Receive_Ports_-_RX_Equilizer_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXLPMHFHOLD_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXLPMLFHOLD_IN
  waveform  add  -label Receive_Ports_-_RX_Fabric_Output_Control_Ports  -comment  Receive_Ports_-_RX_Fabric_Output_Control_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXOUTCLK_OUT
  waveform  add  -label Receive_Ports_-_RX_Initialization_and_Reset_Ports  -comment  Receive_Ports_-_RX_Initialization_and_Reset_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.GTRXRESET_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXPCSRESET_IN
  waveform  add  -label Receive_Ports_-_RX8B/10B_Decoder_Ports  -comment  Receive_Ports_-_RX8B/10B_Decoder_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXCHARISCOMMA_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXCHARISK_OUT
  waveform  add  -label Receive_Ports_-RX_AFE_Ports  -comment  Receive_Ports_-RX_AFE_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.GTHRXP_IN
  waveform  add  -label Receive_Ports_-RX_Initialization_and_Reset_Ports  -comment  Receive_Ports_-RX_Initialization_and_Reset_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.RXRESETDONE_OUT
  waveform  add  -label TX_Initialization_and_Reset_Ports  -comment  TX_Initialization_and_Reset_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.GTTXRESET_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXUSERRDY_IN
  waveform  add  -label Transmit_Ports_-_8b10b_Encoder_Control_Ports  -comment  Transmit_Ports_-_8b10b_Encoder_Control_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXCHARDISPMODE_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXCHARDISPVAL_IN
  waveform  add  -label Transmit_Ports_-_FPGA_TX_Interface_Ports  -comment  Transmit_Ports_-_FPGA_TX_Interface_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXUSRCLK_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXUSRCLK2_IN
  waveform  add  -label Transmit_Ports_-_PCI_Express_Ports  -comment  Transmit_Ports_-_PCI_Express_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXELECIDLE_IN
  waveform  add  -label Transmit_Ports_-_TX_Buffer_Ports  -comment  Transmit_Ports_-_TX_Buffer_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXBUFSTATUS_OUT
  waveform  add  -label Transmit_Ports_-_TX_Data_Path_interface  -comment  Transmit_Ports_-_TX_Data_Path_interface
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXDATA_IN
  waveform  add  -label Transmit_Ports_-_TX_Driver_and_OOB_signaling  -comment  Transmit_Ports_-_TX_Driver_and_OOB_signaling
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.GTHTXN_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.GTHTXP_OUT
  waveform  add  -label Transmit_Ports_-_TX_Fabric_Clock_Output_Control_Ports  -comment  Transmit_Ports_-_TX_Fabric_Clock_Output_Control_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXOUTCLK_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXOUTCLKFABRIC_OUT
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXOUTCLKPCS_OUT
  waveform  add  -label Transmit_Ports_-_TX_Initialization_and_Reset_Ports  -comment  Transmit_Ports_-_TX_Initialization_and_Reset_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXPCSRESET_IN
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXRESETDONE_OUT
  waveform  add  -label Transmit_Transmit_Ports_-_8b10b_Encoder_Control_Ports  -comment  Transmit_Transmit_Ports_-_8b10b_Encoder_Control_Ports
  waveform  add  -signals  gtwizard_v2_5_gbe_gth_TB.gtwizard_v2_5_gbe_gth_exdes_i.gtwizard_v2_5_gbe_gth_init_i.gtwizard_v2_5_gbe_gth_i.gt0_gtwizard_v2_5_gbe_gth_i.TXCHARISK_IN


  console submit -using simulator -wait no "run 300 us"

