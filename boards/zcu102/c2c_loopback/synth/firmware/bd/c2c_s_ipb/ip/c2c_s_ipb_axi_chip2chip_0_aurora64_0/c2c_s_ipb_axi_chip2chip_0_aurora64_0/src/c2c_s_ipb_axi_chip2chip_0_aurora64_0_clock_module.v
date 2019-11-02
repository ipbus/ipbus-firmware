 ///////////////////////////////////////////////////////////////////////////////
 //
 // Project:  Aurora 64B/66B
 // Company:  Xilinx
 //
 //
 //
 // (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
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
 ///////////////////////////////////////////////////////////////////////////////
 //
 //  CLOCK_MODULE
 //
 //
 //  Description: This module takes the reference clock as
 //               input, and produces a divided clock on a global clock net suitable
 //               for driving application logic connected to the Aurora User Interface.
 //

 `timescale 1 ns / 10 ps

(* DowngradeIPIdentifiedWarnings="yes" *)
 module c2c_s_ipb_axi_chip2chip_0_aurora64_0_CLOCK_MODULE #
 (
       parameter   OUT2_DIVIDE     =   10,
       parameter   OUT3_DIVIDE     =   8
 )
 (
     CLK,
     CLK_LOCKED,
     USER_CLK,
     SYNC_CLK,
     MMCM_NOT_LOCKED

 );

 `define DLY #1


 //***********************************Port Declarations*******************************

     input       CLK;
     input       CLK_LOCKED;
     output      USER_CLK;
     output      SYNC_CLK;
     output      MMCM_NOT_LOCKED;

 //*********************************Wire Declarations**********************************

 //*********************************Main Body of Code**********************************


//------------------------------------------------------------------------------
// Tx is needed in ALL conditions like Duplex, Tx only, Rx/Tx simplex
   // Ultrascale GT TX clocking module in outside of the GT


     //                          ___________
     //                         |           |------> user_clk (Tx/Rx userclk2_out)
     //                         |ultrascale |
     //                         | Tx CLK    |------> sync clk (Tx/Rx userclk_out)
     //                 CLK --->| Userclk   |
     //      (txoutclk_out)     | MODULE    |------> shim_clk - not connected
     //                         |           |
     //          CLK_LOCKED --->|           |------> pll_not_locked
     // (tx_pma_reset_done_out) |           |        (--> connect to userclk_tx_active_out in multi gt file)
     //                         |___________|------------> clk_o
     //
                                  
      c2c_s_ipb_axi_chip2chip_0_aurora64_0_ultrascale_tx_userclk ultrascale_tx_userclk_1
      (
       // port declaration
            .gtwiz_userclk_tx_srcclk_in     (CLK          ), // txoutclk_out (GT)                         input  wire
            .gtwiz_userclk_tx_reset_in      (CLK_LOCKED   ), // tx_pma_reset_done_out (GT)                input  wire
            .gtwiz_userclk_tx_usrclk_out    (SYNC_CLK     ), // usrclk_out                                output wire
            .gtwiz_userclk_tx_usrclk2_out   (USER_CLK     ), // usrclk2_out                               output wire
            .gtwiz_userclk_tx_active_out    (MMCM_NOT_LOCKED )//gtwiz_userclk_tx_active_out(GT)output reg = 1'b0
      );
endmodule
