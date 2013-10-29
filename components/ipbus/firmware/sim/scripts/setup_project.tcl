# Creates a new Questa project for ipbus demo
#
# You will want to amend the path to compiled Xilinx libraries to suit
# your system.
#
# Dave Newbold, April 2011
#
# $Id$

set xlib_vhdl $::env(ISE_VHDL_MTI)
set xlib_vlog $::env(ISE_VLOG_MTI)

project new ./ ipbus_sim_demo
vmap unisim $xlib_vhdl/unisim
vmap unimacro $xlib_vhdl/unimacro
vmap secureip $xlib_vlog/secureip
vmap xilinxcorelib $xlib_vhdl/xilinxcorelib

source $::env(REPOS_FW_DIR)/ipbus/firmware/sim/scripts/addfiles_sim.tcl

project calculateorder
project close
quit

