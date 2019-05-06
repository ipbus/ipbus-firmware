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


# Bitstream config options
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]


# System clock (200MHz)
create_clock -period 20.000 -name osc_clk [get_ports osc_clk]
set_property IOSTANDARD LVCMOS25 [get_ports osc_clk]
set_property PACKAGE_PIN P17 [get_ports osc_clk]


# RGMII pin constraints
set_property IOSTANDARD LVCMOS25 [get_ports {rgmii_* phy_rstn}]
set_property PACKAGE_PIN R18 [get_ports {rgmii_txd[0]}]
set_property PACKAGE_PIN T18 [get_ports {rgmii_txd[1]}]
set_property PACKAGE_PIN U17 [get_ports {rgmii_txd[2]}]
set_property PACKAGE_PIN U18 [get_ports {rgmii_txd[3]}]
set_property PACKAGE_PIN T16 [get_ports {rgmii_tx_ctl}]
set_property PACKAGE_PIN N16 [get_ports {rgmii_txc}]
set_property PACKAGE_PIN U16 [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN V17 [get_ports {rgmii_rxd[1]}]
set_property PACKAGE_PIN V15 [get_ports {rgmii_rxd[2]}]
set_property PACKAGE_PIN V16 [get_ports {rgmii_rxd[3]}]
set_property PACKAGE_PIN R16 [get_ports {rgmii_rx_ctl}]
set_property PACKAGE_PIN T14 [get_ports {rgmii_rxc}]
set_property PACKAGE_PIN M13 [get_ports {phy_rstn}]
false_path {phy_rstn} osc_clk


# LED pin constraints
set_property IOSTANDARD LVCMOS25 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN M16 [get_ports {leds[0]}]
set_property PACKAGE_PIN M17 [get_ports {leds[1]}]
set_property PACKAGE_PIN L18 [get_ports {leds[2]}]
set_property PACKAGE_PIN M18 [get_ports {leds[3]}]
false_path {leds[*]} osc_clk


# Configuration pins
if { [llength [get_ports {cfg[*]}]] > 0} {
  set_property IOSTANDARD LVCMOS25 [get_ports {cfg[*]}]
  set_property PULLUP TRUE [get_ports {cfg[*]}]
  set_property PACKAGE_PIN K2 [get_ports {cfg[0]}]
  set_property PACKAGE_PIN K1 [get_ports {cfg[1]}]
  set_property PACKAGE_PIN J4 [get_ports {cfg[2]}]
  set_property PACKAGE_PIN H4 [get_ports {cfg[3]}]
}


# Clock constraints
set_false_path -through [get_pins infra/clocks/rst_reg/Q]
set_false_path -through [get_nets infra/clocks/nuke_i]

# Ethernet clock
create_generated_clock -name clk_125 -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
create_generated_clock -name clk_125_90 -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT2]

# IPbus clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT3]

# 200 Mhz derived clock
create_generated_clock -name clk_200 -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT4]

# 40 Mhz derived clock
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT5]


set_clock_groups -asynchronous -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_aux]]


