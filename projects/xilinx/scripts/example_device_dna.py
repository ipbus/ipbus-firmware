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

    print "IPBus UltraScale(+) device DNA demo:"

    word0 = hw.getNode("device_dna.word0").read()
    word1 = hw.getNode("device_dna.word1").read()
    word2 = hw.getNode("device_dna.word2").read()
    hw.dispatch()

    msg_base = "  Device DNA: {0:08x}{1:08x}{2:08x}"
    print msg_base.format(word2, word1, word0)

######################################################################
