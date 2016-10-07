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
create_clock -period 6.4 -name eth_refclk [get_ports eth_clk_p]

# System clock (125MHz)
create_clock -period 8 -name sysclk [get_ports sysclk_p]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks sysclk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/rxoutclk*}]] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ txoutclk*}]]
                                                 
set_property LOC GTHE3_CHANNEL_X0Y10 [get_cells -hier -filter {name=~infra/eth/*/*GTHE3_CHANNEL_PRIM_INST}]

set_property PACKAGE_PIN P6 [get_ports eth_clk_p]
set_property PACKAGE_PIN P5 [get_ports eth_clk_n]

set_property IOSTANDARD LVDS_25 [get_ports {sysclk_*}]
set_property PACKAGE_PIN P26 [get_ports sysclk_p]
set_property PACKAGE_PIN N26 [get_ports sysclk_n]

set_property IOSTANDARD LVCMOS18 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AP8 [get_ports {leds[0]}]
set_property PACKAGE_PIN H23 [get_ports {leds[1]}]
set_property PACKAGE_PIN P20 [get_ports {leds[2]}]
set_property PACKAGE_PIN P21 [get_ports {leds[3]}]
false_path {leds[*]} sysclk

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
