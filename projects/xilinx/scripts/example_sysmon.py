#!/usr/bin/env python

######################################################################

import sys
import uhal

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

    reg_name_base = "sysmon."
    regs = ["temp",
            "vccint",
            "vccaux",
            "vrefp",
            "vrefn",
            "vccbram"]
    max_len = max([len(i) for i in regs])

    print "IPBus SysMon/XADC demo:"
    for reg_name_spec in regs:
        reg_name = reg_name_base + reg_name_spec
        node = hw.getNode(reg_name)
        val_raw = node.read()
        hw.dispatch()

        # NOTE: Yes, flexible but ugly.
        val = val_raw.value()
        tags = hw.getNode(reg_name).getTags()
        magic = tags.split(";")[0]
        unit = tags.split(";")[1]
        exec(magic)
        msg_base = "  {1:{0:d}s}: {2:5.2f} {3:s}"
        print msg_base.format(max_len, reg_name_spec, conversion, unit)

######################################################################
