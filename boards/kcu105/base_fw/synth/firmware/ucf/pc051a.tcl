
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Ethernet RefClk (125MHz)
create_clock -period 8.000 -name eth_refclk [get_ports eth_clk_p]

# Ethernet monitor clock hack (62.5MHz)
create_clock -period 16.000 -name clk_dc [get_pins infra/eth/dc_buf/O]

# System synchronous clock (40MHz nominal)
create_clock -period 25.000 -name clk40 [get_ports clk40_p]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks clk40] -group [get_clocks -include_generated_clocks eth_refclk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/RXOUTCLK}]] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/TXOUTCLK}]]

# Area constraints
create_pblock infra
resize_pblock [get_pblocks infra] -add {CLOCKREGION_X1Y4:CLOCKREGION_X1Y4}
#add_cells_to_pblock [get_pblocks infra] [get_cells -quiet [list infra]]

create_pblock chans
resize_pblock [get_pblocks chans] -add {CLOCKREGION_X0Y3:CLOCKREGION_X0Y3}
#add_cells_to_pblock [get_pblocks chans] [get_cells -quiet [list payload]]
#remove_cells_from_pblock [get_pblocks chans] [get_cells payload/idelctrl]

set_property PACKAGE_PIN F6 [get_ports eth_clk_p]
set_property PACKAGE_PIN E6 [get_ports eth_clk_n]

set_property LOC GTPE2_CHANNEL_X0Y4 [get_cells -hier -filter {name=~infra/eth/*/gtpe2_i}]

proc false_path {patt clk} {
    set p [get_ports -quiet $patt -filter {direction != out}]
    if {llength $p != 0} {
        set_input_delay 0 -clock [get_clocks $clk] [get_ports $patt -filter {direction != out}]
        set_false_path -from [get_ports $patt -filter {direction != out}]
    }
    set p [get_ports -quiet $patt -filter {direction != in}]
    if {llength $p != 0} {
       	set_output_delay 0 -clock [get_clocks $clk] [get_ports $patt -filter {direction != in}]
	    set_false_path -to [get_ports $patt -filter {direction != in}]
	}
}

set_property IOSTANDARD LVCMOS33 [get_ports {sfp_*}]
set_property PACKAGE_PIN W17 [get_ports {sfp_los}]
set_property PULLUP TRUE [get_ports {sfp_los}]
set_property PACKAGE_PIN V19 [get_ports {sfp_tx_disable}]
set_property PACKAGE_PIN Y18 [get_ports {sfp_scl}]
set_property PACKAGE_PIN U20 [get_ports {sfp_sda}]
false_path sfp_* eth_refclk
#set_input_delay 0 -clock [get_clocks eth_refclk] [get_ports sfp_* -filter {direction != out}]
#set_false_path -from [get_ports sfp_* -filter {direction != out}]
#set_output_delay 0 -clock [get_clocks eth_refclk] [get_ports sfp_* -filter {direction != in}]
#set_false_path -to [get_ports sfp_* -filter {direction != in}]

set_property IOSTANDARD LVCMOS33 [get_ports {leds[*]}]
set_property PACKAGE_PIN W22 [get_ports {leds[0]}]
set_property PACKAGE_PIN U22 [get_ports {leds[1]}]
false_path {leds[*]} eth_refclk
#set_output_delay 0 -clock [get_clocks eth_refclk] [get_ports {leds[*]}]
#set_false_path -to [get_ports {leds[*]}]

set_property IOSTANDARD LVCMOS25 [get_ports {leds_c[*]}]
set_property PACKAGE_PIN B13 [get_ports {leds_c[0]}]
set_property PACKAGE_PIN C13 [get_ports {leds_c[1]}]
set_property PACKAGE_PIN E17 [get_ports {leds_c[2]}]
set_property PACKAGE_PIN F16 [get_ports {leds_c[3]}]
false_path {leds_c[*]} eth_refclk
#set_output_delay 0 -clock [get_clocks eth_refclk] [get_ports {leds_c[*]}]
#set_false_path -to [get_ports {leds_c[*]}]

set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN E14 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN E13 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN D15 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN D14 [get_ports {dip_sw[3]}]
false_path {dip_sw[*]} eth_refclk
#set_input_delay 0 -clock [get_clocks eth_refclk] [get_ports {dip_sw[*]}]
#set_false_path -from [get_ports {dip_sw[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports {si5326_*}]
set_property PACKAGE_PIN T18 [get_ports {si5326_scl}]
set_property PACKAGE_PIN R18 [get_ports {si5326_sda}]
set_property PACKAGE_PIN R19 [get_ports {si5326_rstn}]
set_property PACKAGE_PIN U18 [get_ports {si5326_phase_inc}]
set_property PACKAGE_PIN U17 [get_ports {si5326_phase_dec}]
set_property PACKAGE_PIN P16 [get_ports {si5326_clk1_validn}]
set_property PACKAGE_PIN R17 [get_ports {si5326_clk2_validn}]
set_property PACKAGE_PIN Y21 [get_ports {si5326_lol}]
set_property PACKAGE_PIN Y19 [get_ports {si5326_clk_sel}]
set_property PACKAGE_PIN P19 [get_ports {si5326_rate0}]
set_property PACKAGE_PIN U21 [get_ports {si5326_rate1}]
false_path {si5326_*} eth_refclk
#set_input_delay 0 -clock [get_clocks eth_refclk] [get_ports si5326_* -filter {direction != out}]
#set_false_path -from [get_ports si5326_* -filter {direction != out}]
#set_output_delay 0 -clock [get_clocks eth_refclk] [get_ports si5326_* -filter {direction != in}]
#set_false_path -to [get_ports si5326_* -filter {direction != in}]

set_property IOSTANDARD LVCMOS33 [get_ports {analog_*}]
set_property PACKAGE_PIN Y22 [get_ports {analog_scl}]
set_property PACKAGE_PIN T21 [get_ports {analog_sda}]
false_path {analog_*} eth_refclk
#set_input_delay 0 -clock [get_clocks eth_refclk] [get_ports analog_* -filter {direction != out}]
#set_false_path -from [get_ports analog_* -filter {direction != out}]
#set_output_delay 0 -clock [get_clocks eth_refclk] [get_ports analog_* -filter {direction != in}]
#set_false_path -to [get_ports analog_* -filter {direction != in}]

set_property IOSTANDARD LVDS_25 [get_ports {clk40_*}]
set_property PACKAGE_PIN W11 [get_ports {clk40_p}]
set_property PACKAGE_PIN W12 [get_ports {clk40_n}]

set_property IOSTANDARD LVCMOS18 [get_ports {adc_spi_*}]
set_property PACKAGE_PIN Y12 [get_ports {adc_spi_sclk}]
set_property PACKAGE_PIN Y11 [get_ports {adc_spi_mosi}]
set_property PACKAGE_PIN AB13 [get_ports {adc_spi_miso[0]}]
set_property PACKAGE_PIN AA13 [get_ports {adc_spi_miso[1]}]
set_property PACKAGE_PIN AA11 [get_ports {adc_spi_cs[0]}]
set_property PACKAGE_PIN AA10 [get_ports {adc_spi_cs[1]}]
false_path {adc_spi__*} eth_refclk
#set_input_delay 0 -clock [get_clocks eth_refclk] [get_ports adc_spi_* -filter {direction != out}]
#set_output_delay 0 -clock [get_clocks eth_refclk] [get_ports adc_spi_* -filter {direction != in}]
#set_false_path -to [get_ports adc_spi_* -filter {direction != in}]

set_property IOSTANDARD LVDS_25 [get_ports {adc_d_*}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[0]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[1]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[2]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[3]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[4]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[5]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[6]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[7]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[8]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[9]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[10]}]
set_property DIFF_TERM TRUE [get_ports {adc_d_*[11]}]
set_property PACKAGE_PIN F19 [get_ports {adc_d_p[0]}]
set_property PACKAGE_PIN F20 [get_ports {adc_d_n[0]}]
set_property PACKAGE_PIN E21 [get_ports {adc_d_p[1]}]
set_property PACKAGE_PIN D21 [get_ports {adc_d_n[1]}]
set_property PACKAGE_PIN B21 [get_ports {adc_d_p[2]}]
set_property PACKAGE_PIN A21 [get_ports {adc_d_n[2]}]
set_property PACKAGE_PIN C22 [get_ports {adc_d_p[3]}]
set_property PACKAGE_PIN B22 [get_ports {adc_d_n[3]}]
set_property PACKAGE_PIN B17 [get_ports {adc_d_p[4]}]
set_property PACKAGE_PIN B18 [get_ports {adc_d_n[4]}]
set_property PACKAGE_PIN E19 [get_ports {adc_d_p[5]}]
set_property PACKAGE_PIN D19 [get_ports {adc_d_n[5]}]
set_property PACKAGE_PIN A13 [get_ports {adc_d_p[6]}]
set_property PACKAGE_PIN A14 [get_ports {adc_d_n[6]}]
set_property PACKAGE_PIN C14 [get_ports {adc_d_p[7]}]
set_property PACKAGE_PIN C15 [get_ports {adc_d_n[7]}]
set_property PACKAGE_PIN A15 [get_ports {adc_d_p[8]}]
set_property PACKAGE_PIN A16 [get_ports {adc_d_n[8]}]
set_property PACKAGE_PIN B15 [get_ports {adc_d_p[9]}]
set_property PACKAGE_PIN B16 [get_ports {adc_d_n[9]}]
set_property PACKAGE_PIN C18 [get_ports {adc_d_p[10]}]
set_property PACKAGE_PIN C19 [get_ports {adc_d_n[10]}]
set_property PACKAGE_PIN D17 [get_ports {adc_d_p[11]}]
set_property PACKAGE_PIN C17 [get_ports {adc_d_n[11]}]
false_path {adc_d_*} eth_refclk
#set_input_delay 0 -clock [get_clocks clk40] [get_ports adc_d_*]
#set_false_path -from [get_ports adc_d_*]
