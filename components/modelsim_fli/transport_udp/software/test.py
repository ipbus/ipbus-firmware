#!/usr/bin/python
from __future__ import print_function, absolute_import

import uhal
import time
import sys

# uhal.setLogLevelTo(uhal.LogLevel.ERROR)
hw = uhal.getDevice("sim", "ipbusudp-2.0://127.0.0.1:50001", "file://ipbus_example.xml")

v = hw.getNode("reg").read()
hw.dispatch()
print(hex(v))

hw.getNode("reg").write(16)
hw.dispatch()

v = hw.getNode("reg").read()
hw.dispatch()
print(hex(v))
