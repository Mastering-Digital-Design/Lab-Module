# sinegen.py - Generate sinewave table
#  ... for use with Altera ROMs

from math import sin, pi

DEPTH = 1024  # Size of ROM
WIDTH = 10   # Size of data in bits
OUTMAX = 2**WIDTH - 1   # Amplitude of sinewave

filename = "rom_data.mif"
with open(filename, 'w') as f:
    # Header for the .mif file
    f.write("-- ROM Initialization file\n\n")
    f.write("DEPTH = {};\n".format(DEPTH))
    f.write("WIDTH = {};\n".format(WIDTH))
    f.write("ADDRESS_RADIX = HEX;\n")
    f.write("DATA_RADIX = HEX;\n\n")
    f.write("CONTENT\nBEGIN\n\n")

    for address in range(DEPTH):
        angle = (address * 2 * pi) / DEPTH
        sine_value = sin(angle)
        data = int((sine_value) * 0.5 * OUTMAX + OUTMAX / 2)

        # Display output on the console and write to the file
        print("{:04x} : {:04x};".format(address, data))
        f.write("{:04x} : {:04x};\n".format(address, data))

    f.write("END;\n")

