#!/usr/bin/env python

######################################################################

import random
import sys
import uhal

######################################################################

ACCESS_MODE_READ = 0
ACCESS_MODE_WRITE = 1

######################################################################

def axi_read(hw, register_address):
    hw.getNode("axi4lite_master.ctrl.address").write(register_address)
    hw.getNode("axi4lite_master.ctrl.data_strobe").write(0xf)
    hw.getNode("axi4lite_master.ctrl.access_mode").write(ACCESS_MODE_READ)
    hw.getNode("axi4lite_master.ctrl.access_strobe").write(0x0)
    hw.getNode("axi4lite_master.ctrl.access_strobe").write(0x1)
    hw.getNode("axi4lite_master.ctrl.access_strobe").write(0x0)
    hw.dispatch()
    axi_data = hw.getNode("axi4lite_master.status.data_out").read()
    axi_data_valid = hw.getNode("axi4lite_master.status.done").read()
    hw.dispatch()
    data = axi_data.value()
    data_valid = axi_data_valid.value()
    return (data_valid, data)

def axi_write(hw, register_address, data):
    hw.getNode("axi4lite_master.ctrl.address").write(register_address)
    hw.getNode("axi4lite_master.ctrl.data_strobe").write(0xf)
    hw.getNode("axi4lite_master.ctrl.data_in").write(rnd)
    hw.getNode("axi4lite_master.ctrl.access_mode").write(ACCESS_MODE_WRITE)
    hw.getNode("axi4lite_master.ctrl.access_strobe").write(0x0)
    hw.getNode("axi4lite_master.ctrl.access_strobe").write(0x1)
    hw.getNode("axi4lite_master.ctrl.access_strobe").write(0x0)
    hw.dispatch()

######################################################################

if __name__ == '__main__':

    if len(sys.argv) < 3:
        print "Please specify the device IP address" \
            " and the top-level address table file to use"
        sys.exit(1)

    device_ip = sys.argv[1]
    device_uri = "ipbusudp-2.0://" + device_ip + ":50001"
    address_table_name = sys.argv[2]
    address_table_uri = "file://" + address_table_name

    uhal.setLogLevelTo(uhal.LogLevel.WARNING)
    hw = uhal.getDevice("dummy", device_uri, address_table_uri)

    reg_name_base = "axi4lite_master."
    regs = ["status",
            "status.done",
            "status.data_out"]
    max_len = max([len(i) for i in regs])

    # DEBUG DEBUG DEBUG
    # for reg_name_spec in regs:
    #     reg_name = reg_name_base + reg_name_spec
    #     node = hw.getNode(reg_name)
    #     val_raw = node.read()
    #     hw.dispatch()
    #     val = val_raw.value()
    #     msg_base = "  {1:{0:d}s}: 0x{2:08x}"
    #     print msg_base.format(max_len, reg_name_spec, val)
    # DEBUG DEBUG DEBUG end

    print "-" * 50
    print "IPBus AXI4-lite master demo:"
    print "-" * 50

    # Write a random number, and read it back from both sides of the
    # AXI GPIO register.
    register_address = 0x0
    rnd = random.randint(0, 255)
    axi_write(hw, register_address, rnd)

    (data_valid, res0) = axi_read(hw, register_address)
    res1 = hw.getNode("axi_readback_reg.word0").read()
    hw.dispatch()

    if data_valid:
        print "  Wrote 0x{0:08x}, read back 0x{1:08x} and 0x{2:08x}".format(rnd, res0, res1)
    else:
        print "    Failed to read back AXI register"

######################################################################
