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



set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

# PCIe
create_clock -period 10.000 -name pcie_sys_clk [get_ports pcie_sys_clk_p]
set_property PACKAGE_PIN AK10 [get_ports pcie_sys_clk_p]

set_property IOSTANDARD LVCMOS18 [get_ports pcie_sys_rst]
set_property PACKAGE_PIN AE15 [get_ports pcie_sys_rst]
set_false_path -from [get_ports pcie_sys_rst]

set_property PACKAGE_PIN AM2 [get_ports pcie_rx_p]
set_property PACKAGE_PIN AM6 [get_ports pcie_tx_p]


# EXTERNAL OSCILLATOR:
# - based on an ICS8N4Q001L clock generator,
#   hard-wired to use the first frequency setting, which defaults to 170
#   MHz according to datasheet, or 200 MHz according to user guide and
#   schematics.
# - 1.8V differential signal
# - connected to an HR bank (-> use LVDS_25 instead of LVDS)
create_clock -period 5.000 -name osc_clk [get_ports osc_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports osc_clk_p]
set_property PACKAGE_PIN AL12 [get_ports osc_clk_p]
set_property PACKAGE_PIN AM12 [get_ports osc_clk_n]


# LED pin constraints
set_property IOSTANDARD LVCMOS15 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN J31 [get_ports {leds[0]}]
set_property PACKAGE_PIN H31 [get_ports {leds[1]}]
set_property PACKAGE_PIN J29 [get_ports {leds[2]}]
set_property PACKAGE_PIN G31 [get_ports {leds[3]}]


# Clock constraints
create_generated_clock -name axi_clk [get_pins -hierarchical -filter {NAME =~infra/dma/xdma/*/phy_clk_i/bufg_gt_userclk/O}]
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
set_clock_groups -asynch -group [get_clocks -include_generated_clocks axi_clk] -group [get_clocks -include_generated_clocks osc_clk]
set_false_path -from [get_pins infra/clocks/nuke_i_reg/C] -to [get_pins infra/clocks/nuke_d_reg/D]
set_false_path -from [get_pins infra/clocks/rst_reg/C] -to [get_pins infra/clocks/rst_ipb_ctrl_reg/D]
set_false_path -from [get_pins infra/clocks/rst_reg/C] -to [get_pins infra/clocks/rst_ipb_reg/D]
