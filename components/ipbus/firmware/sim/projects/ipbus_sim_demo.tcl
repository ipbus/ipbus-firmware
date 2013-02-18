# Runs the ipbus simulator demo
#
# You will need to have the precompiled Xilinx libraries available
# to the simulator.
#
# Dave Newbold, April 2011
#
# $Id$

project open ipbus_sim_demo
vsim -t 1ns work.top
run -all
