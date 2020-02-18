#!/usr/bin/env python

######################################################################

import sys
import uhal

######################################################################

ICAP_ADDRESS_AXSS = 0b01101
ICAP_ADDRESS_BOOTST = 0b10110
ICAP_ADDRESS_CMD = 0b00100
ICAP_ADDRESS_CTL0 = 0b00101
ICAP_ADDRESS_IDCODE = 0b01100
ICAP_ADDRESS_MASK = 0b00110
ICAP_ADDRESS_STAT = 0b00111

ACCESS_MODE_READ = 0
ACCESS_MODE_WRITE = 1
ACCESS_MODE_RECONFIGURE = 2

######################################################################

def icap_read(hw, register_address):
    hw.getNode("icap.access_mode").write(ACCESS_MODE_READ)
    hw.getNode("icap.address").write(register_address)
    hw.getNode("icap.access_strobe").write(0x0)
    hw.getNode("icap.access_strobe").write(0x1)
    hw.dispatch()
    icap_user_data = hw.getNode("icap.user_data_out").read()
    icap_user_data_valid = hw.getNode("icap.user_data_out_valid").read()
    hw.dispatch()
    data_valid = icap_user_data_valid.value()
    data = icap_user_data.value() if data_valid else 0
    return (data_valid, data)

def icap_write(hw, register_address, data):
    hw.getNode("icap.access_mode").write(ACCESS_MODE_WRITE)
    hw.getNode("icap.address").write(register_address)
    hw.getNode("icap.user_data_in").write(data)
    hw.getNode("icap.access_strobe").write(0x0)
    hw.getNode("icap.access_strobe").write(0x1)
    hw.dispatch()

def icap_trigger_reconf(hw, base_address):
    hw.getNode("icap.access_mode").write(ACCESS_MODE_RECONFIGURE)
    hw.getNode("icap.address").write(base_address)
    hw.getNode("icap.access_strobe").write(0x0)
    hw.getNode("icap.access_strobe").write(0x1)
    hw.dispatch()

def iprog_trigger_reconf(hw, base_address):
    hw.getNode("iprog.address").write(base_address)
    hw.getNode("iprog.reconfigure").write(0x0)
    hw.getNode("iprog.reconfigure").write(0x1)
    hw.dispatch()

######################################################################

def get_user_confirmation(prompt=None, resp=False):
    if prompt is None:
        prompt = "Please confirm"

    if resp:
        full_prompt = "{0:s} [n]|y: ".format(prompt)
    else:
        full_prompt = "{0:s} [y]|n: ".format(prompt)

    while True:
        answer = raw_input(full_prompt)
        if not answer:
            return resp
        if answer not in ["y", "Y", "n", "N"]:
            print "Please enter y or n"
            continue
        if answer in ["y", "Y"]:
            return True
        if answer in ["n", "N"]:
            return False

def get_user_choice(prompt=None, choices=["y", "n"]):
    if prompt is None:
        prompt = "Please choose from {0:s}: ".format(choices)

    if not prompt.endswith(" "):
        prompt += " "

    while True:
        answer = raw_input(prompt)
        if answer not in choices:
            print "Please enter a valid choice"
            continue
        return answer

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

    icap_registers = [
        ("IDCODE", ICAP_ADDRESS_IDCODE),
        ("STAT", ICAP_ADDRESS_STAT),
        ("BOOTST", ICAP_ADDRESS_BOOTST),
        ("AXSS", ICAP_ADDRESS_AXSS)
    ]
    max_len = max([len(i[0]) for i in icap_registers])

    print "-" * 50
    print "IPBus ICAP interface demo"
    print "-" * 50

    print "  Register reading:"
    for (register_name, register_address) in icap_registers:
        (data_valid, data) = icap_read(hw, register_address)

        if data_valid:
            msg_base = "    {1:{0:d}s}: 0x{2:08x}"
            print msg_base.format(max_len, register_name, data)
        else:
            print "Failed to read ICAP register {0:s}".format(register_name)

    #----------

    print "  Register writing:"

    # Read user access register.
    (data_valid, data) = icap_read(hw, ICAP_ADDRESS_AXSS)
    if data_valid:
        print "    Read ICAP AXSS register: 0x{0:08x}".format(data)
    else:
        print "    Failed to read ICAP AXSS register"

    # Write user access register. Just to show that we can.
    data = ~data & 0xffffffff
    print "    Writing 0x{0:08x} to ICAP AXSS register".format(data)
    icap_write(hw, ICAP_ADDRESS_AXSS, data)

    # Read user access register.
    (data_valid, data) = icap_read(hw, ICAP_ADDRESS_AXSS)
    if data_valid:
        print "    Read ICAP AXSS register: 0x{0:08x}".format(data)
    else:
        print "    Failed to read ICAP AXSS register"

    #----------

    # Trigger a reconfiguration of the FPGA, from address zero.
    question = "Would you like to see a demo of the FPGA reloading too?"
    if get_user_confirmation(question):
        choice = "Would you like to use the ICAP actor (1) or the IPROG actor (2)?"
        which = get_user_choice(choice, ["1", "2"])
        if which == "1":
            # IPROG via ICAP.
            icap_trigger_reconf(hw, 0x0)
        else:
            # Straight IPROG.
            # NOTE: In this case we have to first select the bottom
            # ICAP instance, since that is where the IPROG entity is
            # connected.
            icap_write(hw, ICAP_ADDRESS_MASK, 0x1 << 30)
            icap_write(hw, ICAP_ADDRESS_CTL0, 0x1 << 30)
            iprog_trigger_reconf(hw, 0x0)

######################################################################
