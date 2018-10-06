
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

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

# Ethernet RefClk (125MHz)
create_clock -period 8.000 -name eth_refclk [get_ports eth_clk_p]

# Ethernet monitor clock hack (62.5MHz)
create_clock -period 16.000 -name clk_dc [get_pins infra/eth/dc_buf/O]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks eth_refclk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/RXOUTCLK}]] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/TXOUTCLK}]]

set_property PACKAGE_PIN F6 [get_ports eth_clk_p]
set_property PACKAGE_PIN E6 [get_ports eth_clk_n]

set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells -hier -filter {name=~infra/eth/*/gtpe2_i}]

set_property IOSTANDARD LVCMOS33 [get_ports {sfp_*}]
set_property PACKAGE_PIN B21 [get_ports {sfp_los}]
set_property PACKAGE_PIN A19 [get_ports {sfp_tx_disable}]
false_path sfp_* eth_refclk

set_property IOSTANDARD LVCMOS33 [get_ports {leds[*]}]
set_property PACKAGE_PIN F21 [get_ports {leds[0]}]
set_property PACKAGE_PIN F20 [get_ports {leds[1]}]
set_property PACKAGE_PIN C15 [get_ports {leds[2]}]
set_property PACKAGE_PIN C14 [get_ports {leds[3]}]
set_property PACKAGE_PIN C13 [get_ports {leds[4]}]
set_property PACKAGE_PIN C19 [get_ports {leds[5]}]
set_property PACKAGE_PIN C18 [get_ports {leds[6]}]
set_property PACKAGE_PIN C17 [get_ports {leds[7]}]
false_path {leds[*]} eth_refclk

#set_property IOSTANDARD LVCMOS33 [get_ports {dip_sw[*]}]
#set_property PACKAGE_PIN AA18 [get_ports {dip_sw[0]}]
#set_property PACKAGE_PIN AA19 [get_ports {dip_sw[1]}]
#set_property PACKAGE_PIN AA20 [get_ports {dip_sw[2]}]
#set_property PACKAGE_PIN AA21 [get_ports {dip_sw[3]}]
#false_path {dip_sw[*]} eth_refclk

