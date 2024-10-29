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

# System clock (50MHz)
create_clock -period 20.000 -name sysclk [get_ports sysclk_p]

# System clock (250MHz)
create_clock -period 4.000 -name clk [get_ports clk_in_p]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks sysclk] -group [get_clocks -include_generated_clocks clk]

set_property IOSTANDARD LVDS_25 [get_ports {sysclk_* clk_in_* d_in_* clk_out_* d_out_*}]
set_property DIFF_TERM TRUE [get_ports {sysclk_* clk_in_* d_in_*}]
set_property PACKAGE_PIN T9 [get_ports sysclk_p]
set_property PACKAGE_PIN U10 [get_ports sysclk_n]
set_property PACKAGE_PIN U18 [get_ports clk_in_p]
set_property PACKAGE_PIN U19 [get_ports clk_in_n]
set_property PACKAGE_PIN U14 [get_ports d_in_p]
set_property PACKAGE_PIN U15 [get_ports d_in_n]
set_property PACKAGE_PIN N20 [get_ports clk_out_p]
set_property PACKAGE_PIN P20 [get_ports clk_out_n]
set_property PACKAGE_PIN N18 [get_ports d_out_p]
set_property PACKAGE_PIN P19 [get_ports d_out_n]
false_path {d_in_* d_out_*} sysclk

set_property IOSTANDARD LVCMOS25 [get_ports {debug[*]}]
set_property PACKAGE_PIN Y18 [get_ports {debug[0]}]
set_property PACKAGE_PIN V16 [get_ports {debug[1]}]
set_property PACKAGE_PIN Y19 [get_ports {debug[2]}]
set_property PACKAGE_PIN W16 [get_ports {debug[3]}]
set_property PACKAGE_PIN R16 [get_ports {debug[4]}]
set_property PACKAGE_PIN T17 [get_ports {debug[5]}]
set_property PACKAGE_PIN R17 [get_ports {debug[6]}]
set_property PACKAGE_PIN R18 [get_ports {debug[7]}]
set_property PACKAGE_PIN V17 [get_ports {debug[8]}]
set_property PACKAGE_PIN W18 [get_ports {debug[9]}]
set_property PACKAGE_PIN V18 [get_ports {debug[10]}]
set_property PACKAGE_PIN W19 [get_ports {debug[11]}]
false_path {debug[*]} sysclk
