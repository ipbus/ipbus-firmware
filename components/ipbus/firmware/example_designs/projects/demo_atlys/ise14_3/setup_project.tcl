project new demo_atlys
project set family spartan6
project set device xc6slx45
project set package csg324
project set speed -2

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

xfile add firmware/ipbus/firmwareexample_designs/hdl/demo_atlys/top_atlys.vhd
xfile add firmware/ipbus/firmwareexample_designs/ucf/atlys.ucf
xfile add firmware/ipbus/firmwareexample_designs/hdl/clocks_s6_extphy_100MHz.vhd
xfile add firmware/ipbus/firmwareexample_designs/hdl/clock_divider_s6.v
xfile add firmware/ipbus/firmwareethernet/hdl/emac_hostbus_decl.vhd
xfile add firmware/ipbus/firmwareethernet/hdl/eth_s6_gmii.vhd

source firmware/ipbus/firmwareipbus_core/cfg/setup.tcl
source firmware/ipbus/firmwareexample_designs/cfg/setup.tcl

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
