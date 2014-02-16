project new demo_atlys
project set family spartan6
project set device xc6slx45
project set package csg324
project set speed -2

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

source $::env(REPOS_FW_DIR)/ipbus/firmware/example_designs/scripts/addfiles.tcl

project close

