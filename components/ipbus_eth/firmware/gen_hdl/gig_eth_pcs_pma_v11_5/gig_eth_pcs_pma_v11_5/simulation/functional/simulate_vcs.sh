#!/bin/sh

rm -rf simv* csrc DVEfiles AN.DB

echo "Compiling Core Simulation Models"
vlogan +v2k \
../../../gig_eth_pcs_pma_v11_5.v \
../../example_design/gig_eth_pcs_pma_v11_5_sync_block.v \
../../example_design/gig_eth_pcs_pma_v11_5_reset_sync.v \
../../example_design/transceiver/gig_eth_pcs_pma_v11_5_gtwizard_gt.v \
../../example_design/transceiver/gig_eth_pcs_pma_v11_5_gtwizard.v \
../../example_design/transceiver/gig_eth_pcs_pma_v11_5_tx_startup_fsm.v \
../../example_design/transceiver/gig_eth_pcs_pma_v11_5_rx_startup_fsm.v \
../../example_design/transceiver/gig_eth_pcs_pma_v11_5_gtwizard_gtrxreset_seq.v \
../../example_design/transceiver/gig_eth_pcs_pma_v11_5_gtwizard_init.v \
../../example_design/transceiver/gig_eth_pcs_pma_v11_5_transceiver.v \
../../example_design/gig_eth_pcs_pma_v11_5_tx_elastic_buffer.v \
../../example_design/gig_eth_pcs_pma_v11_5_block.v \
../../example_design/gig_eth_pcs_pma_v11_5_example_design.v \
../stimulus_tb.v \
../demo_tb.v

echo "Elaborating design"
vcs +vcs+lic+wait \
    -debug \
    demo_tb glbl

echo "Starting simulation"
./simv -ucli -i ucli_commands.key

dve -vpd vcdplus.vpd -session vcs_session.tcl
