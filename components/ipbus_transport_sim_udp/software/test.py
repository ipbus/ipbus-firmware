#!/usr/bin/python

import uhal
import time
import sys
from I2CuHal import I2CCore

# uhal.setLogLevelTo(uhal.LogLevel.ERROR)
hw = uhal.getDevice("sim", "ipbusudp-2.0://127.0.0.1:50001", "file://ipbus_example.xml")

v = hw.getNode("reg").read()
print hex(v)
