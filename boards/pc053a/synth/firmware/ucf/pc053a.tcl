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



set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Ethernet RefClk (125MHz)
create_clock -period 8.000 -name eth_refclk [get_ports eth_clk_p]

# Ethernet monitor clock hack (62.5MHz)
create_clock -period 16.000 -name clk_dc [get_pins infra/eth/dc_buf/O]

# Area constraints
create_pblock infra
resize_pblock [get_pblocks infra] -add {CLOCKREGION_X1Y4:CLOCKREGION_X1Y4}

set_property PACKAGE_PIN F6 [get_ports eth_clk_p]
set_property PACKAGE_PIN E6 [get_ports eth_clk_n]

set_property LOC GTPE2_CHANNEL_X0Y4 [get_cells -hier -filter {name=~infra/eth/*/gtpe2_i}]

set_property IOSTANDARD LVCMOS33 [get_ports {sfp_*}]
set_property PACKAGE_PIN W17 [get_ports {sfp_los}]
set_property PULLUP TRUE [get_ports {sfp_los}]
set_property PACKAGE_PIN V19 [get_ports {sfp_tx_disable}]
set_property PACKAGE_PIN Y18 [get_ports {sfp_scl}]
set_property PACKAGE_PIN U20 [get_ports {sfp_sda}]
false_path sfp_* eth_refclk

set_property IOSTANDARD LVCMOS33 [get_ports {leds[*]}]
set_property PACKAGE_PIN W22 [get_ports {leds[0]}]
set_property PACKAGE_PIN U22 [get_ports {leds[1]}]
false_path {leds[*]} eth_refclk

set_property IOSTANDARD LVCMOS25 [get_ports {leds_c[*]}]
set_property PACKAGE_PIN B13 [get_ports {leds_c[0]}]
set_property PACKAGE_PIN C13 [get_ports {leds_c[1]}]
set_property PACKAGE_PIN E17 [get_ports {leds_c[2]}]
set_property PACKAGE_PIN F16 [get_ports {leds_c[3]}]
false_path {leds_c[*]} eth_refclk

set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN D14 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN D15 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN E13 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN E14 [get_ports {dip_sw[3]}]
false_path {dip_sw[*]} eth_refclk


# Clocks derived from system clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT2]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks eth_refclk] -group [get_clocks -include_generated_clocks clk_aux] -group [get_clocks -include_generated_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/RXOUTCLK}]] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/TXOUTCLK}]]
