#!/usr/bin/env python2

import uhal
import os.path
import random
import time


# ----------------------------------------------------------
def readported(ram_node):

    addr_node = ram_node.getNode('addr')
    data_node = ram_node.getNode('data')

    addr_node.write(0x0)
    return data_node.readBlock(data_node.getSize())
# ----------------------------------------------------------


# ----------------------------------------------------------
def writeported(ram_node, data):
    addr_node = ram_node.getNode('addr')
    data_node = ram_node.getNode('data')

    # print len(data), data_node.getSize()
    if len(data) > data_node.getSize():
        data = data[:data_node.getSize()]
    elif len(data) < data_node.getSize():
        data = data + [0]*(data_node.getSize()-len(data))

    # print 'written  =', data
    addr_node.write(0x0)
    return data_node.writeBlock(data)
# ----------------------------------------------------------


# ----------------------------------------------------------
def portedram_writeandreadback(pram_node):
    valvec = readported(pram_node)
    device.dispatch()

    # in_words = [random.randint(0,(1<<32-1)) for _ in xrange(pram_node.getNode('data').getSize())]
    in_words = range(pram_node.getNode('data').getSize(), 0, -1)
    writeported(pram_node, in_words)
    device.dispatch()
    val_vec = readported(pram_node)
    device.dispatch()

    ok = in_words == list(val_vec)
    print 'SUCCEDED' if ok else 'FAILED',repr(pram_node.getId()), ': readback test ('+str(pram_node.getNode('data').getSize()),'words)'

    if not ok:
        print '   First mismatch at:', next( (idx, x, y) for idx, (x, y) in enumerate(zip(in_words, val_vec)) if x!=y )

# ----------------------------------------------------------


# ----------------------------------------------------------
def ram_writeandreadback(ram_node):
    valvec = ram_node.readBlock(ram_node.getSize())
    ram_node.getClient().dispatch()

    in_words = range(ram_node.getSize(), 0, -1)
    ram_node.writeBlock(in_words)
    ram_node.getClient().dispatch()
    val_vec = ram_node.readBlock(ram_node.getSize())
    ram_node.getClient().dispatch()

    ok = in_words == list(val_vec)
    print 'SUCCEDED' if ok else 'FAILED',repr(ram_node.getId()), ': readback test ('+str(ram_node.getSize()),'words)'

    if not ok:
        print '   First mismatch at:', next( (idx, x, y) for idx, (x, y) in enumerate(zip(in_words, val_vec)) if x!=y )
# ----------------------------------------------------------


reladdrpath = [os.pardir, os.pardir, 'components', 'ipbus_util', 'addr_table', 'ram_slaves_tester.xml']
addrtabpath = 'file://'+os.path.normpath(os.path.join(os.path.abspath(os.path.dirname(__file__)), *reladdrpath ))

device = uhal.getDevice('SIM', 'ipbusudp-2.0://192.168.201.2:50001', addrtabpath)

# Reset
# device.getNode('csr.ctrl.rst').write(0x1)
# device.dispatch()

# Read magic word
csr_stat = device.getNode('csr.stat').read()
device.dispatch()


print 'stat =',hex(csr_stat)

# ----- rw reg
reg_node = device.getNode('reg')
val = reg_node.read()
device.dispatch()
print 'reg B =',hex(val)

reg_node.write(5)
val = reg_node.read()
device.dispatch()
print 'reg A =',hex(val)

# # ----- peephole ram
# portedram_writeandreadback(device.getNode('ported_ram'))

# # ----- ported ram (32 bits)
# portedram_writeandreadback(device.getNode('ported_dpram'))

# # ----- ported ram (36 bits)
# portedram_writeandreadback(device.getNode('ported_dpram36'))

# # ----- ram (36 bits)
# ram_writeandreadback(device.getNode('ram'))

# ----- duap-port ram (32 bits)
# ram_writeandreadback(device.getNode('dpram'))

# # ----- duap-port ram (36 bits)
# ram_writeandreadback(device.getNode('dpram36'))

print '--- Before ---'
# device.getNode('dpram').writeBlock([0]*device.getNode('dpram').getSize())
# device.dispatch()

# valvec = device.getNode('dpram').readBlock(device.getNode('dpram').getSize())
# device.dispatch()
# print list(valvec)

device.getNode('patt_gen.ctrl.mode').write(0x2)
device.getNode('patt_gen.ctrl.word').write(0xff)

device.getNode('patt_gen.ctrl.fire').write(0x1)
device.getNode('patt_gen.ctrl.fire').write(0x0)
device.dispatch()

time.sleep(5)
# raise SystemExit(0)

print '--- After ---'
# valvec = device.getNode('dpram').readBlock(device.getNode('dpram').getSize())
# device.dispatch()
# print [ hex(x) for x in valvec]


# valvec = device.getNode('dpram36').readBlock(device.getNode('dpram36').getSize())
# device.dispatch()
# print '\n'.join([ hex(x) for i,x in enumerate(valvec[:32])])

# valvec = readported(device.getNode('pdpram'))
# device.dispatch()
# print [ hex(x) for x in valvec[:0x20]]

# print '---pdpram 36---'
# valvec = readported(device.getNode('ported_dpram36'))
# device.dispatch()
# print '\n'.join([
#      "%02d 0x%08x" % (i,x) for i,x in enumerate(valvec[:32])
#     ])

# print '---pdpram 72---'
# valvec = readported(device.getNode('ported_dpram72'))
# device.dispatch()
# print '\n'.join([
#      "%02d 0x%08x" % (i,x) for i,x in enumerate(valvec[:32])
#     ])


print '---spdpram 72---'
valvec = readported(device.getNode('ported_sdpram72'))
device.dispatch()
print '\n'.join([
     "%02d 0x%08x" % (i,x) for i,x in enumerate(valvec[:32])
    ])


