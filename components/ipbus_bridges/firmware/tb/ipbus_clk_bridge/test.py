#!/usr/bin/env python3

from __future__ import print_function

import sys
import uhal
import time
import random

def test_reg(reg):
    a = random.randint(0, 0xffffffff)
    hw.getNode(reg).write(a)
    v1 = hw.getNode(reg).read()
    hw.dispatch()
    v2 = hw.getNode(reg).readBlock(16)
    hw.dispatch()
    r = True
    for i in range(16):
        r = r and v2[i] == a
#    print(reg, hex(a), v1, v2)
    return v1 == a and r

uhal.setLogLevelTo(uhal.LogLevel.ERROR)
manager = uhal.ConnectionManager("file://connections.xml")
hw = manager.getDevice("SIM")

REG = ("reg", "af_reg", "as_reg", "rf_reg", "rs_reg", "c_reg")

while True:
    h = random.choice(REG);
    r = test_reg(h)
    print(h, r)
    if not r: break


