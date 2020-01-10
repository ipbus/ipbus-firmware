
################################################################
# This is a generated script based on design: c2c_s_ipb
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source c2c_s_ipb_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu9eg-ffvb1156-2-e
   set_property BOARD_PART xilinx.com:zcu102:part0:3.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name c2c_s_ipb

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set gt_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
   ] $gt_clk

  set gt_i [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 gt_i ]

  set gt_o [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 gt_o ]

  set ipb_axi [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 ipb_axi ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {124987000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.PROTOCOL {AXI4} \
   ] $ipb_axi


  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {ipb_axi} \
   CONFIG.ASSOCIATED_RESET {aresetn} \
   CONFIG.FREQ_HZ {124987000} \
 ] $aclk
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set c2c_stat_o [ create_bd_port -dir O -from 2 -to 0 c2c_stat_o ]
  set gtx_stat_o [ create_bd_port -dir O -from 4 -to 0 gtx_stat_o ]
  set ipb_clk_o [ create_bd_port -dir O -type clk ipb_clk_o ]
  set ipb_ic_rst_o [ create_bd_port -dir O -from 0 -to 0 ipb_ic_rst_o ]
  set ipb_periph_rst_o [ create_bd_port -dir O -from 0 -to 0 ipb_periph_rst_o ]

  # Create instance: axi_chip2chip_0, and set properties
  set axi_chip2chip_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_chip2chip:5.0 axi_chip2chip_0 ]
  set_property -dict [ list \
   CONFIG.C_AURORA_WIDTH {1} \
   CONFIG.C_AXI_DATA_WIDTH {64} \
   CONFIG.C_AXI_STB_WIDTH {8} \
   CONFIG.C_EN_AXI_LINK_HNDLR {true} \
   CONFIG.C_INTERFACE_MODE {1} \
   CONFIG.C_INTERFACE_TYPE {2} \
   CONFIG.C_MASTER_FPGA {0} \
   CONFIG.C_M_AXI_ID_WIDTH {0} \
   CONFIG.C_M_AXI_WUSER_WIDTH {0} \
   CONFIG.C_NUM_OF_IO {28} \
   CONFIG.C_SUPPORT_NARROWBURST {true} \
 ] $axi_chip2chip_0

  # Create instance: axi_chip2chip_0_aurora64, and set properties
  set axi_chip2chip_0_aurora64 [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_64b66b:12.0 axi_chip2chip_0_aurora64 ]
  set_property -dict [ list \
   CONFIG.CHANNEL_ENABLE {X1Y10} \
   CONFIG.C_AURORA_LANES {1} \
   CONFIG.C_LINE_RATE {5} \
   CONFIG.C_REFCLK_SOURCE {MGTREFCLK0_of_Quad_X1Y2} \
   CONFIG.C_START_LANE {X1Y10} \
   CONFIG.C_START_QUAD {Quad_X1Y2} \
   CONFIG.SupportLevel {1} \
   CONFIG.drp_mode {Disabled} \
   CONFIG.interface_mode {Streaming} \
 ] $axi_chip2chip_0_aurora64

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
 ] $axi_interconnect_0

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {80.0} \
   CONFIG.CLKOUT1_DRIVES {Buffer} \
   CONFIG.CLKOUT1_JITTER {152.375} \
   CONFIG.CLKOUT1_PHASE_ERROR {222.296} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {31.24} \
   CONFIG.CLKOUT2_DRIVES {Buffer} \
   CONFIG.CLKOUT2_JITTER {138.880} \
   CONFIG.CLKOUT2_PHASE_ERROR {222.296} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {62.48} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_DRIVES {Buffer} \
   CONFIG.CLKOUT4_DRIVES {Buffer} \
   CONFIG.CLKOUT5_DRIVES {Buffer} \
   CONFIG.CLKOUT6_DRIVES {Buffer} \
   CONFIG.CLKOUT7_DRIVES {Buffer} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {62.625} \
   CONFIG.MMCM_CLKIN1_PERIOD {8.001} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {50.125} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {25} \
   CONFIG.MMCM_DIVCLK_DIVIDE {5} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.PRIM_IN_FREQ {124.987} \
   CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
   CONFIG.USE_PHASE_ALIGNMENT {true} \
 ] $clk_wiz_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $util_vector_logic_0

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $util_vector_logic_1

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {5} \
 ] $xlconcat_0

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $xlconcat_1

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {1} \
 ] $xlconstant_1

  # Create interface connections
  connect_bd_intf_net -intf_net GT_DIFF_REFCLK_1 [get_bd_intf_ports gt_clk] [get_bd_intf_pins axi_chip2chip_0_aurora64/GT_DIFF_REFCLK1]
  connect_bd_intf_net -intf_net GT_SERIAL_RX_1 [get_bd_intf_ports gt_i] [get_bd_intf_pins axi_chip2chip_0_aurora64/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net axi_chip2chip_0_AXIS_TX [get_bd_intf_pins axi_chip2chip_0/AXIS_TX] [get_bd_intf_pins axi_chip2chip_0_aurora64/USER_DATA_S_AXIS_TX]
  connect_bd_intf_net -intf_net axi_chip2chip_0_aurora64_GT_SERIAL_TX [get_bd_intf_ports gt_o] [get_bd_intf_pins axi_chip2chip_0_aurora64/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net axi_chip2chip_0_aurora64_USER_DATA_M_AXIS_RX [get_bd_intf_pins axi_chip2chip_0/AXIS_RX] [get_bd_intf_pins axi_chip2chip_0_aurora64/USER_DATA_M_AXIS_RX]
  connect_bd_intf_net -intf_net axi_chip2chip_0_m_axi [get_bd_intf_pins axi_chip2chip_0/m_axi] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_ports ipb_axi] [get_bd_intf_pins axi_interconnect_0/M01_AXI]

  # Create port connections
  connect_bd_net -net aresetn_2 [get_bd_ports aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net axi_chip2chip_0_aurora64_channel_up [get_bd_pins axi_chip2chip_0/axi_c2c_aurora_channel_up] [get_bd_pins axi_chip2chip_0_aurora64/channel_up] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_chip2chip_0_aurora64_gt_pll_lock [get_bd_pins axi_chip2chip_0_aurora64/gt_pll_lock] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_chip2chip_0_aurora64_hard_err [get_bd_pins axi_chip2chip_0_aurora64/hard_err] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net axi_chip2chip_0_aurora64_lane_up [get_bd_pins axi_chip2chip_0_aurora64/lane_up] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net axi_chip2chip_0_aurora64_mmcm_not_locked_out [get_bd_pins axi_chip2chip_0/aurora_mmcm_not_locked] [get_bd_pins axi_chip2chip_0_aurora64/mmcm_not_locked_out]
  connect_bd_net -net axi_chip2chip_0_aurora64_soft_err [get_bd_pins axi_chip2chip_0_aurora64/soft_err] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net axi_chip2chip_0_aurora64_user_clk_out [get_bd_pins axi_chip2chip_0/axi_c2c_phy_clk] [get_bd_pins axi_chip2chip_0_aurora64/user_clk_out]
  connect_bd_net -net axi_chip2chip_0_aurora_pma_init_out [get_bd_pins axi_chip2chip_0/aurora_pma_init_out] [get_bd_pins axi_chip2chip_0_aurora64/pma_init]
  connect_bd_net -net axi_chip2chip_0_aurora_reset_pb [get_bd_pins axi_chip2chip_0/aurora_reset_pb] [get_bd_pins axi_chip2chip_0_aurora64/reset_pb]
  connect_bd_net -net axi_chip2chip_0_axi_c2c_config_error_out [get_bd_pins axi_chip2chip_0/axi_c2c_config_error_out] [get_bd_pins xlconcat_1/In0]
  connect_bd_net -net axi_chip2chip_0_axi_c2c_link_status_out [get_bd_pins axi_chip2chip_0/axi_c2c_link_status_out] [get_bd_pins xlconcat_1/In1]
  connect_bd_net -net axi_chip2chip_0_axi_c2c_multi_bit_error_out [get_bd_pins axi_chip2chip_0/axi_c2c_multi_bit_error_out] [get_bd_pins xlconcat_1/In2]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_ports ipb_clk_o] [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net clk_wiz_0_clk_out2 [get_bd_pins axi_chip2chip_0/aurora_init_clk] [get_bd_pins axi_chip2chip_0_aurora64/init_clk] [get_bd_pins clk_wiz_0/clk_out2]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_1/dcm_locked]
  connect_bd_net -net m_aclk_0_1 [get_bd_ports aclk] [get_bd_pins axi_chip2chip_0/m_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_chip2chip_0/m_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_1_interconnect_aresetn [get_bd_pins proc_sys_reset_1/interconnect_aresetn] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_ports ipb_ic_rst_o] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_ports ipb_periph_rst_o] [get_bd_pins util_vector_logic_1/Res]
  connect_bd_net -net xlconcat_0_dout [get_bd_ports gtx_stat_o] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconcat_1_dout [get_bd_ports c2c_stat_o] [get_bd_pins xlconcat_1/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins clk_wiz_0/reset] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins xlconstant_1/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0xA1010000 [get_bd_addr_spaces axi_chip2chip_0/MAXI] [get_bd_addr_segs ipb_axi/Reg] SEG_ipb_axi_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


