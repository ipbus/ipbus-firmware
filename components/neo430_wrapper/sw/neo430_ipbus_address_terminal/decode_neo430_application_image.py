# Use to pull strings out of neo430_application_image.vhd
# Run with neo430_application_image.vhd as command line argument. 
# Pipe into strings to get strings...
# e.g.
# python decode_neo430_application_image.py ../../../firmware/hdl/neo430_application_image.vhd | strings
#
# David Cussans Nov 2020
#
from sys import argv
from os.path import exists
import re
import sys

#this to accept parameter from command-line
script, from_file = argv

# Read in lines
with open(from_file) as in_file:
    lines = in_file.read().splitlines()

for i in lines:
    #print i
    m = re.search('x"([0-9a-f]+)"', i)
    if (m):
        numberStr = m.group(0)
        number = numberStr[2:6]
        # print number

        converted = int( number , 16)
        convertedLow = chr(converted & 0x00FF)
        convertedHigh = chr((converted >> 8) & 0xFF)
        # print "high, low = ", convertedLow , convertedHigh

        sys.stdout.write(convertedLow + convertedHigh)
        #this to print the result for reference on-screen.
        #print "converted =" + str(converted)

#print "done."

