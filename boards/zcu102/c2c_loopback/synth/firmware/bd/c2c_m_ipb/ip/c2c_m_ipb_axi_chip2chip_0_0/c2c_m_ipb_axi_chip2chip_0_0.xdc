
# file: c2c_m_ipb_axi_chip2chip_0_0.xdc
# (c) Copyright 2009 - 2011 Xilinx, Inc. All rights reserved.
# 
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
# 
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
# 
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
# 
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.




#Independent BRAM FIFO constraints in MASTER INDEPENDENT mode
#BRAM FIFO constraints in MASTER mode for R-FIFO - always in asynch mode
#Independent DIST RAM FIFO constraints in MASTER mode - always in asynch mode
##set_false_path -to [get_pins -hierarchical -filter {NAME =~*/*rstblk*/*CLR}]
set_false_path -from [get_cells -hierarchical -filter {NAME =~*/axi_chip2chip_ch0_ctrl_inst/intr_data_reg[*]}]

set_false_path -from [get_pins -filter {REF_PIN_NAME=~C} -of_objects [get_cells -hierarchical -filter {NAME =~*/axi_chip2chip_ch0_ctrl_inst/*slave_ecc_intr*}]]
##set_false_path -to [get_pins -hierarchical -filter {NAME =~*/*rstblk*/*CLR}]

#$This is added for the R Pin where it is timed for both Rising & Falling Edge of the Clock
################################################################################

set_false_path -to [get_pins -filter {REF_PIN_NAME=~PRE} -of_objects [get_cells -hierarchical -filter {NAME =~*master_fpga_gen.axi_chip2chip_master_phy_inst/axi_chip2chip_phy_init_inst/auro_phy_init.aurora_rst_out*_reg}]]
set_max_delay -from [get_pins -filter {REF_PIN_NAME=~C} -of_objects [get_cells -hierarchical -filter {NAME=~*master_fpga_gen.axi_chip2chip_master_phy_inst/axi_chip2chip_phy_init_inst/calib_done_flop_reg}]] -to [get_pins -filter {REF_PIN_NAME=~D} -of_objects [get_cells -hierarchical -filter {NAME=~*master_fpga_gen.axi_chip2chip_master_phy_inst/axi_chip2chip_phy_init_inst/sync_cell_master.axi_chip2chip_sync_cell_inst/sync_flop_0_reg*[*]}]] -datapath_only 10.000
set_max_delay -from [get_pins -filter {REF_PIN_NAME=~C} -of_objects [get_cells -hierarchical -filter {NAME=~*master_fpga_gen.axi_chip2chip_master_phy_inst/axi_chip2chip_phy_init_inst/phy_error_flop*}]] -to [get_pins -filter {REF_PIN_NAME=~D} -of_objects [get_cells -hierarchical -filter {NAME=~*master_fpga_gen.axi_chip2chip_master_phy_inst/axi_chip2chip_phy_init_inst/sync_cell_master.axi_chip2chip_sync_cell_inst/sync_*0*[*]}]] -datapath_only 10.000
set_max_delay -from [get_pins -filter {REF_PIN_NAME=~C} -of_objects [get_cells -hierarchical -filter {NAME=~*master_fpga_gen.axi_chip2chip_master_inst/aurora_ecc_io_stage.rx_ecc_dec_error_flop_reg}]] -to [get_pins -filter {REF_PIN_NAME=~D} -of_objects [get_cells -hierarchical -filter {NAME=~*master_fpga_gen.axi_chip2chip_master_inst/aurora_ecc_io_stage.axi_chip2chip_sync_cell_master_ecc_err_inst/sync_flop_0_reg[0]}]] -datapath_only 10.000
set_false_path -from [get_pins -filter {REF_PIN_NAME=~C} -of_objects [get_cells -hierarchical -filter {NAME =~*/*fifo_reset_reg}]]
set_false_path -to [get_pins -filter {REF_PIN_NAME=~PRE} -of_objects [get_cells -hierarchical -filter {NAME =~*/*fifo_reset_reg}]]
set_false_path -to [get_pins -filter {REF_PIN_NAME=~PRE} -of_objects [get_cells -hierarchical -filter {NAME =~*/*sync_reset*}]]
set_false_path -to [get_pins -filter {REF_PIN_NAME=~D} -of_objects [get_cells -hierarchical -filter {NAME =~*axi_chip2chip_sync_cell*sync_flop_0*}]]
