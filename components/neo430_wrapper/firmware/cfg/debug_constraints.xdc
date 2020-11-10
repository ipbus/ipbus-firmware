


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list infra/clocks/clko_ipb]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {soft_core_cpu/cmp_i2c/registers/cr[0]} {soft_core_cpu/cmp_i2c/registers/cr[1]} {soft_core_cpu/cmp_i2c/registers/cr[2]} {soft_core_cpu/cmp_i2c/registers/cr[3]} {soft_core_cpu/cmp_i2c/registers/cr[4]} {soft_core_cpu/cmp_i2c/registers/cr[5]} {soft_core_cpu/cmp_i2c/registers/cr[6]} {soft_core_cpu/cmp_i2c/registers/cr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 3 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {soft_core_cpu/cmp_i2c/wb_adr_i[0]} {soft_core_cpu/cmp_i2c/wb_adr_i[1]} {soft_core_cpu/cmp_i2c/wb_adr_i[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {soft_core_cpu/cmp_i2c/registers/ctr[0]} {soft_core_cpu/cmp_i2c/registers/ctr[1]} {soft_core_cpu/cmp_i2c/registers/ctr[2]} {soft_core_cpu/cmp_i2c/registers/ctr[3]} {soft_core_cpu/cmp_i2c/registers/ctr[4]} {soft_core_cpu/cmp_i2c/registers/ctr[5]} {soft_core_cpu/cmp_i2c/registers/ctr[6]} {soft_core_cpu/cmp_i2c/registers/ctr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {soft_core_cpu/cmp_i2c/registers/prer[0]} {soft_core_cpu/cmp_i2c/registers/prer[1]} {soft_core_cpu/cmp_i2c/registers/prer[2]} {soft_core_cpu/cmp_i2c/registers/prer[3]} {soft_core_cpu/cmp_i2c/registers/prer[4]} {soft_core_cpu/cmp_i2c/registers/prer[5]} {soft_core_cpu/cmp_i2c/registers/prer[6]} {soft_core_cpu/cmp_i2c/registers/prer[7]} {soft_core_cpu/cmp_i2c/registers/prer[8]} {soft_core_cpu/cmp_i2c/registers/prer[9]} {soft_core_cpu/cmp_i2c/registers/prer[10]} {soft_core_cpu/cmp_i2c/registers/prer[11]} {soft_core_cpu/cmp_i2c/registers/prer[12]} {soft_core_cpu/cmp_i2c/registers/prer[13]} {soft_core_cpu/cmp_i2c/registers/prer[14]} {soft_core_cpu/cmp_i2c/registers/prer[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {soft_core_cpu/cmp_i2c/registers/txr[0]} {soft_core_cpu/cmp_i2c/registers/txr[1]} {soft_core_cpu/cmp_i2c/registers/txr[2]} {soft_core_cpu/cmp_i2c/registers/txr[3]} {soft_core_cpu/cmp_i2c/registers/txr[4]} {soft_core_cpu/cmp_i2c/registers/txr[5]} {soft_core_cpu/cmp_i2c/registers/txr[6]} {soft_core_cpu/cmp_i2c/registers/txr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 8 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {soft_core_cpu/s_i2c_data[0]} {soft_core_cpu/s_i2c_data[1]} {soft_core_cpu/s_i2c_data[2]} {soft_core_cpu/s_i2c_data[3]} {soft_core_cpu/s_i2c_data[4]} {soft_core_cpu/s_i2c_data[5]} {soft_core_cpu/s_i2c_data[6]} {soft_core_cpu/s_i2c_data[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {soft_core_cpu/wb_adr_o_int[0]} {soft_core_cpu/wb_adr_o_int[1]} {soft_core_cpu/wb_adr_o_int[2]} {soft_core_cpu/wb_adr_o_int[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list neo430_scl_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list neo430_sda_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list soft_core_cpu/s_i2c_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list uid_scl_IBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list uid_scl_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list uid_sda_IBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list uid_sda_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list soft_core_cpu/wb_ack_i_int]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list soft_core_cpu/cmp_i2c/wb_ack_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list soft_core_cpu/wb_stb_i0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list soft_core_cpu/wb_stb_o_int]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_ipb]
