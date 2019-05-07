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


set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]


# Ethernet RefClk (125MHz)
create_clock -period 8.000 -name eth_refclk [get_ports eth_clk_p]

# Ethernet monitor clock hack (62.5MHz)
create_clock -period 16.000 -name clk_dc [get_pins infra/eth/decoupled_clk_reg/Q]

# Ethernet constraints
set_property PACKAGE_PIN G8 [get_ports eth_clk_p]
set_property PACKAGE_PIN G7 [get_ports eth_clk_n]
set_property LOC GTXE2_CHANNEL_X0Y10 [get_cells -hier -filter {name=~infra/eth/*/gtxe2_i}]


# LED pin assignment
set_property IOSTANDARD LVCMOS15 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AB8 [get_ports {leds[0]}]
set_property PACKAGE_PIN AA8 [get_ports {leds[1]}]
set_property PACKAGE_PIN AC9 [get_ports {leds[2]}]
set_property PACKAGE_PIN AB9 [get_ports {leds[3]}]
false_path {leds[*]} eth_refclk

# DIP switch pin assignment
set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN Y29 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN W29 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN AA28 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN Y28 [get_ports {dip_sw[3]}]
false_path {dip_sw[*]} eth_refclk

# SFP 
set_property IOSTANDARD LVCMOS25 [get_ports {sfp_*}]
set_property PACKAGE_PIN P19 [get_ports {sfp_los}]
set_property PACKAGE_PIN Y20 [get_ports {sfp_tx_disable}]
false_path sfp_* eth_refclk


# IPbus clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]

# Other derived clocks
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT2]
create_generated_clock -name clk_200 -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT3]

set_false_path -through [get_pins infra/clocks/rst_reg/Q]
set_false_path -through [get_nets infra/clocks/nuke_i]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks eth_refclk] -group [get_clocks clk_dc] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/RXOUTCLK}]] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/TXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_aux]]
