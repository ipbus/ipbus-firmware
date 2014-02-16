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
project addfile firmware/ipbus/firmware/ipbus_core/hdl/ipbus_bus_decl.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/ipbus_package.vhd
project addfile firmware/ipbus/firmware/ethernet/hdl/emac_hostbus_decl.vhd
project addfile firmware/ipbus/firmware/example_designs/sim_hdl/clock_sim.vhd
project addfile firmware/ipbus/firmware/example_designs/hdl/slaves.vhd
project addfile firmware/ipbus/firmware/example_designs/hdl/ipbus_addr_decode.vhd
project addfile firmware/ipbus/firmware/ethernet/sim/eth_mac_sim.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/rx_buffer.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/tx_buffer.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/arp.v
project addfile firmware/ipbus/firmware/ipbus_core/hdl/icmp.v
project addfile firmware/ipbus/firmware/ipbus_core/hdl/udp_shim.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/ipbus_fabric.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/ipbus_ctrl_udponly.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/ipbus_ctrl_decl.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/ip_checksum_8bit.v
project addfile firmware/ipbus/firmware/ipbus_core/hdl/packet_handler.v
project addfile firmware/ipbus/firmware/ipbus_core/hdl/sub_packetbuffer.v
project addfile firmware/ipbus/firmware/ipbus_core/hdl/sub_packetreq.v
project addfile firmware/ipbus/firmware/ipbus_core/hdl/sub_packetresp.v
project addfile firmware/ipbus/firmware/ipbus_core/hdl/transactor_rx.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/transactor_sm.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/transactor_tx.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/transactor.vhd
project addfile firmware/ipbus/firmware/example_designs/hdl/ipbus_ver.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/slaves/ipbus_reg.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/slaves/ipbus_peephole_ram.vhd
project addfile firmware/ipbus/firmware/ipbus_core/hdl/slaves/ipbus_emac_hostbus.vhd
project addfile firmware/ipbus/firmware/ipbus/coregen/dpram_8x12_32x10.vhd
project addfile firmware/ipbus/firmware/ipbus/coregen/sdpram_8x11.vhd
project addfile firmware/ipbus/firmware/example_designs/sim_hdl/top_sim.vhd
project calculateorder
project close
