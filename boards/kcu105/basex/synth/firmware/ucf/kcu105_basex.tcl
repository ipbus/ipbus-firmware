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

# Ethernet RefClk (156MHz)
set_property PACKAGE_PIN P6 [get_ports eth_clk_p]
set_property PACKAGE_PIN P5 [get_ports eth_clk_n]
create_clock -period 6.4 -name eth_refclk [get_ports eth_clk_p]

# System clock (125MHz)
set_property IOSTANDARD LVDS [get_ports {sysclk_*}]
set_property PACKAGE_PIN G10 [get_ports sysclk_p]
set_property PACKAGE_PIN F10 [get_ports sysclk_n]
create_clock -period 8 -name sysclk [get_ports sysclk_p]
                                              
set_property LOC GTHE3_CHANNEL_X0Y10 [get_cells -hier -filter {name=~infra/eth/*/*GTHE3_CHANNEL_PRIM_INST}]

# user LEDs
set_property IOSTANDARD LVCMOS18 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AP8 [get_ports {leds[0]}]
set_property PACKAGE_PIN H23 [get_ports {leds[1]}]
set_property PACKAGE_PIN P20 [get_ports {leds[2]}]
set_property PACKAGE_PIN P21 [get_ports {leds[3]}]
false_path {leds[*]} sysclk

# user DIP switches
set_property IOSTANDARD LVCMOS12 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN AN16 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN AN19 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN AP18 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN AN14 [get_ports {dip_sw[3]}]
false_path {dip_sw[*]} sysclk

#set_property IOSTANDARD LVCMOS25 [get_ports {sfp_*}]
#set_property PACKAGE_PIN P19 [get_ports {sfp_los}]
#set_property PACKAGE_PIN Y20 [get_ports {sfp_tx_disable}]
#false_path sfp_* eth_refclk


# Clocks derived from system clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT2]

set_clock_groups -asynchronous -group [get_clocks sysclk] -group [get_clocks -include_generated_clocks clk_aux] -group [get_clocks -include_generated_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ txoutclk*}]]
