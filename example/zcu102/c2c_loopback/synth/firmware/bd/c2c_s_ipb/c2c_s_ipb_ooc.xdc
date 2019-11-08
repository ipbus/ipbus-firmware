################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name aclk -period 8.001 [get_ports aclk]
create_clock -name gt_clk_clk_p -period 6.400 [get_ports gt_clk_clk_p]

################################################################################