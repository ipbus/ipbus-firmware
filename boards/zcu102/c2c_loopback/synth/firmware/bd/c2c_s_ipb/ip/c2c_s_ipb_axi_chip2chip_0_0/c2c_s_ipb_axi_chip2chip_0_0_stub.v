// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
// Date        : Sat Nov  2 15:57:35 2019
// Host        : heplnw017.pp.rl.ac.uk running 64-bit CentOS Linux release 7.7.1908 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /data/tsw/firmware/ipbus-dev-zcu102-c2c/proj/zcu102_2017.4to2019.1/zcu102_2017.4to2019.1/zcu102_2017.4to2019.1.srcs/sources_1/bd/c2c_s_ipb/ip/c2c_s_ipb_axi_chip2chip_0_0/c2c_s_ipb_axi_chip2chip_0_0_stub.v
// Design      : c2c_s_ipb_axi_chip2chip_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axi_chip2chip_v5_0_5,Vivado 2019.1" *)
module c2c_s_ipb_axi_chip2chip_0_0(axi_c2c_lnk_hndlr_in_progress, m_aclk, 
  m_aresetn, m_axi_awaddr, m_axi_awlen, m_axi_awsize, m_axi_awburst, m_axi_awvalid, 
  m_axi_awready, m_axi_wdata, m_axi_wstrb, m_axi_wlast, m_axi_wvalid, m_axi_wready, 
  m_axi_bresp, m_axi_bvalid, m_axi_bready, m_axi_araddr, m_axi_arlen, m_axi_arsize, 
  m_axi_arburst, m_axi_arvalid, m_axi_arready, m_axi_rdata, m_axi_rresp, m_axi_rlast, 
  m_axi_rvalid, m_axi_rready, axi_c2c_s2m_intr_in, axi_c2c_m2s_intr_out, axi_c2c_phy_clk, 
  axi_c2c_aurora_channel_up, axi_c2c_aurora_tx_tready, axi_c2c_aurora_tx_tdata, 
  axi_c2c_aurora_tx_tvalid, axi_c2c_aurora_rx_tdata, axi_c2c_aurora_rx_tvalid, 
  aurora_do_cc, aurora_pma_init_in, aurora_init_clk, aurora_pma_init_out, 
  aurora_mmcm_not_locked, aurora_reset_pb, axi_c2c_config_error_out, 
  axi_c2c_link_status_out, axi_c2c_multi_bit_error_out)
/* synthesis syn_black_box black_box_pad_pin="axi_c2c_lnk_hndlr_in_progress,m_aclk,m_aresetn,m_axi_awaddr[31:0],m_axi_awlen[7:0],m_axi_awsize[2:0],m_axi_awburst[1:0],m_axi_awvalid,m_axi_awready,m_axi_wdata[63:0],m_axi_wstrb[7:0],m_axi_wlast,m_axi_wvalid,m_axi_wready,m_axi_bresp[1:0],m_axi_bvalid,m_axi_bready,m_axi_araddr[31:0],m_axi_arlen[7:0],m_axi_arsize[2:0],m_axi_arburst[1:0],m_axi_arvalid,m_axi_arready,m_axi_rdata[63:0],m_axi_rresp[1:0],m_axi_rlast,m_axi_rvalid,m_axi_rready,axi_c2c_s2m_intr_in[3:0],axi_c2c_m2s_intr_out[3:0],axi_c2c_phy_clk,axi_c2c_aurora_channel_up,axi_c2c_aurora_tx_tready,axi_c2c_aurora_tx_tdata[63:0],axi_c2c_aurora_tx_tvalid,axi_c2c_aurora_rx_tdata[63:0],axi_c2c_aurora_rx_tvalid,aurora_do_cc,aurora_pma_init_in,aurora_init_clk,aurora_pma_init_out,aurora_mmcm_not_locked,aurora_reset_pb,axi_c2c_config_error_out,axi_c2c_link_status_out,axi_c2c_multi_bit_error_out" */;
  output axi_c2c_lnk_hndlr_in_progress;
  input m_aclk;
  input m_aresetn;
  output [31:0]m_axi_awaddr;
  output [7:0]m_axi_awlen;
  output [2:0]m_axi_awsize;
  output [1:0]m_axi_awburst;
  output m_axi_awvalid;
  input m_axi_awready;
  output [63:0]m_axi_wdata;
  output [7:0]m_axi_wstrb;
  output m_axi_wlast;
  output m_axi_wvalid;
  input m_axi_wready;
  input [1:0]m_axi_bresp;
  input m_axi_bvalid;
  output m_axi_bready;
  output [31:0]m_axi_araddr;
  output [7:0]m_axi_arlen;
  output [2:0]m_axi_arsize;
  output [1:0]m_axi_arburst;
  output m_axi_arvalid;
  input m_axi_arready;
  input [63:0]m_axi_rdata;
  input [1:0]m_axi_rresp;
  input m_axi_rlast;
  input m_axi_rvalid;
  output m_axi_rready;
  input [3:0]axi_c2c_s2m_intr_in;
  output [3:0]axi_c2c_m2s_intr_out;
  input axi_c2c_phy_clk;
  input axi_c2c_aurora_channel_up;
  input axi_c2c_aurora_tx_tready;
  output [63:0]axi_c2c_aurora_tx_tdata;
  output axi_c2c_aurora_tx_tvalid;
  input [63:0]axi_c2c_aurora_rx_tdata;
  input axi_c2c_aurora_rx_tvalid;
  output aurora_do_cc;
  input aurora_pma_init_in;
  input aurora_init_clk;
  output aurora_pma_init_out;
  input aurora_mmcm_not_locked;
  output aurora_reset_pb;
  output axi_c2c_config_error_out;
  output axi_c2c_link_status_out;
  output axi_c2c_multi_bit_error_out;
endmodule
