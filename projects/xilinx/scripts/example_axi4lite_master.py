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

SEP_LINE = "-" * 50

######################################################################

def axi_read(hw, axi4lite_master_node, word_address, num_bytes_per_axi_word=None):
    ctrl_reg_name = f"{axi4lite_master_node}.ctrl"
    stat_reg_name = f"{axi4lite_master_node}.status"
    if not num_bytes_per_axi_word:
        num_bytes_per_axi_word_raw = hw.getNode(f"{stat_reg_name}.num_bytes_per_word").read()
        hw.dispatch()
        num_bytes_per_axi_word = num_bytes_per_axi_word_raw.value()
    num_ipbus_words = num_bytes_per_axi_word // 4
    hw.getNode(f"{ctrl_reg_name}.word_address").write(word_address)
    data_strobe = int("0b" + ("1" * num_bytes_per_axi_word), 2)
    hw.getNode(f"{ctrl_reg_name}.data_strobe").write(data_strobe)
    hw.getNode(f"{ctrl_reg_name}.access_mode").write(ACCESS_MODE_READ)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x0)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x1)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x0)
    hw.dispatch()
    access_done_raw = hw.getNode(f"{stat_reg_name}.access_done").read()
    num_tries = 1
    hw.dispatch()
    access_done =  access_done_raw.value()
    while (not access_done) and (num_tries <= AXI_ACCESS_MAX_NUM_TRIES):
        num_tries += 1
        time.sleep(AXI_ACCESS_SLEEP)
        access_done_raw = hw.getNode(f"{stat_reg_name}.access_done").read()
        hw.dispatch()
        access_done = access_done_raw.value()
    if not access_done:
        raise RuntimeError("Failed to execute AXI read")
    tmp_raw = hw.getNode(f"{stat_reg_name}.data_out").readBlock(num_ipbus_words)
    hw.dispatch()
    tmp = tmp_raw.value()
    data = 0
    for (i, j) in enumerate(tmp):
        data += (j << (i * 32))
    return data

##############################

def axi_read_block(hw, axi4lite_master_node, start_address, num_words):
    stat_reg_name = f"{axi4lite_master_node}.status"
    num_bytes_per_axi_word_raw = hw.getNode(f"{stat_reg_name}.num_bytes_per_word").read()
    hw.dispatch()
    num_bytes_per_axi_word = num_bytes_per_axi_word_raw.value()
    data = []
    for tmp in range(num_words):
        address = start_address + tmp * num_bytes_per_axi_word
        data.append(axi_read(hw, axi4lite_master_node, address, num_bytes_per_axi_word))
    return data

##############################

def axi_write(hw, axi4lite_master_node, word_address, data, num_bytes_per_axi_word=None):
    ctrl_reg_name = f"{axi4lite_master_node}.ctrl"
    stat_reg_name = f"{axi4lite_master_node}.status"
    if not num_bytes_per_axi_word:
        num_bytes_per_axi_word_raw = hw.getNode(f"{stat_reg_name}.num_bytes_per_word").read()
        hw.dispatch()
        num_bytes_per_axi_word = num_bytes_per_axi_word_raw.value()
    num_ipbus_words = num_bytes_per_axi_word // 4
    hw.getNode(f"{ctrl_reg_name}.word_address").write(word_address)
    data_strobe = int("0b" + ("1" * num_bytes_per_axi_word), 2)
    hw.getNode(f"{ctrl_reg_name}.data_strobe").write(data_strobe)

    vals = []
    tmp = data
    for i in range(num_ipbus_words):
        val = tmp & 0xffffffff
        tmp = (tmp >> 32)
        vals.append(val)
    hw.getNode(f"{ctrl_reg_name}.data_in").writeBlock(vals)
    hw.dispatch()

    hw.getNode(f"{ctrl_reg_name}.access_mode").write(ACCESS_MODE_WRITE)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x0)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x1)
    hw.getNode(f"{ctrl_reg_name}.access_strobe").write(0x0)
    access_done_raw = hw.getNode(f"{stat_reg_name}.access_done").read()
    num_tries = 1
    hw.dispatch()
    access_done = access_done_raw.value()
    while (not access_done) and (num_tries <= AXI_ACCESS_MAX_NUM_TRIES):
        num_tries += 1
        time.sleep(AXI_ACCESS_SLEEP)
        access_done_raw = hw.getNode(f"{stat_reg_name}.access_done").read()
        hw.dispatch()
        access_done = access_done_raw.value()
    if not access_done:
        raise RuntimeError("Failed to execute AXI write")

##############################

def axi_write_block(hw, axi4lite_master_node, start_address, data):
    stat_reg_name = f"{axi4lite_master_node}.status"
    num_bytes_per_axi_word_raw = hw.getNode(f"{stat_reg_name}.num_bytes_per_word").read()
    hw.dispatch()
    num_bytes_per_axi_word = num_bytes_per_axi_word_raw.value()
    for (tmp, word) in enumerate(data):
        address = start_address + tmp * num_bytes_per_axi_word
        axi_write(hw, axi4lite_master_node, address, word, num_bytes_per_axi_word)

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

    ##############################

    print(SEP_LINE)
    print("IPBus AXI4Lite demo")
    print(SEP_LINE)

    ##############################

    print("- AXI4Lite to GPIO, readback verification via IPBus CSR")

    try:
        # Write a random number, and read it back from both sides of
        # the AXI GPIO register.
        register_address = 0x0
        rnd = random.randint(0, ((2 << 31) - 1))
        axi_write(hw, "axi4lite_gpio", register_address, rnd)
        res0 = axi_read(hw, "axi4lite_gpio", register_address)
        res1_raw = hw.getNode("axi4lite_gpio_readback_reg.word0").read()
        hw.dispatch()
        res1 = res1_raw.value()
    except Exception as err:
        print(f"    Failed to access AXI GPIO register: {err}")
        sys.exit(1)

    print(f"    Wrote 0x{rnd:08x}, read back 0x{res0:08x} and 0x{res1:08x}")
    if (res0 == res1 == rnd):
        print("    This looks okay")
    else:
        print("    --> Clearly something is wrong!")

    ##############################

    for num_bits in [32, 64]:

        print(f"- AXI4Lite to {num_bits}-bit wide dual-port block RAM")

        node_name = f"axi4lite_mem_{num_bits}bit"
        # NOTE: The actual memory depth is 1024 words.
        # C_NUM_AXI_WORDS = 1024
        C_NUM_AXI_WORDS = 16

        try:
            # Write a bunch of random numbers and then read them back.
            start_address = 0x0
            num_bytes_per_axi_word = num_bits // 8
            tmp = ((2 << (8 * num_bytes_per_axi_word - 1)) - 1)
            rnd = [random.randint(0, tmp) for i in range(C_NUM_AXI_WORDS)]
            axi_write_block(hw, node_name, start_address, rnd)
            res = axi_read_block(hw, node_name, start_address, len(rnd))
        except Exception as err:
            print(f"    Failed to access AXI block RAM: {err}")
            sys.exit(1)

        if res == rnd:
            print(f"  Read back what was written ({len(rnd)} entries)")
            print("     This looks okay")
        else:
            print(f"  Read back something different from what was written")

            num_fs = 2 * num_bytes_per_axi_word
            for (i, (j, k)) in enumerate(zip(rnd, res)):
                marker = " (ok)" if k == j else " !!!"
                print(f"    {i:>4}: wrote 0x{j:0{num_fs}x} read 0x{k:0{num_fs}x}{marker}")

            print("    --> Clearly something is wrong!")

######################################################################
