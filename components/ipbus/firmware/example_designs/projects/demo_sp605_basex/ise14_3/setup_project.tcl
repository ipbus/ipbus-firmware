project new demo_sp605_basex
project set family spartan6
project set device xc6slx45t
project set package fgg484
project set speed -3

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

xfile add firmware/example_designs/hdl/demo_sp605_basex/top_sp605_basex.vhd
xfile add firmware/example_designs/ucf/sp605_basex.ucf
xfile add firmware/example_designs/hdl/clocks_s6_basex.vhd
xfile add firmware/example_designs/hdl/clock_divider_s6.v
xfile add firmware/ethernet/hdl/emac_hostbus_decl.vhd
xfile add firmware/ethernet/hdl/eth_s6_1000basex.vhd

source firmware/ipbus_core/cfg/setup.tcl
source firmware/example_designs/cfg/setup.tcl
source firmware/ethernet/cfg/setup_gig_eth_pcs_pma_v11_4.tcl

set fp [open cores_list r]
set files [read $fp]
close $fp
set flist [split $files "\n"]
foreach f $flist {
	if {$f eq ""} continue
	set fb [exec basename $f]
	xfile add ipcore_dir/$fb
}

project close
