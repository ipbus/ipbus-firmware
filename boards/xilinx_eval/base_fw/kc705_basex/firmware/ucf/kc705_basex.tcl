# Ethernet RefClk (125MHz)
create_clock -period 8.000 -name eth_refclk [get_ports eth_clk_p]

# Clock from Ethernet Transceiver (derived from Ethernet RefClk)
create_clock -period 16.000 -name eth_transceiver [get_pins infra/eth/phy/*/gtxe2_i/TXOUTCLK]

# The decoupled_clk is driven from a flip-flop to circumvent Xilinx rules for the ethernet sys clk.
# i.e. sys clk must not be derived from eth refclk so that some monitoring can occur even with reclk failure.
# This is not good design practice, but ned some method to breach design rule.
create_generated_clock -name decoupled_clk -source [get_pins infra/eth/decoupled_clk_src_reg/C] -divide_by 2  [get_pins infra/eth/decoupled_clk_src_reg/Q]

# Ethernet driven by Ethernet txoutclk (i.e. via transceiver)
#create_generated_clock -name eth_clk_62_5 -source [get_pins infra/eth/mmcm/CLKIN1] [get_pins infra/eth/mmcm/CLKOUT1]
#create_generated_clock -name eth_clk_125 -source [get_pins infra/eth/mmcm/CLKIN1] [get_pins infra/eth/mmcm/CLKOUT2]

# Clocks derived from MMCM driven by Ethernet RefClk directly (i.e. not via transceiver)
#create_generated_clock -name clk_ipb -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]

set_false_path -through [get_pins infra/clocks/rst_reg/Q]
set_false_path -through [get_nets infra/clocks/nuke_i]

set_property LOC GTXE2_CHANNEL_X0Y10 [get_cells -hier -filter {name=~infra/eth/*/gtxe2_i}]

set_property IOSTANDARD LVCMOS15 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AB8 [get_ports {leds[0]}]
set_property PACKAGE_PIN AA8 [get_ports {leds[1]}]
set_property PACKAGE_PIN AC9 [get_ports {leds[2]}]
set_property PACKAGE_PIN AB9 [get_ports {leds[3]}]

set_property IOSTANDARD LVCMOS25 [get_ports {sfp_los}]
set_property PACKAGE_PIN P19 [get_ports {sfp_los}]
