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

# System clock (200MHz)
create_clock -period 20.000 -name sysclk [get_ports sysclk]

set_false_path -through [get_pins infra/clocks/rst_reg/Q]
set_false_path -through [get_nets infra/clocks/nuke_i]

set_property IOSTANDARD LVCMOS25 [get_ports sysclk]
set_property PACKAGE_PIN P17 [get_ports sysclk]

set_property IOSTANDARD LVCMOS25 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN M16 [get_ports {leds[0]}]
set_property PACKAGE_PIN M17 [get_ports {leds[1]}]
set_property PACKAGE_PIN L18 [get_ports {leds[2]}]
set_property PACKAGE_PIN M18 [get_ports {leds[3]}]
false_path {leds[*]} sysclk

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
false_path {phy_rstn} sysclk

set_property IOSTANDARD LVCMOS25 [get_ports {cfg[*]}]
set_property PULLUP TRUE [get_ports {cfg[*]}]
set_property PACKAGE_PIN K2 [get_ports {cfg[0]}]
set_property PACKAGE_PIN K1 [get_ports {cfg[1]}]
set_property PACKAGE_PIN J4 [get_ports {cfg[2]}]
set_property PACKAGE_PIN H4 [get_ports {cfg[3]}]

