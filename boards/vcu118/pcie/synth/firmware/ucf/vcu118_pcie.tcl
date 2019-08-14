#-------------------------------------------------------------------------------
#
#   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#                                     - - -
#
#   Additional information about ipbus-firmare and the list of ipbus-firmware
#   contacts are available at
#
#       https://ipbus.web.cern.ch/ipbus
#
#-------------------------------------------------------------------------------


## VCU118 XDC
#
# Link Width   - x1
# Link Speed   - gen3
# Family       - virtexup
# Part         - xcvu9p
# Package      - flga2104
# Speed grade  - -2L
# PCIe Block   - X1Y2 in clock region X5Y5 (same side, but 4 clk regions lower)
# PCIe Block   - X0Y3 in clock region X0Y8 (opposite side, 5 clk regions across)
## ---------------------------------------------------------------

# FPGA config options
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CONFIG_MODE SPIx8 [current_design]

# Bitstream config options
set_property BITSTREAM.CONFIG.CONFIGRATE 51.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]


# PCIe
create_clock -period 10.000 -name pcie_sys_clk [get_ports pcie_sys_clk_p]
set_property PACKAGE_PIN AC9 [get_ports pcie_sys_clk_p]

set_property IOSTANDARD LVCMOS18 [get_ports pcie_sys_rst_n]
set_property PACKAGE_PIN AM17 [get_ports pcie_sys_rst_n]
set_property PULLUP true [get_ports pcie_sys_rst_n]
set_false_path -from [get_ports pcie_sys_rst_n]

set_property PACKAGE_PIN AA4 [get_ports pcie_rx_p]
set_property PACKAGE_PIN Y7 [get_ports pcie_tx_p]


# External 300 MHz oscillator
create_clock -period 3.333 -name osc_clk [get_ports osc_clk_p]
set_property PACKAGE_PIN F31         [get_ports osc_clk_n] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13N_T2L_N1_GC_QBC_47
set_property IOSTANDARD  DIFF_SSTL12 [get_ports osc_clk_n] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13N_T2L_N1_GC_QBC_47
set_property PACKAGE_PIN G31         [get_ports osc_clk_p] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13P_T2L_N0_GC_QBC_47
set_property IOSTANDARD  DIFF_SSTL12 [get_ports osc_clk_p] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13P_T2L_N0_GC_QBC_47


# LED pin constraints
set_property IOSTANDARD  LVCMOS12 [get_ports {leds[*]}]
set_property PACKAGE_PIN AT32     [get_ports {leds[0]}] ;# Bank  40 VCCO - VCC1V2_FPGA - IO_L19N_T3L_N1_DBC_AD9N_40
set_property PACKAGE_PIN AV34     [get_ports {leds[1]}] ;# Bank  40 VCCO - VCC1V2_FPGA - IO_T2U_N12_40
set_property PACKAGE_PIN AY30     [get_ports {leds[2]}] ;# Bank  40 VCCO - VCC1V2_FPGA - IO_T1U_N12_40
set_property PACKAGE_PIN BB32     [get_ports {leds[3]}] ;# Bank  40 VCCO - VCC1V2_FPGA - IO_L7N_T1L_N1_QBC_AD13N_40


# Clock constraints
create_generated_clock -name axi_clk [get_pins -hierarchical -filter {NAME =~infra/dma/xdma/*/phy_clk_i/bufg_gt_userclk/O}]
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
set_clock_groups -asynch -group [get_clocks -include_generated_clocks axi_clk] -group [get_clocks -include_generated_clocks osc_clk]
set_false_path -from [get_pins infra/clocks/nuke_i_reg/C] -to [get_pins infra/clocks/nuke_d_reg/D]
set_false_path -from [get_pins infra/clocks/rst_reg/C] -to [get_pins infra/clocks/rst_ipb_ctrl_reg/D]
set_false_path -from [get_pins infra/clocks/rst_reg/C] -to [get_pins infra/clocks/rst_ipb_reg/D]

