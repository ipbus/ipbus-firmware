project new demo_v5fxt
project set family virtex5
project set device xc5vfx30t
project set package ff665
project set speed -3

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

xfile add firmware/example_designs/hdl/demo_v5fxt/top_v5fxt.vhd
xfile add firmware/example_designs/ucf/v5fxt.ucf
xfile add firmware/example_designs/hdl/clocks_v5_extphy.vhd
xfile add firmware/example_designs/hdl/clock_divider_s6.v
xfile add firmware/ethernet/hdl/emac_hostbus_decl.vhd
xfile add firmware/ethernet/hdl/eth_v5_gmii.vhd
xfile add firmware/ethernet/hdl/mac_arbiter_decl.vhd
xfile add firmware/ethernet/hdl/mac_arbiter.vhd

source firmware/ethernet/cfg/setup_v5_gmii.tcl
source firmware/ipbus_core_v1/cfg/setup.tcl
source firmware/example_designs/cfg/setup.tcl

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

