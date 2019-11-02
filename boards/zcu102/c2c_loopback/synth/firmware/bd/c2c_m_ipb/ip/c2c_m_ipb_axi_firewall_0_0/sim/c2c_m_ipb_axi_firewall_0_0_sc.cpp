// (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
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
// DO NOT MODIFY THIS FILE.

#include "c2c_m_ipb_axi_firewall_0_0_sc.h"

#include "axi_firewall.h"

#include <map>
#include <string>

c2c_m_ipb_axi_firewall_0_0_sc::c2c_m_ipb_axi_firewall_0_0_sc(const sc_core::sc_module_name& nm) : sc_core::sc_module(nm), mp_impl(NULL)
{
  // configure connectivity manager
  xsc::utils::xsc_sim_manager::addInstance("c2c_m_ipb_axi_firewall_0_0", this);

  // initialize module
  xsc::common_cpp::properties model_param_props;
  model_param_props.addLong("C_PROTOCOL", "0");
  model_param_props.addLong("C_ID_WIDTH", "0");
  model_param_props.addLong("C_ADDR_WIDTH", "32");
  model_param_props.addLong("C_RDATA_WIDTH", "64");
  model_param_props.addLong("C_WDATA_WIDTH", "64");
  model_param_props.addLong("C_AWUSER_WIDTH", "0");
  model_param_props.addLong("C_ARUSER_WIDTH", "0");
  model_param_props.addLong("C_WUSER_WIDTH", "0");
  model_param_props.addLong("C_RUSER_WIDTH", "0");
  model_param_props.addLong("C_BUSER_WIDTH", "0");
  model_param_props.addLong("C_NUM_READ_THREADS", "1");
  model_param_props.addLong("C_NUM_WRITE_THREADS", "1");
  model_param_props.addLong("C_NUM_READ_OUTSTANDING", "32");
  model_param_props.addLong("C_NUM_WRITE_OUTSTANDING", "32");
  model_param_props.addLong("C_ENABLE_PIPELINING", "1");
  model_param_props.addString("C_FAMILY", "zynquplus");
  mp_impl = new axi_firewall("inst", model_param_props);

  // initialize sockets
  M_INITIATOR_rd_socket = mp_impl->M_INITIATOR_rd_socket;
  M_INITIATOR_wr_socket = mp_impl->M_INITIATOR_wr_socket;
  S_TARGET_rd_socket = mp_impl->S_TARGET_rd_socket;
  S_TARGET_wr_socket = mp_impl->S_TARGET_wr_socket;
  S_TARGET_CTRL_rd_socket = mp_impl->S_TARGET_CTRL_rd_socket;
  S_TARGET_CTRL_wr_socket = mp_impl->S_TARGET_CTRL_wr_socket;
}

c2c_m_ipb_axi_firewall_0_0_sc::~c2c_m_ipb_axi_firewall_0_0_sc()
{
  xsc::utils::xsc_sim_manager::clean();

  delete mp_impl;
}

