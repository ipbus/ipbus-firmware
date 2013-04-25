project new mp7_485
project set family virtex7
project set device xc7vx485t
project set package ffg1927
project set speed -2

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

source $::env(REPOS_FW_DIR)/ipbus/firmware/example_designs/scripts/addfiles.tcl

project close

