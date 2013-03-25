# Creates a new Questa project for ipbus demo
#
# You will want to amend the path to compiled Xilinx libraries to suit
# your system.
#
# Dave Newbold, April 2011
#
# $Id$

project new ./ ipbus_sim_demo
vmap unisim /opt/xilinx_lib/13.4_64b/unisim
vmap unimacro /opt/xilinx_lib/13.4_64b/unimacro
vmap secureip /opt/xilinx_lib/13.4_64b/secureip
vmap xilinxcorelib /opt/xilinx_lib/13.4_64b/xilinxcorelib

source $::env(REPOS_FW_DIR)/ipbus/firmware/sim/scripts/addfiles_sim.tcl

project calculateorder
project close
quit

