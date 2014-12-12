vlib work
vmap work work

echo "Compiling Core Simulation Models"
vlog -work work ../../../gig_eth_pcs_pma_v11_5.v

echo "Compiling Example Design"
vlog -work work \
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
../../example_design/gig_eth_pcs_pma_v11_5_example_design.v

echo "Compiling Test Bench"
vlog -work work -novopt ../stimulus_tb.v ../demo_tb.v

echo "Starting simulation"
vsim -voptargs="+acc" -L unisims_ver -L secureip -t ps work.demo_tb work.glbl
do wave_mti.do
run -all

