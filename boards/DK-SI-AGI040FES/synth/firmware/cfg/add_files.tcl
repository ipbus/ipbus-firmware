set path_script [file dirname [file normalize [info script]]]
set path_src [file join {*}[lrange [file split $path_script] 0 end-5]]

# ==== Top ====

set_global_assignment -name VHDL_FILE $path_src/boards/DK-SI-AGI040FES/synth/firmware/hdl/top.vhd
set_global_assignment -name TOP_LEVEL_ENTITY top

# ==== Infra ====

set_global_assignment -name VHDL_FILE $path_src/components/ipbus_eth/firmware/hdl/eth_agilex7_tse.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_util/firmware/hdl/clocks/clocks_agilex7.vhd

# ==== IPBus ====

# ipbus_ctrl
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_core/firmware/hdl/ipbus_package.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_core/firmware/hdl/ipbus_trans_decl.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_util/firmware/hdl/masters/ipbus_ctrl.vhd

# udp
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_if_flat.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_ipam_block.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_build_arp.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_build_ping.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_ipaddr_ipam.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_build_payload.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_build_resend.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_build_status.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_status_buffer.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_byte_sum.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_do_rx_reset.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_packet_parser.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_rxram_mux.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_dualportram.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_buffer_selector.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_rxram_shim.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_dualportram_rx.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_rxtransactor_if_simple.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_dualportram_tx.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_tx_mux.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_txtransactor_if_simple.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_transport_udp/firmware/hdl/udp_clock_crossing_if.vhd

# transactor
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_core/firmware/hdl/transactor.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_core/firmware/hdl/transactor_if.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_core/firmware/hdl/transactor_sm.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_core/firmware/hdl/transactor_cfg.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_core/firmware/hdl/trans_arb.vhd

# payload
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_util/firmware/hdl/ipbus_example.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_util/firmware/hdl/ipbus_decode_ipbus_example.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_slaves/firmware/hdl/ipbus_ctrlreg_v.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_slaves/firmware/hdl/ipbus_reg_v.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_slaves/firmware/hdl/ipbus_ram.vhd
set_global_assignment -name VHDL_FILE $path_src/components/ipbus_slaves/firmware/hdl/ipbus_peephole_ram.vhd

# ==== Quartus Config ====

# constraints
set_global_assignment -name SDC_FILE $path_src/boards/DK-SI-AGI040FES/synth/firmware/cfg/constraints.sdc
set_global_assignment -name SDC_FILE $path_src/components/ipbus_util/firmware/cfg/clocks/clocks_agilex7_constraints.sdc