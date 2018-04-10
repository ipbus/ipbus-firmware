## VCU118 XDC
#
# Link Width   - x1
# Link Speed   - gen3
# Family       - virtexup
# Part         - xcvu9p
# Package      - flga2104
# Speed grade  - -2L
# PCIe Block   - X1Y2 in clock region X5Y5 (same side, but 4 clk regions lower)
# PCIe Block   - X0Y3 in clock region X0Y8 (opposite side, 5 clk regions across)
## ---------------------------------------------------------------

# FPGA config options
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CONFIG_MODE SPIx8 [current_design]

# Bitstream config options
set_property BITSTREAM.CONFIG.CONFIGRATE 51.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]

# PCIe Sys Reset
set_property IOSTANDARD LVCMOS18 [get_ports pcie_sys_rst_n]
set_property PACKAGE_PIN AM17 [get_ports pcie_sys_rst_n]
set_property PULLUP true [get_ports pcie_sys_rst_n]
set_false_path -from [get_ports pcie_sys_rst_n]

# PCIe Ref Clock
create_clock -period 10.000 -name sys_clk [get_ports pcie_sys_clk_p]
set_property PACKAGE_PIN AC9 [get_ports pcie_sys_clk_p]

# PCIe location constraints.  Not sure what is best Clock Root: X5Y5 through to X5Y8
set_property LOC GTYE4_CHANNEL_X1Y35 [get_cells -hierarchical -filter {NAME =~infra/dma/*GTYE4_CHANNEL_PRIM_INST}]
set_property LOC PCIE40E4_X1Y2 [get_cells -hierarchical -filter {NAME =~infra/dma/*pcie_4_0_pipe_inst/pcie_4_0_e4_inst}]
set_property USER_CLOCK_ROOT X5Y5 [get_nets -of_objects [get_pins -hierarchical -filter NAME=~infra/dma/*bufg_gt_sysclk/O]]
set_property USER_CLOCK_ROOT X5Y5 [get_nets -of_objects [get_pins -hierarchical -filter NAME=~infra/dma/*/phy_clk_i/bufg_gt_intclk/O]]
set_property USER_CLOCK_ROOT X5Y5 [get_nets -of_objects [get_pins -hierarchical -filter NAME=~infra/dma/*/phy_clk_i/bufg_gt_coreclk/O]]
set_property USER_CLOCK_ROOT X5Y5 [get_nets -of_objects [get_pins -hierarchical -filter NAME=~infra/dma/*/phy_clk_i/bufg_gt_userclk/O]]
