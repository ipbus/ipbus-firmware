# From Vivado 2020.2.2 (i.e. from IP core 4.1 revision 10) there
# appears to be a bug which causes the AXI clock frequency to be half
# of what was requested if the CPLL is being used. (See also:
# https://gitlab.cern.ch/p2-xware/firmware/emp-fwk/-/issues/26.)
#
# Until this gets fixed/solved upstream, we redefine the problem clock
# with a modified constraint adapted from the IP core itself.

if {([get_property IPDEF [get_ips xdma_0]] == "xilinx.com:ip:xdma:4.1")
    && ([get_property CORE_REVISION [get_ips xdma_0]] >= 10)
    && ([get_property CONFIG.plltype [get_ips xdma_0]] == "CPLL")} {
  puts "Fixing up AXI clock frequency as workaround for a Vivado bug."
  # create_clock -period 2.000 -name xdma_txoutclk [get_pins -hierarchical -filter {NAME =~infra/dma/xdma/*/*_CHANNEL_PRIM_INST/TXOUTCLK}]
  create_generated_clock -name {txoutclk_out[0]} \
    -source [get_pins -hierarchical -filter {NAME =~infra/dma/xdma/*/*_CHANNEL_PRIM_INST/GTREFCLK0}] \
    -edges {1 2 3} \
    -edge_shift {0.000 -4.000 -8.000} \
    -add \
    -master_clock [get_clocks pcie_sys_clk] \
    [get_pins -hierarchical -filter {NAME =~infra/dma/xdma/*/*_CHANNEL_PRIM_INST/TXOUTCLK}]
}

