set xs_aclk       [get_clocks -of_objects [get_ports s_aclk]]



# Ignore paths from the write clock to the read data registers for Asynchronous Distributed RAM based FIFO




set_disable_timing -from CLK -to O [filter [all_fanout -from [get_ports axi_c2c_phy_clk] -flat -endpoints_only -only_cells] {PRIMITIVE_SUBGROUP==dram || PRIMITIVE_SUBGROUP==LUTRAM}] 

