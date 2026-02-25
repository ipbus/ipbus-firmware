qsys-script --script=../../src/ipbus-firmware/components/ipbus_eth/firmware/ip/tse_sys.tcl --quartus-project=quartus_ipbus_example.qpf
qsys-script --script=../../src/ipbus-firmware/components/ipbus_util/firmware/ip/clocks/iopll.tcl --quartus-project=quartus_ipbus_example.qpf
qsys-script --script=../../src/ipbus-firmware/boards/DK-SI-AGI040FES/synth/firmware/ip/reset_release.tcl --quartus-project=quartus_ipbus_example.qpf
qsys-script --script=../../src/ipbus-firmware/boards/DK-SI-AGI040FES/synth/firmware/ip/probe.tcl --quartus-project=quartus_ipbus_example.qpf