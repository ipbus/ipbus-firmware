project new demo_v5fxt
project set family virtex5
project set device xc5vfx30t
project set package ff665
project set speed -3

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

source addfiles.tcl

project close

