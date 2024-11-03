### Contents of the Lab_3 folder

**Updated on 3 Nov 2024**: Please update your Lab contents if you had downloaded Lab 3 before this date.

* [Experiment instruction](./Experiment%20Sheet%20-%20Mastering%20Digital%20Design%20Part%203.md) for Lab 3
* [(Deprecated) Experiment instruction](./Experiment%20Sheet%20-%20Mastering%20Digital%20Design%20Part%203.pdf) for Lab 3 (PDF file)
* [Schematic diagram](./DE1-SOC%20Addon%20Card.pdf) of add-on card
* MCP49x1.pdf - [Datasheet](./MCP49x1.pdf) for the 10-bit DAC
* MCP604.pdf - [Datasheet](./MCP604.pdf) for MCP604 quad op-amp
* [spi2dac.sv](./spi2dac.sv) - SPI interface to DAC
* [(Deprecated) spi2adc.v](./spi2adc.v) - Old SPI interface to ADC without reset
* [clktick.sv](./clktick.sv) - Clock tick module SV code
* [hexto7seg.sv](./hexto7seg.sv) - Hex to 7 segment decoder SV code
* [pwm.sv](./pwm.sv) - Pulse-width modulator SV code
* [bin2bcd_16.sv](./bin2bcd_16.sv) - 16-bit binary to BCD conversion (SV code)
* [rom_data.mif](./rom_data.mif) - ROM data file of one cycle of sinewave
* Script to generate sinewave in [Matlab](./sinegen.m) or [Python](./sinegen.py)
* [ex11sol.sof.zip](./ex11sol.sof.zip) - bitstream solution for ex11
* [ex14sol.sof.zip](./ex14sol.sof.zip) - bitstream solution for ex14
* [ex15sol.sof.zip](./ex15sol.sof.zip) - bitstream solution for ex15
* [pin_assignment.txt](./pin_assignment.txt) - this specifies which pin on the FPGA is connected to the external components on the DE1-SoC board. This is be added into the .qsf file.


NOTE: remember to put the various SV modules in ./mylib folder.