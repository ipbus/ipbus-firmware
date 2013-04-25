project new minit_240_ipb
project set family virtex5
project set device xc5vtx240t
project set package ff1759
project set speed -2

project set "Other XST Command Line Options" "-use_new_parser yes" -process "Synthesize - XST"
project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

source $::env(REPOS_FW_DIR)/ipbus/firmware/example_designs/scripts/addfiles.tcl

project close

