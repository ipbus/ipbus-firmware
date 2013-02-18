project new demo_sp605_extphy
project set family spartan6
project set device xc6slx45t
project set package fgg484
project set speed -3

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

xfile add firmware/ipbus/firmware/example_designs/hdl/demo_sp605_extphy/top_sp605_extphy.vhd
xfile add firmware/ipbus/firmware/example_designs/ucf/sp605_extphy.ucf
xfile add firmware/ipbus/firmware/example_designs/hdl/clocks_s6_extphy.vhd
xfile add firmware/ipbus/firmware/example_designs/hdl/clock_divider_s6.v
xfile add firmware/ipbus/firmware/ethernet/hdl/emac_hostbus_decl.vhd
xfile add firmware/ipbus/firmware/ethernet/hdl/eth_s6_gmii.vhd

source firmware/ipbus/firmware/ipbus_core/cfg/setup.tcl
source firmware/ipbus/firmware/example_designs/cfg/setup.tcl

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
