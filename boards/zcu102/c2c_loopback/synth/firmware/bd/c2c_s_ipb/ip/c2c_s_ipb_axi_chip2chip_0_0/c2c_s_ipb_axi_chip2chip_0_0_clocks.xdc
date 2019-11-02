set xm_aclk     [get_clocks -of_objects [get_ports m_aclk]]



#Independent DIST RAM FIFO constraints in SLAVE INDEPENDENT mode 
#read to write


set_disable_timing -from CLK -to O [filter [all_fanout -from [get_ports m_aclk] -flat -endpoints_only -only_cells] {PRIMITIVE_SUBGROUP==dram || PRIMITIVE_SUBGROUP==LUTRAM}] 

