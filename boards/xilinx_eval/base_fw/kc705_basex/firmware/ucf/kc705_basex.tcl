# Ethernet RefClk (125MHz)
create_clock -period 8.000 -name eth_refclk [get_ports eth_clk_p]

# Ethernet monitor clock hack (62.5MHz)
create_clock -period 16.000 -name clk_dc [get_pins infra/eth/decoupled_clk_reg/Q]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks eth_refclk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/RXOUTCLK}]] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/TXOUTCLK}]]

# Ethernet driven by Ethernet txoutclk (i.e. via transceiver)
#create_generated_clock -name eth_clk_62_5 -source [get_pins infra/eth/mmcm/CLKIN1] [get_pins infra/eth/mmcm/CLKOUT1]
#create_generated_clock -name eth_clk_125 -source [get_pins infra/eth/mmcm/CLKIN1] [get_pins infra/eth/mmcm/CLKOUT2]

# Clocks derived from MMCM driven by Ethernet RefClk directly (i.e. not via transceiver)
#create_generated_clock -name clk_ipb -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]

#set_false_path -through [get_pins infra/clocks/rst_reg/Q]
#set_false_path -through [get_nets infra/clocks/nuke_i]

set_property LOC GTXE2_CHANNEL_X0Y10 [get_cells -hier -filter {name=~infra/eth/*/gtxe2_i}]

set_property IOSTANDARD LVCMOS15 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AB8 [get_ports {leds[0]}]
set_property PACKAGE_PIN AA8 [get_ports {leds[1]}]
set_property PACKAGE_PIN AC9 [get_ports {leds[2]}]
set_property PACKAGE_PIN AB9 [get_ports {leds[3]}]

set_property IOSTANDARD LVCMOS25 [get_ports {sfp_los}]
set_property PACKAGE_PIN P19 [get_ports {sfp_los}]
