#!/bin/sh
export MODELSIM_ROOT="/opt/mentor/modeltech"
export ISE_VHDL_MTI="/opt/Xilinx/14.6/ISE_DS/ISE/vhdl/mti_se/10.1b/lin64/"
export ISE_VLOG_MTI="/opt/Xilinx/14.6/ISE_DS/ISE/verilog/mti_se/10.1b/lin64/"

vsim -c -do $REPOS_FW_DIR/ipbus/firmware/sim/scripts/setup_project.tcl
cp -r $REPOS_FW_DIR/ipbus/firmware/ethernet/sim/modelsim_fli ./
cd modelsim_fli
./mac_fli_compile.sh
cd ..
ln -s modelsim_fli/mac_fli.so

