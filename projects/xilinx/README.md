# Instructions on building and running the SysMon example designs and scripts.

## KC705 with RJ45 Ethernet connection.
```
$ ipbb init xilinx_example
$ cd xilinx_example
$ ipbb add git https://github.com/ipbus-firmware
$ ipbb proj create vivado -t top_kc705_gmii.dep example_kc705 ipbus-firmware:projects/xilinx
$ cd proj/example_kc705
$ ipbb vivado make-project
$ ipbb vivado synth -j4 impl -j 4
$ ipbb vivado package
```

Now program the bit file into the FPGA.

```
$ cd ../../src/ipbus-firmware/projects/xilinx/scripts/
$ cp ../../../../../proj/example_kc705/package/src/addrtab/* .
$ ./example_sysmon.py 192.168.200.16 ipbus_example_xilinx_x7.xml
```

## VCU118 with RJ45 Ethernet connection.
```
$ ipbb init xilinx_example
$ cd xilinx_example
$ ipbb add git https://github.com/ipbus-firmware
$ ipbb proj create vivado -t top_vcu118_sgmii.dep example_vcu118 ipbus-firmware:projects/xilinx
$ cd proj/example_vcu118
$ ipbb vivado make-project
$ ipbb vivado synth -j4 impl -j 4
$ ipbb vivado package
```

Now program the bit file into the FPGA.

```
$ cd ../../src/ipbus-firmware/projects/xilinx/scripts/
$ cp ../../../../../proj/example_vcu118/package/src/addrtab/* .
$ ./example_sysmon.py 192.168.200.17 ipbus_example_xilinx_usp.xml
$ ./example_device_dna.py 192.168.200.17 ipbus_example_xilinx_usp.xml
```

## Expected output
### SysMon
The SysMon part of the output of the example script (for both
examples) should show something like:

```
IPBus SysMon/XADC demo:
  temp   : 23.67 C
  vccint :  0.85 V
  vccaux :  1.79 V
  vrefp  :  0.00 V
  vrefn  :  0.00 V
  vccbram:  0.85 V
```

### Device DNA
The device DNA part of the UltraScale(+) example should report a
96-bit identifier that looks similar to this:

```
IPBus UltraScale(+) device DNA demo:
  Device DNA: 4002000001298e463d5102c5
```
