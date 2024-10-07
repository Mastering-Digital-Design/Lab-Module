# sinegen.py - Generate sinewave table
#  ... for use with Altera ROMs
# 
from math import sin, cos, radians

DEPTH = 1024  # Size of ROM
WIDTH = 10   # Size of data in bits
OUTMAX = 2**WIDTH - 1   # Amplitude of sinewave

filename = "rom_data.mif"
f = open(filename,'w')

#  Header for the .mif file
print >> f, "-- ROM Initialization file\n"
print >> f, "DEPTH = %d;" % DEPTH
print >> f, "WIDTH = %d;" % WIDTH
print >> f, "ADDRESS_RADIX = HEX;"
print >> f, "DATA_RADIX = HEX;\n"
print >> f, "CONTENT\nBEGIN\n"

for address in range(DEPTH):
	angle = (address*2*pi)/DEPTH
	sine_value = sin(angle)
	data = int((sine_value)*0.5*OUTMAX)+OUTMAX/2
	
	print "%4x : %4x;" % (address, data)
	print >> f, "%4x : %4x;" % (address, data)

print >> f, "END;\n"

f.close()


