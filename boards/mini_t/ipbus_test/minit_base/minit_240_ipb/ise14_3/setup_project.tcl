project new minit_240_ipb
project set family virtex5
project set device xc5vtx240t
project set package ff1759
project set speed -2

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

xfile add firmware/minit_base/hdl/top.vhd
xfile add firmware/minit_base/ucf/minit_240_ipb.ucf
xfile add firmware/ipbus/firmware/example_designs/hdl/clocks_v5_extphy.vhd
xfile add firmware/ipbus/firmware/example_designs/hdl/clock_divider_s6.v
xfile add firmware/ipbus/firmware/ethernet/hdl/emac_hostbus_decl.vhd
xfile add firmware/ipbus/firmware/ethernet/hdl/eth_v5_1000basex.vhd

source firmware/ipbus/firmware/ethernet/cfg/setup_v5_serdes.tcl
source firmware/ipbus/firmware/ipbus_core_v1/cfg/setup.tcl
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

