#!/usr/bin/python

# This script parses an ipbus v2.0 UDP packet and does simple checks and decoding
# Command line argument is a list of files, or stdin is used if no arguments
# Files should be in ASCII hexdump format (e.g. from wireshark), whitespace is ignored

import fileinput
import sys

tinfo = ["r ", "w ", "rn", "wn", "m", "ms"]
iinfo = ["ok", "bad_hdr", "-", "-", "err_r", "err_w", "tout_r", "tout_w", "-", "-", "-", "-", "-", "-", "-", "req"]

c = ""
for line in fileinput.input():
	c += line.strip()

i = 0
l = 0
e = True

while e and len(c) > 7:
	b, c = int(c[:8], 16), c[8:]

	if i == 0: # Check for byte ordering
		if (b & 0xf0) == 0xf0:
			flip = False
		elif (b & 0xf0000000) == 0xf0000000:
			flip = True
		else:
			print "Bad header word"
			e = False
			
	if flip: # Flip word
		b = ((b & 0xff000000) >> 24) | ((b & 0xff0000) >> 8) | ((b & 0xff00) << 8) | ((b & 0xff) << 24)

	if l == 0: # packet header

		p_ver = (b & 0xf0000000) >> 28
		p_id = (b & 0xffff00) >> 8
		p_type = (b & 0xf)
		p_flip = "flipped" if flip else "not flipped"

		if p_ver != 2:
			print "Bad proto version"
			e = False
		elif p_type != 0:
			print "Not a control packet"
			e = False

		l = 1
		m = "phdr: ver=%x, id=%04x, type=%x, %s" % (p_ver, p_id, p_type, p_flip)

	elif l == 1: # transaction hdr

		t_ver = (b & 0xf0000000) >> 28
		t_id = (b & 0xfff0000) >> 16
		t_len = (b & 0xff00) >> 8
		t_type = (b & 0xf0) >> 4
		t_info = (b & 0xf)

		if t_ver != 2:
			print "Bad proto version"
			e = False

		if t_info == 0xf:
			if t_type == 0x0 or t_type == 0x2:
				t_rlen = 0
			elif t_type == 0x1 or t_type == 0x3:
				t_rlan = t_len
			elif t_type == 0x4:
				t_rlen = 2
			elif t_type == 0x5:
				t_rlen = 1
			else:
				print "Bad transaction type"
				e = False
		else:
			if t_type == 0x0 or t_type == 0x2:
				t_rlen = t_len
			elif t_type == 0x1 or t_type == 0x3:
				t_rlen = 0
			else:
				t_rlen = 1

		l = 2 if t_info == 0xf else 3
		m = "    thdr: ver=%x, id=%03x, len=%02x, type=%s, info=%s" % (t_ver, t_id, t_len, tinfo[t_type], iinfo[t_info])
		
	elif l == 2: # transaction address
		l = 1 if t_rlen == 0 else 3 
		m = "    addr: %08x" % b

	elif l == 3: # transaction data
		t_rlen -= 1
		l = 1 if t_rlen == 0 else 3
		if t_type == 0x4:
			m = "        and :" if t_rlen == 1 else "        or  :"
		elif t_type == 0x5:
			m = "        add :"
		else:
			m = "        data:"
		m += " %08x" % b

	print "%04x"%i, "%08x"%b, "    ",
	print m

	i += 1
	