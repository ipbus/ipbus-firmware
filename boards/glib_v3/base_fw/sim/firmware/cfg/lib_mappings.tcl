set xlib_vhdl $::env(ISE_VHDL_MTI)
set xlib_vlog $::env(ISE_VLOG_MTI)
vmap unisim $xlib_vhdl/unisim
vmap unimacro $xlib_vhdl/unimacro
vmap secureip $xlib_vlog/secureip
vmap xilinxcorelib $xlib_vhdl/xilinxcorelib

