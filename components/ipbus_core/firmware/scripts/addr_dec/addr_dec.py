#!/usr/bin/python

# This script generates the address select logic in the
# ipbus_addr_decode.vhd file for the ipbus system.
#
# You must have the 'bitstring' package installed to use this:
#
# http://packages.python.org/bitstring/
#
# The script takes an input file called addr_table in the following
# whitespace-delimited format:
#
# slv_num(dec)  slv_name  base_address(hex)  address_bits(dec)
#
# Entries must be in strict slave number order, one slave per line
#
# address_bits gives the number of bits (from LSB upwards) which are
# decoded internally to the slave. Slaves are restricted to lie on
# commensurate power-of-two boundaries.
#
# Note that full address decoding is not performed (would be very
# inefficient with 32b address space), so slaves will appear at many
# locations.
#
# Dave.Newbold@cern.ch, May 2011


from __future__ import print_function
from bitstring import BitArray
import sys

slaves = list()
print("Reading address table")
tbl_file = open("addr_table", "r")

slv_idx = 0;
or_prod = BitArray(hex = "0x00000000")
and_prod = BitArray(hex = "0xffffffff")

for l in tbl_file:
	a=l.rstrip().split()
	if l[0]=="#" or len(a)==0:
		continue
	assert int(a[0], 0) == slv_idx
	slv_idx = slv_idx + 1
	addr_bits = BitArray(int = int(a[2], 0), length = 32)
	mask_bits = BitArray(int = (2**int(a[3], 0))-1, length = 32)
	print(a[0], a[1], addr_bits, mask_bits)
	if((addr_bits & mask_bits).uint != 0):
		sys.exit("Non-aligned address")
	masked = addr_bits & ~mask_bits
	or_prod = or_prod | masked
	and_prod = and_prod & masked
	slaves.append((a[0], a[1], addr_bits, mask_bits))

tbl_file.close()

addr_mask = or_prod & ~and_prod
print("Significant address bits:", addr_mask)

tmpl_file = open("ipbus_addr_decode.vhd.tmpl", "r")
out_file = open("ipbus_addr_decode.vhd", "w")

for l in tmpl_file:
	if l.rstrip()!="--ADDR_TABLE_HERE":
		out_file.write(l)
	else:
		for s in slaves:
			mask = addr_mask & ~s[3]
			cf_str=str()
			for i in xrange(32):
				cf_str += ('-' if not mask[i] else ('1' if s[2][i] else '0'))
			out_file.write("\t\tif    " if int(s[0], 0)==0 else "\t\telsif ")
			out_file.write("std_match(addr, \"" + cf_str + "\") then\n")
			out_file.write("\t\t\tsel := " + str(int(s[0], 0)) + "; -- " + s[1] + " / base " + s[2].hex + " / mask " + s[3].hex + "\n")
			
tmpl_file.close()
out_file.close()

