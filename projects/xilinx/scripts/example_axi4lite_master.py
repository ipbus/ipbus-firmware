#!/usr/bin/env python3

######################################################################
## Call this script with as arguments:
## - the IP address (or host name) of the target board, and
## - the name of the top-level IPBus address table to use.
######################################################################

import random
import sys
import time
import uhal

######################################################################

ACCESS_MODE_READ = 0
ACCESS_MODE_WRITE = 1

AXI_ACCESS_MAX_NUM_TRIES = 10
AXI_ACCESS_SLEEP = 0.1

######################################################################

def axi_read(hw, axi4lite_master_node, register_address):
    ctrl_reg_name = f"{axi4lite_master_node}.ctrl"
    stat_reg_name = f"{axi4lite_master_node}.status"
    hw.getNode(f"{ctrl_reg_name}.address").write(register_address)
    hw.getNode(f"{ctrl_reg_name}.data_strobe").write(0xf)
    hw.getNode(f"{ctrl_reg_name}.access_mode").write(ACCESS_MODE_READ)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x0)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x1)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x0)
    hw.dispatch()
    access_done_raw = hw.getNode(f"{stat_reg_name}.done").read()
    num_tries = 1
    hw.dispatch()
    access_done = access_done_raw.value()
    while (not access_done) and (num_tries <= AXI_ACCESS_MAX_NUM_TRIES):
        num_tries += 1
        time.sleep(AXI_ACCESS_SLEEP)
        access_done_raw = hw.getNode(f"{stat_reg_name}.done").read()
        hw.dispatch()
        access_done = access_done_raw.value()
    if not access_done:
        raise RuntimeError("Failed to execute AXI read")
    data_raw = hw.getNode(f"{stat_reg_name}.data_out").read()
    hw.dispatch()
    data = data_raw.value()
    data_valid = True
    return (data_valid, data)

def axi_write(hw, axi4lite_master_node, register_address, data):
    ctrl_reg_name = f"{axi4lite_master_node}.ctrl"
    stat_reg_name = f"{axi4lite_master_node}.status"
    hw.getNode(f"{ctrl_reg_name}.address").write(register_address)
    hw.getNode(f"{ctrl_reg_name}.data_strobe").write(0xf)
    hw.getNode(f"{ctrl_reg_name}.data_in").write(data)
    hw.getNode(f"{ctrl_reg_name}.access_mode").write(ACCESS_MODE_WRITE)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x0)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x1)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x0)
    access_done_raw = hw.getNode(f"{stat_reg_name}.done").read()
    num_tries = 1
    hw.dispatch()
    access_done = access_done_raw.value()
    while (not access_done) and (num_tries <= AXI_ACCESS_MAX_NUM_TRIES):
        num_tries += 1
        time.sleep(AXI_ACCESS_SLEEP)
        access_done_raw = hw.getNode(f"{stat_reg_name}.done").read()
        hw.dispatch()
        access_done = access_done_raw.value()
    if not access_done:
        raise RuntimeError("Failed to execute AXI write")

######################################################################

if __name__ == '__main__':

    if len(sys.argv) < 3:
        print("Please specify the device IP address" \
            " and the top-level address table file to use")
        sys.exit(1)

    device_ip = sys.argv[1]
    device_uri = "ipbusudp-2.0://" + device_ip + ":50001"
    address_table_name = sys.argv[2]
    address_table_uri = "file://" + address_table_name

    uhal.setLogLevelTo(uhal.LogLevel.WARNING)
    hw = uhal.getDevice("dummy", device_uri, address_table_uri)

    # DEBUG DEBUG DEBUG
    # reg_name_base = "axi4lite_gpio."
    # regs = ["status",
    #         "status.done",
    #         "status.data_out"]
    # max_len = max([len(i) for i in regs])
    # for reg_name_spec in regs:
    #     reg_name = reg_name_base + reg_name_spec
    #     node = hw.getNode(reg_name)
    #     val_raw = node.read()
    #     hw.dispatch()
    #     val = val_raw.value()
    #     msg_base = "  {1:{0:d}s}: 0x{2:08x}"
    #     print msg_base.format(max_len, reg_name_spec, val)
    # DEBUG DEBUG DEBUG end

    print("-" * 50)
    print("IPBus AXI4-lite master demo:")
    print("-" * 50)

    # Write a random number, and read it back from both sides of the
    # AXI GPIO register.
    register_address = 0x0
    rnd = random.randint(0, 255)
    axi_write(hw, "axi4lite_gpio", register_address, rnd)

    (data_valid, res0) = axi_read(hw, "axi4lite_gpio", register_address)
    res1 = hw.getNode("axi4lite_gpio_readback_reg.word0").read()
    hw.dispatch()

    if data_valid:
        print(f"  Wrote 0x{rnd:08x}, read back 0x{res0:08x} and 0x{res1:08x}")
        if (res0 == res1 == rnd):
            print("  This looks okay")
        else:
            print("  --> Clearly something is wrong!")
    else:
        print("    Failed to read back AXI GPIO register")

######################################################################
