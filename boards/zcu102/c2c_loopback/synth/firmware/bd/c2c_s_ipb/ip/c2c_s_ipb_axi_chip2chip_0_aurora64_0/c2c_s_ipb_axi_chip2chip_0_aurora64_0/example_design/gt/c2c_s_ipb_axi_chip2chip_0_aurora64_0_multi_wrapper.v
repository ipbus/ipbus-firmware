 ///////////////////////////////////////////////////////////////////////////////
 //
 // Project:  Aurora 64B/66B
 // Company:  Xilinx
 //
 //
 //
 // (c) Copyright 2008 - 2014 Xilinx, Inc. All rights reserved.
 //
 // This file contains confidential and proprietary information
 // of Xilinx, Inc. and is protected under U.S. and
 // international copyright and other intellectual property
 // laws.
 //
 // DISCLAIMER
 // This disclaimer is not a license and does not grant any
 // rights to the materials distributed herewith. Except as
 // otherwise provided in a valid license issued to you by
 // Xilinx, and to the maximum extent permitted by applicable
 // law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
 // WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
 // AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
 // BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
 // INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
 // (2) Xilinx shall not be liable (whether in contract or tort,
 // including negligence, or under any other theory of
 // liability) for any loss or damage of any kind or nature
 // related to, arising under or in connection with these
 // materials, including for any direct, or any indirect,
 // special, incidental, or consequential loss or damage
 // (including loss of data, profits, goodwill, or any type of
 // loss or damage suffered as a result of any action brought
 // by a third party) even if such damage or loss was
 // reasonably foreseeable or Xilinx had been advised of the
 // possibility of the same.
 //
 // CRITICAL APPLICATIONS
 // Xilinx products are not designed or intended to be fail-
 // safe, or for use in any application requiring fail-safe
 // performance, such as life-support or safety devices or
 // systems, Class III medical devices, nuclear facilities,
 // applications related to the deployment of airbags, or any
 // other applications that could lead to death, personal
 // injury, or severe property or environmental damage
 // (individually and collectively, "Critical
 // Applications"). Customer assumes the sole risk and
 // liability of any use of Xilinx products in Critical
 // Applications, subject only to applicable laws and
 // regulations governing limitations on product liability.
 //
 // THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
 // PART OF THIS FILE AT ALL TIMES.

 //
 //
 ////////////////////////////////////////////////////////////////////////////////
 // Design Name: c2c_s_ipb_axi_chip2chip_0_aurora64_0_MULTI_GT
 //

 // Multi GT wrapper for ultrascale series

 `timescale 1ns / 1ps
 `define DLY #1

   (* core_generation_info = "c2c_s_ipb_axi_chip2chip_0_aurora64_0,aurora_64b66b_v12_0_0,{c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTHQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=5.0,c_gt_type=GTHE4,c_qpll=false,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=156.25,c_simplex=false,c_simplex_mode=TX,c_stream=true,c_ufc=false,c_user_k=false,flow_mode=None,interface_mode=Streaming,dataflow_config=Duplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
 module c2c_s_ipb_axi_chip2chip_0_aurora64_0_MULTI_GT
 (
    // GT reset module interface ports starts
    input           gtwiz_reset_all_in                ,
    input           gtwiz_reset_clk_freerun_in        ,
    input           gtwiz_reset_tx_pll_and_datapath_in,
    input           gtwiz_reset_tx_datapath_in        ,
    input           gtwiz_reset_rx_pll_and_datapath_in,
    input           gtwiz_reset_rx_datapath_in        ,
    input           gtwiz_reset_rx_data_good_in       ,

    output          gtwiz_reset_rx_cdr_stable_out     ,
    output          gtwiz_reset_tx_done_out           ,
    output          gtwiz_reset_rx_done_out           ,

    // GT reset module interface ports ends
    output          fabric_pcs_reset                  ,
    output          bufg_gt_clr_out             ,
    input           gtwiz_userclk_tx_active_out       ,

    output          userclk_rx_active_out             ,

    //____________________________CHANNEL PORTS________________________________
    //------------------------------- CPLL Ports -------------------------------
    //------------------------ Channel - Clocking Ports ------------------------
     output [0:0]         gt_cplllock,

    input           gt0_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [9:0]    gt0_drpaddr,
    input           gt0_drp_clk_in,
    input  [15:0]   gt0_drpdi,
    output [15:0]   gt0_drpdo,
    input           gt0_drpen,
    output          gt0_drprdy,
    input           gt0_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt0_rxusrclk_out,
    output          gt0_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt0_txusrclk_in,
    input           gt0_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    input  [2:0]       gt_loopback,
    //------------------- RX Initialization and Reset Ports --------------------
    input  [0:0]         gt_eyescanreset,
    input  [0:0]         gt_rxpolarity,
    //------------------------ RX Margin Analysis Ports ------------------------
    output [0:0]         gt_eyescandataerror,
    input  [0:0]         gt_eyescantrigger,
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt0_rxcdrovrden_in,
    input  [0:0]         gt_rxcdrhold,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt0_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt0_gthrxn_in,
    input                                           gt0_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    output  [2:0]      gt_rxbufstatus,
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    input   [0:0]        gt_rxdfelpmreset,
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt0_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt0_rxdatavalid_out,
    output [1:0]                                    gt0_rxheader_out,
    output                                          gt0_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt0_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    input  [0:0]         gt_rxlpmen,
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    input  [0:0]         gt_gtrxreset,
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    output [0:0]         gt_rxresetdone,
    //---------------------- TX Configurable Driver Ports ----------------------
    input  [4:0]       gt_txpostcursor,
    //------------------- TX Initialization and Reset Ports --------------------
    input  [0:0]         gt_gttxreset,

    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt0_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
 
    input   [4:0]      gt_txdiffctrl,
    output [15:0]      gt_dmonitorout,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt0_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt0_gthtxn_out,
    output                                           gt0_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt0_txoutclk_out,
    output                                           gt0_txoutclkfabric_out,
    output                                           gt0_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt0_txsequence_in,
    //--------------- Transmit Ports - TX Polarity Control Ports ---------------
    input  [0:0]         gt_txpolarity,
    input  [0:0]         gt_txinhibit,
    input  [15:0]  gt_pcsrsvdin,
    input  [0:0]         gt_txpmareset,
    input  [0:0]         gt_txpcsreset,
    input  [0:0]         gt_rxpcsreset,
    input  [0:0]         gt_rxbufreset,
    output [0:0]         gt_rxpmaresetdone,
    input  [4:0]       gt_txprecursor,
    input  [3:0]       gt_txprbssel,
    input  [3:0]       gt_rxprbssel,
    input  [0:0]         gt_txprbsforceerr,
    output [0:0]         gt_rxprbserr,
    input  [0:0]         gt_rxprbscntreset,
    output [1:0]       gt_txbufstatus,
    input  [0:0]         gt_rxpmareset,
    input  [2:0]       gt_rxrate,
    //----------- GT POWERGOOD STATUS Port -----------
    output [0:0]         gt_powergood,
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    output [0:0]         gt_txresetdone

 );

 //***************************** Wire Declarations *****************************
     // Ground and VCC signals
     wire                    tied_to_ground_i;
     wire    [280:0]         tied_to_ground_vec_i;
     wire                    tied_to_vcc_i;
 //********************************* Main Body of Code**************************
     //-------------------------  Static signal Assigments ---------------------
     assign tied_to_ground_i          = 1'b0;
     assign tied_to_ground_vec_i      = 281'd0;
     assign tied_to_vcc_i             = 1'b1;

// wire definition starts
    wire                                            gtwiz_userclk_tx_active_out_i;   

    wire  [0 : 0] gtrefclk0_in      ;

    wire  [0 : 0] cplllock_out      ;

    //--------------------------------------------------------------------------

 
    wire  [9 : 0 ] drpaddr_in;
    wire  [0 : 0 ] drpclk_in;
    wire  [15 : 0 ] drpdi_in  ;
    wire  [15 : 0 ] drpdo_out ;
    wire  [0 : 0 ] drpen_in  ;
    wire  [0 : 0 ] drprdy_out;
    wire  [0 : 0 ] drpwe_in  ;

    wire  [2 : 0 ] loopback_in;

    wire  [1 : 0 ] rxstartofseq_out;

    wire  [0 : 0 ] eyescanreset_in;
    wire  [0 : 0 ] rxpolarity_in  ;

    wire  [0 : 0 ] eyescandataerror_out;
    wire  [0 : 0 ] eyescantrigger_in   ;

    wire  [0 : 0 ] rxcdrovrden_in;
    wire  [0 : 0 ] rxcdrhold_in  ;
    wire  [31: 0 ] gtwiz_userdata_rx_out;
 
    wire  [0 : 0 ] gthrxn_in     ;
    wire  [0 : 0 ] gthrxp_in     ;
    wire  [2 : 0 ] rxbufstatus_out    ;//
    wire  [0 : 0 ] rxdfelpmreset_in   ;//
    wire  [0 : 0 ] rxoutclk_out       ;//
    wire  [1 : 0 ] rxdatavalid_out  ;//
    wire  [5 : 0 ] rxheader_out       ;//
    wire  [1 : 0 ] rxheadervalid_out  ;//
    wire  [0 : 0 ] rxgearboxslip_in   ;//
    wire  [0 : 0 ] rxlpmen_in         ;//
    wire  [0 : 0 ] gtrxreset_in       ;//
    wire  [0 : 0 ] rxresetdone_out    ;//
    wire  [4 : 0 ] txpostcursor_in    ;//
    wire  [0 : 0 ] gttxreset_in       ;//
    //wire  [0 : 0 ] txuserrdy_in     ;
    wire  [5 : 0 ] txheader_in        ;//
 
    wire  [4 : 0 ] txdiffctrl_in      ;//
    wire  [63 : 0 ] gtwiz_userdata_tx_in;//
 
    wire  [0 : 0 ] gthtxn_out         ;//
    wire  [0 : 0 ] gthtxp_out         ;//
 
    wire  [0 : 0 ] txoutclk_out       ;//
    wire  [0 : 0 ] txoutclkfabric_out ;//
    wire  [0 : 0 ] txoutclkpcs_out    ;//

    wire  [6 : 0 ] txsequence_in      ;//
    wire  [0 : 0 ] txpolarity_in      ;//
    wire  [0 : 0 ] txinhibit_in      ;//
    wire  [0 : 0 ] txpmareset_in      ;//
    wire  [0 : 0 ] txpcsreset_in      ;//
    wire  [0 : 0 ] rxpcsreset_in      ;//
    wire  [0 : 0 ] rxbufreset_in      ;//
    wire  [0 : 0 ] rxpmaresetdone_out ;//
    wire  [4 : 0 ] txprecursor_in     ;//
    wire  [3 : 0 ] txprbssel_in       ;//
    wire  [3 : 0 ] rxprbssel_in       ;//
    wire  [0 : 0 ] txprbsforceerr_in  ;//
    wire  [0 : 0 ] rxprbserr_out      ;//
    wire  [0 : 0 ] rxprbscntreset_in  ;//
    wire  [15 : 0 ] pcsrsvdin_in       ;//
 
    wire  [15 : 0 ] dmonitorout_out    ;//
 
    wire  [1 : 0 ] txbufstatus_out    ;//
    wire  [0 : 0 ] rxpmareset_in      ;//
    wire  [2 : 0 ] rxrate_in          ;//
    wire  [0 : 0 ] txresetdone_out    ;//
    wire  [0 : 0 ] txusrclk_in        ;
    wire  [0 : 0 ] txusrclk2_in       ;
    wire  [0 : 0 ] rxusrclk_in        ;
    wire  [0 : 0 ] rxusrclk2_in       ;

    reg   [9:0] fabric_pcs_rst_extend_cntr      = 10'b0; // 10 bit counter
    reg   [7:0] usrclk_rx_active_in_extend_cntr = 8'b0 ; // 8 bit counter
    reg   [7:0] usrclk_tx_active_in_extend_cntr = 8'b0 ; // 8 bit counter

    wire  [0 : 0 ] txpmaresetdone_out;

    wire  [0 : 0 ] txpmaresetdone_int;
    wire  [0 : 0 ] rxpmaresetdone_int;
    wire  [0 : 0 ] gtpowergood_out;

    reg   gtwiz_userclk_rx_reset_in_r=1'b0;

    // Clocking module is outside of GT.
    wire gtwiz_userclk_tx_active_in;
    wire gtwiz_userclk_rx_active_in;

    wire gtwiz_userclk_rx_usrclk2_out;// signals from Rx clocking module
    wire gtwiz_userclk_rx_usrclk_out; // signals from Rx clocking module

    wire gtwiz_userclk_tx_usrclk2_out;// signals from Tx clocking module
    //wire gtwiz_userclk_tx_usrclk_out; // signals from Tx clocking module

    wire gtwiz_userclk_tx_reset_in  ;
    wire gtwiz_userclk_rx_reset_in  ;

// wire definition ends

// assignment starts
    //--------------------------------------------------------------------------
     
    // Power good assignment
    assign gt_powergood = gtpowergood_out;   
     
    //--------------------------------------------------------------------------
    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[0]        = gt0_gtrefclk0_in     ;

    assign gt_cplllock[0]         = cplllock_out[0]      ;


    // DRP interface for GT channel starts
    assign gt0_drpdo        = drpdo_out[15 : 0];
    assign gt0_drprdy       = drprdy_out[0];

 
    assign drpaddr_in[9 : 0] = gt0_drpaddr;
    assign drpclk_in[0]         = gt0_drp_clk_in;
    assign drpdi_in[15 : 0] = gt0_drpdi;
    assign drpen_in[0]          = gt0_drpen  ;
    assign drpwe_in[0]          = gt0_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[6 : 0] = gt0_txsequence_in;

    assign gt0_rxdata_out       = gtwiz_userdata_rx_out[31 : 0];
    assign gt_rxbufstatus[2 : 0]  = rxbufstatus_out[2 : 0];
    assign gt0_rxheader_out     = rxheader_out[1 : 0];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[2 : 0]     = gt_loopback[2 : 0];
    assign txpostcursor_in[4 : 0] = gt_txpostcursor[4 : 0];
    assign txheader_in[5 : 0]     = {4'b0, gt0_txheader_in[1:0]};
 
    assign txdiffctrl_in[4 : 0]   = gt_txdiffctrl[4 : 0];
    assign gtwiz_userdata_tx_in[63 : 0] = gt0_txdata_in;
    assign txprecursor_in[4 : 0] = gt_txprecursor[4 : 0];
    assign txprbssel_in[3 : 0]   = gt_txprbssel[3 : 0];
    assign rxprbssel_in[3 : 0]   = gt_rxprbssel[3 : 0];


 
    assign gt_dmonitorout[15 : 0] = dmonitorout_out[15 : 0];
 
    assign gt_txbufstatus[1 : 0]   = txbufstatus_out[1 : 0];


    assign eyescanreset_in[0]           = gt_eyescanreset[0]  ;
    assign rxpolarity_in[0]             = gt_rxpolarity[0]   ;
    assign eyescantrigger_in[0]         = gt_eyescantrigger[0];
    assign rxcdrovrden_in[0]            = gt0_rxcdrovrden_in   ;
    assign rxcdrhold_in[0]              = gt_rxcdrhold[0]     ;
 
    assign gthrxn_in[0]                 = gt0_gthrxn_in        ;
    assign gthrxp_in[0]                 = gt0_gthrxp_in        ;
 
    assign rxdfelpmreset_in[0]          = gt_rxdfelpmreset[0] ;
    assign txpolarity_in[0]             = gt_txpolarity[0]    ;
    assign txinhibit_in[0]              = gt_txinhibit[0]    ;
    assign pcsrsvdin_in[15 : 0] = gt_pcsrsvdin[15 : 0];
    assign txpmareset_in[0]             = gt_txpmareset[0]    ;
    assign txpcsreset_in[0]             = gt_txpcsreset[0]    ;
    assign rxpcsreset_in[0]             = gt_rxpcsreset[0]    ;
    assign rxbufreset_in[0]             = gt_rxbufreset[0]    ;
    assign rxgearboxslip_in[0]          = gt0_rxgearboxslip_in ;
    assign rxlpmen_in[0]                = gt_rxlpmen[0]       ;
    assign gtrxreset_in[0]              = gt_gtrxreset[0]     ;
    assign gttxreset_in[0]              = gt_gttxreset[0]     ;
    assign txprbsforceerr_in[0]         = gt_txprbsforceerr[0];
    assign rxprbscntreset_in[0]         = gt_rxprbscntreset[0];

    assign gt_eyescandataerror[0]       = eyescandataerror_out[0];
    assign gt_rxprbserr[0]              = rxprbserr_out[0]     ;
    assign gt0_rxoutclk_out             = rxoutclk_out[0]      ;
    assign gt0_rxdatavalid_out          = rxdatavalid_out[0];

    assign gt0_rxheadervalid_out        = rxheadervalid_out[0] ;
    assign gt_rxresetdone[0]           = rxresetdone_out[0]   ;
 
    assign gt0_gthtxn_out               = gthtxn_out[0]        ;
    assign gt0_gthtxp_out               = gthtxp_out[0]        ;
 
    assign gt0_txoutclk_out             = txoutclk_out[0]      ;
    assign gt0_txoutclkfabric_out       = txoutclkfabric_out[0];
    assign gt0_txoutclkpcs_out          = txoutclkpcs_out[0]   ;
    assign gt_rxpmaresetdone[0]         = rxpmaresetdone_out[0];
    assign gt_txresetdone[0]           = txresetdone_out[0]   ;


    assign rxpmareset_in[0]             = gt_rxpmareset[0];
    assign rxrate_in[2 : 0] = gt_rxrate[2 : 0];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[0]              = gt0_txusrclk2_in;
    assign txusrclk_in[0]               = gt0_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[0]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[0]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt0_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt0_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;



//------------------------------------------------------------------------------
// Rx is needed in below conditions
// duplex, Rx only, RX/TX simplex
    // Ultrascale GT RX clocking module in outside of the GT
  wire gtwiz_userclk_rx_active_out;
     c2c_s_ipb_axi_chip2chip_0_aurora64_0_ultrascale_rx_userclk
     #(
      // parameter declaration
            .P_CONTENTS                     (0),
            .P_FREQ_RATIO_SOURCE_TO_USRCLK  (1),
            .P_FREQ_RATIO_USRCLK_TO_USRCLK2 (1)
      )
    ultrascale_rx_userclk
     (
      // port declaration
            .gtwiz_reset_clk_freerun_in     (gtwiz_reset_clk_freerun_in  ), 
            .gtwiz_userclk_rx_srcclk_in     (rxoutclk_out[0]             ), // input  wire
            .gtwiz_userclk_rx_reset_in      (gtwiz_userclk_rx_reset_in_r   ), // input  wire
            .gtwiz_userclk_rx_usrclk_out    (gtwiz_userclk_rx_usrclk_out ), // output wire
            .gtwiz_userclk_rx_usrclk2_out   (gtwiz_userclk_rx_usrclk2_out), // output wire
            .gtwiz_userclk_rx_active_out    (gtwiz_userclk_rx_active_out )  // output reg  = 1'b0
     );
//------------------------------------------------------------------------------

//--- fabric_pcs_reset reset extension counter based upon the stable clock
    //connect output of main clocking module (user clock) here
    assign gtwiz_userclk_tx_usrclk2_out = txusrclk2_in[0];

//--- synchronizing to usrclk2
//c2c_s_ipb_axi_chip2chip_0_aurora64_0_rst_sync # 
//   ( 
//       .c_mtbf_stages (3) 
//   )u_rst_gtwiz_userclk_tx_active_out 
//   ( 
//       .prmry_in     (gtwiz_userclk_tx_active_out), 
//       .scndry_aclk  (gtwiz_userclk_tx_usrclk2_out), 
//       .scndry_out   (gtwiz_userclk_tx_active_out_i) 
//   ); 
assign  gtwiz_userclk_tx_active_out_i = gtwiz_userclk_tx_active_out;

    always @(posedge gtwiz_userclk_tx_usrclk2_out, negedge gtwiz_userclk_tx_active_out_i)
    begin
        if (!gtwiz_userclk_tx_active_out_i) // deactive counter when tx_active is not present
               fabric_pcs_rst_extend_cntr   <=   10'b0;
        else if (!fabric_pcs_rst_extend_cntr[9])  // when tx active is asserted, extend with 10 bit counter
                fabric_pcs_rst_extend_cntr  <=   fabric_pcs_rst_extend_cntr + 1'b1;
        end


  assign fabric_pcs_reset   = !fabric_pcs_rst_extend_cntr[9];
//--- fabric_pcs_reset reset extension counter ends

//------------------------------------------------------------------------------
//--- gtwiz_userclk_tx_active_in delay extension counter based upon the stable tx clock
// 8-bit counter

    always @(posedge gtwiz_userclk_tx_usrclk2_out, negedge gtwiz_userclk_tx_active_out_i)
    begin
        if (!gtwiz_userclk_tx_active_out_i) // deactive counter when tx_active is not present
                usrclk_tx_active_in_extend_cntr   <=   8'b0;
        else if (fabric_pcs_rst_extend_cntr[9] &&       // Extended tx active from clock module with 10 bit counter
                 (!usrclk_tx_active_in_extend_cntr[7]))
                usrclk_tx_active_in_extend_cntr   <=   usrclk_tx_active_in_extend_cntr + 1'b1;
        end

  assign userclk_tx_active_out   = usrclk_tx_active_in_extend_cntr[7];
//--- gtwiz_userclk_tx_active_in reset extension counter ends
//------------------------------------------------------------------------------

//--- gtwiz_userclk_rx_active_in delay extension counter based upon the stable Rx clock
// 8-bit counter
    always @(posedge gtwiz_userclk_rx_usrclk2_out, negedge gtwiz_userclk_rx_active_out)
    begin
        if (!gtwiz_userclk_rx_active_out)       // deactive counter when rx_active is not present
                usrclk_rx_active_in_extend_cntr   <=   8'b0;
        else if (gtwiz_userclk_rx_active_out && // Rx clock module is stable
                 (!usrclk_rx_active_in_extend_cntr[7]))
                usrclk_rx_active_in_extend_cntr   <=   usrclk_rx_active_in_extend_cntr + 1'b1;
        end

  assign userclk_rx_active_out   = !usrclk_rx_active_in_extend_cntr[7];
//--- gtwiz_userclk_rx_active_in reset extension counter ends
//------------------------------------------------------------------------------
   // assginment of delayed counters of Tx and Rx active signals to GT ports
   assign gtwiz_userclk_tx_active_in = userclk_tx_active_out;
   //--------------------------------------------------------
   // driving the gtwiz_userclk_rx_active_in different conditions
   // Rx clocking module is included in the design
   assign gtwiz_userclk_rx_active_in = usrclk_rx_active_in_extend_cntr[7];
   //--------------------------------------------------------
//------------------------------------------------------------------------------
//-- txpmaresetdone logic starts

   assign txpmaresetdone_int        = txpmaresetdone_out;

   assign gtwiz_userclk_tx_reset_in = ~(&txpmaresetdone_int);
   assign bufg_gt_clr_out     = ~(&txpmaresetdone_int);
//-- txpmaresetdone logic ends

//-- rxpmaresetdone logic starts
   assign rxpmaresetdone_int        = rxpmaresetdone_out;

   assign gtwiz_userclk_rx_reset_in = ~(&rxpmaresetdone_int);
      always @(posedge gtwiz_reset_clk_freerun_in) 
          gtwiz_userclk_rx_reset_in_r <= `DLY gtwiz_userclk_rx_reset_in;
//-- rxpmaresetdone logic ends

    //-- GT Reference clock assignment

    // decision is made to use cpll only - note the 1 at the end of QPLL, so below changes are needed
    // to be incorporated
    assign cplloutclk_out    = cplloutclk_out;
    assign cplloutrefclk_out = cplloutrefclk_out;


 // dynamic GT instance call
   c2c_s_ipb_axi_chip2chip_0_aurora64_0_gt c2c_s_ipb_axi_chip2chip_0_aurora64_0_gt_i
  (
   .cplllock_out(cplllock_out),
   .dmonitorout_out(dmonitorout_out),
   .drpaddr_in(drpaddr_in),
   .drpclk_in(drpclk_in),
   .drpdi_in(drpdi_in),
   .drpdo_out(drpdo_out),
   .drpen_in(drpen_in),
   .drprdy_out(drprdy_out),
   .drpwe_in(drpwe_in),
   .eyescandataerror_out(eyescandataerror_out),
   .eyescanreset_in(eyescanreset_in),
   .eyescantrigger_in(eyescantrigger_in),
   .gthrxn_in(gthrxn_in),
   .gthrxp_in(gthrxp_in),
   .gthtxn_out(gthtxn_out),
   .gthtxp_out(gthtxp_out),
   .gtpowergood_out(gtpowergood_out),
   .gtrefclk0_in(gtrefclk0_in),
   .gtwiz_reset_all_in(gtwiz_reset_all_in),
   .gtwiz_reset_clk_freerun_in(gtwiz_reset_clk_freerun_in),
   .gtwiz_reset_rx_cdr_stable_out(gtwiz_reset_rx_cdr_stable_out),
   .gtwiz_reset_rx_datapath_in(gtwiz_reset_rx_datapath_in),
   .gtwiz_reset_rx_done_out(gtwiz_reset_rx_done_out),
   .gtwiz_reset_rx_pll_and_datapath_in(gtwiz_reset_rx_pll_and_datapath_in),
   .gtwiz_reset_tx_datapath_in(gtwiz_reset_tx_datapath_in),
   .gtwiz_reset_tx_done_out(gtwiz_reset_tx_done_out),
   .gtwiz_reset_tx_pll_and_datapath_in(gtwiz_reset_tx_pll_and_datapath_in),
   .gtwiz_userclk_rx_active_in(gtwiz_userclk_rx_active_in),
   .gtwiz_userclk_tx_active_in(gtwiz_userclk_tx_active_in),
   .gtwiz_userclk_tx_reset_in(gtwiz_userclk_tx_reset_in),
   .gtwiz_userdata_rx_out(gtwiz_userdata_rx_out),
   .gtwiz_userdata_tx_in(gtwiz_userdata_tx_in),
   .loopback_in(loopback_in),
   .pcsrsvdin_in(pcsrsvdin_in),
   .rxbufreset_in(rxbufreset_in),
   .rxbufstatus_out(rxbufstatus_out),
   .rxcdrhold_in(rxcdrhold_in),
   .rxcdrovrden_in(rxcdrovrden_in),
   .rxdatavalid_out(rxdatavalid_out),
   .rxdfelpmreset_in(rxdfelpmreset_in),
   .rxgearboxslip_in(rxgearboxslip_in),
   .rxheader_out(rxheader_out),
   .rxheadervalid_out(rxheadervalid_out),
   .rxlpmen_in(rxlpmen_in),
   .rxoutclk_out(rxoutclk_out),
   .rxpcsreset_in(rxpcsreset_in),
   .rxpmareset_in(rxpmareset_in),
   .rxpmaresetdone_out(rxpmaresetdone_out),
   .rxpolarity_in(rxpolarity_in),
   .rxprbscntreset_in(rxprbscntreset_in),
   .rxprbserr_out(rxprbserr_out),
   .rxprbssel_in(rxprbssel_in),
   .rxresetdone_out(rxresetdone_out),
   .rxstartofseq_out(rxstartofseq_out),
   .rxusrclk2_in(rxusrclk2_in),
   .rxusrclk_in(rxusrclk_in),
   .txbufstatus_out(txbufstatus_out),
   .txdiffctrl_in(txdiffctrl_in),
   .txheader_in(txheader_in),
   .txinhibit_in(txinhibit_in),
   .txoutclk_out(txoutclk_out),
   .txoutclkfabric_out(txoutclkfabric_out),
   .txoutclkpcs_out(txoutclkpcs_out),
   .txpcsreset_in(txpcsreset_in),
   .txpmareset_in(txpmareset_in),
   .txpmaresetdone_out(txpmaresetdone_out),
   .txpolarity_in(txpolarity_in),
   .txpostcursor_in(txpostcursor_in),
   .txprbsforceerr_in(txprbsforceerr_in),
   .txprbssel_in(txprbssel_in),
   .txprecursor_in(txprecursor_in),
   .txresetdone_out(txresetdone_out),
   .txsequence_in(txsequence_in),
   .txusrclk2_in(txusrclk2_in),
   .txusrclk_in(txusrclk_in)
  );



endmodule
