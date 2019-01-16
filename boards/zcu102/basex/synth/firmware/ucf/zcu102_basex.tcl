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

proc false_path {patt clk} {
    set p [get_ports -quiet $patt -filter {direction != out}]
    if {[llength $p] != 0} {
        set_input_delay 0 -clock [get_clocks $clk] [get_ports $patt -filter {direction != out}]
        set_false_path -from [get_ports $patt -filter {direction != out}]
    }
    set p [get_ports -quiet $patt -filter {direction != in}]
    if {[llength $p] != 0} {
       	set_output_delay 0 -clock [get_clocks $clk] [get_ports $patt -filter {direction != in}]
	    set_false_path -to [get_ports $patt -filter {direction != in}]
	}
}

# Ethernet RefClk (156MHz, scaled to 125 MHz later)
create_clock -period 6.4 -name eth_refclk [get_ports eth_clk_p]

# System clock (125MHz)
create_clock -period 8 -name sysclk [get_ports sysclk_p]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks sysclk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ txoutclk*}]]

# use the top left cage (SFP0) in the onboard quad SFP+ module. eth_tx_p on pin E4, bank 230
set_property LOC GTHE4_CHANNEL_X1Y12 [get_cells -hier -filter {name=~infra/eth/*/*GTHE4_CHANNEL_PRIM_INST}]

# MGT reference clock for bank 230
set_property PACKAGE_PIN C8 [get_ports eth_clk_p]
set_property PACKAGE_PIN C7 [get_ports eth_clk_n]

# MGT reference clock for bank 129
#set_property PACKAGE_PIN L27 [get_ports eth_clk_p]
#set_property PACKAGE_PIN L28 [get_ports eth_clk_n]

set_property IOSTANDARD LVDS_25 [get_ports {sysclk_*}]
set_property PACKAGE_PIN G21 [get_ports sysclk_p]
set_property PACKAGE_PIN F21 [get_ports sysclk_n]

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

set_property IOSTANDARD LVCMOS33 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN AN14 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN AP14 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN AM14 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN AN13 [get_ports {dip_sw[3]}]
false_path {dip_sw[*]} sysclk
