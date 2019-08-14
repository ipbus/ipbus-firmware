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


# External 300 MHz oscillator
create_clock -period 3.333 -name osc_clk_300 [get_ports osc_clk_300_p]
set_property PACKAGE_PIN F31         [get_ports osc_clk_300_n] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13N_T2L_N1_GC_QBC_47
set_property IOSTANDARD  DIFF_SSTL12 [get_ports osc_clk_300_n] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13N_T2L_N1_GC_QBC_47
set_property PACKAGE_PIN G31         [get_ports osc_clk_300_p] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13P_T2L_N0_GC_QBC_47
set_property IOSTANDARD  DIFF_SSTL12 [get_ports osc_clk_300_p] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13P_T2L_N0_GC_QBC_47

# External 300 MHz oscillator
create_clock -period 8.000 -name osc_clk_125 [get_ports osc_clk_125_p]
set_property PACKAGE_PIN AY23 [get_ports osc_clk_125_n] ;
set_property IOSTANDARD  LVDS [get_ports osc_clk_125_n] ;
set_property PACKAGE_PIN AY24 [get_ports osc_clk_125_p] ;
set_property IOSTANDARD  LVDS [get_ports osc_clk_125_p] ;


# Table 3-29 of UG1224 VCU118 board user guide
# Also /Vivado/2016.4/data/boards/board_files/vcu118/1.0/part0_pins.xml
set_property IOSTANDARD LVCMOS12 [get_ports {leds[*]}]
set_property PACKAGE_PIN AT32 [get_ports {leds[0]}]
set_property PACKAGE_PIN AV34 [get_ports {leds[1]}]
set_property PACKAGE_PIN AY30 [get_ports {leds[2]}]
set_property PACKAGE_PIN BB32 [get_ports {leds[3]}]
set_property PACKAGE_PIN BF32 [get_ports {leds[4]}]
set_property PACKAGE_PIN AU37 [get_ports {leds[5]}]
set_property PACKAGE_PIN AV36 [get_ports {leds[6]}]
set_property PACKAGE_PIN BA37 [get_ports {leds[7]}]
# push-button SW 10 pin GPIO_SW_N
set_property IOSTANDARD LVCMOS18 [get_ports {rst_in[*]}]
set_property PACKAGE_PIN BB24 [get_ports {rst_in[0]}]
set_property PACKAGE_PIN BE23 [get_ports {rst_in[1]}]
set_property PACKAGE_PIN BF22 [get_ports {rst_in[2]}]
set_property PACKAGE_PIN BE22 [get_ports {rst_in[3]}]
set_property PACKAGE_PIN BD23 [get_ports {rst_in[4]}]

# push-button SW 10 pin GPIO_SW_N
set_property IOSTANDARD LVCMOS12 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN B17 [get_ports dip_sw[0]]
set_property PACKAGE_PIN G16 [get_ports dip_sw[1]]
set_property PACKAGE_PIN J16 [get_ports dip_sw[2]]
set_property PACKAGE_PIN D21 [get_ports dip_sw[3]]


# Clock constraints
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]

set_clock_groups -asynchronous -group [ get_clocks -include_generated_clocks osc_clk_300 ] -group [ get_clocks -include_generated_clocks osc_clk_125 ]  -group [ get_clocks -include_generated_clocks sgmii_clk_p ] 


set_false_path -from [get_pins infra/clocks/nuke_i_reg/C] -to [get_pins infra/clocks/nuke_d_reg/D]
set_false_path -from [get_pins infra/clocks/rst_reg/C] -to [get_pins infra/clocks/rst_ipb_ctrl_reg/D]
set_false_path -from [get_pins infra/clocks/rst_reg/C] -to [get_pins infra/clocks/rst_ipb_reg/D]

false_path {leds[*]} osc_clk_300
false_path {rst_in[*]} osc_clk_125
false_path {dip_sw[*]} osc_clk_125
false_path phy_resetb osc_clk_125
false_path phy_mdio osc_clk_125
false_path phy_mdc osc_clk_125

