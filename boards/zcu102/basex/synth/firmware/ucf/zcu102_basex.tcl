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

# Eth clock: bank 230 MGT RefClk (156MHz, scaled to 125 MHz in the pcs_pma core)
set_property PACKAGE_PIN C8 [get_ports eth_clk_p]
set_property PACKAGE_PIN C7 [get_ports eth_clk_n]
create_clock -period 6.4 -name eth_refclk [get_ports eth_clk_p]

# System clock (125MHz)
set_property IOSTANDARD LVDS_25 [get_ports {sysclk_*}]
set_property PACKAGE_PIN G21 [get_ports sysclk_p]
set_property PACKAGE_PIN F21 [get_ports sysclk_n]
create_clock -period 8 -name sysclk [get_ports sysclk_p]

# use the top right cage (SFP0) in the onboard quad SFP+ module. eth_tx_p on pin E4, bank 230
set_property LOC GTHE4_CHANNEL_X1Y12 [get_cells -hier -filter {name=~infra/eth/*/*GTHE4_CHANNEL_PRIM_INST}]

# SFP0 tx enable
set_property PACKAGE_PIN A12 [get_ports sfp_enable]
set_property IOSTANDARD LVCMOS25 [get_ports sfp_enable]

# user LEDs
set_property IOSTANDARD LVCMOS33 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AG14 [get_ports {leds[0]}]
set_property PACKAGE_PIN AF13 [get_ports {leds[1]}]
set_property PACKAGE_PIN AE13 [get_ports {leds[2]}]
set_property PACKAGE_PIN AJ14 [get_ports {leds[3]}]
set_property PACKAGE_PIN AJ15 [get_ports {leds[4]}]
set_property PACKAGE_PIN AH13 [get_ports {leds[5]}]
set_property PACKAGE_PIN AH14 [get_ports {leds[6]}]
set_property PACKAGE_PIN AL12 [get_ports {leds[7]}]
false_path {leds[*]} sysclk

# user DIP switches
set_property IOSTANDARD LVCMOS33 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN AN14 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN AP14 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN AM14 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN AN13 [get_ports {dip_sw[3]}]
false_path {dip_sw[*]} sysclk

# Clocks derived from system clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT2]

set_clock_groups -asynchronous -group [get_clocks sysclk] -group [get_clocks -include_generated_clocks clk_aux] -group [get_clocks -include_generated_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ txoutclk*}]]
