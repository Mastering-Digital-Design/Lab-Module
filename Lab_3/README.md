### Contents of the Lab_3 folder

* Lecture 3 [slides](./Lecture_3_slides.pdf) (PDF file)
* Lecture 3 [notes](./Lecture_3_notes.pdf) (PDF file)
* [Experiment instruction](./Experiment%20Sheet%20-%20Mastering%20Digital%20Design%20Part%203.pdf) for Lab 3 (PDF file)
* [Schematic diagram](./DE1-SOC%20Addon%20Card.pdf) of add-on card
* MCP49x1.pdf - [Datasheet](./MCP49x1.pdf) for the 10-bit DAC
* MCP3002.pdf - [Datasheet](./MCP3002.pdf) for the 10-bit ADC
* MCP604.pdf - [Datasheet](./MCP604.pdf) for MCP604 quad op-amp
* [spi2dac.sv](./spi2dac.sv) - SPI interface to DAC
* [spi2adc.sv](./spi2adc.sv) - SPI interface to ADC
* [clktick.sv](./clktick.sv) - Clock tick module SV code
* [hexto7seg.sv](./hexto7seg.sv) - Hex to 7 segment decoder SV code
* [pwm.sv](./pwm.sv) - Pulse-width modulator SV code
* [bin2bcd_16.sv](./bin2bcd_16.sv) - 16-bit binary to BCD conversion (SV code)
* [rom_data.mif](./rom_data.mif) - ROM data file
* [ex11sol.sof.zip](./ex11sol.sof.zip) - bitstream solution for ex11
* [ex14sol.sof.zip](./ex14sol.sof.zip) - bitstream solution for ex14
* [ex15sol.sof.zip](./ex15sol.sof.zip) - bitstream solution for ex15
* [pin_assignment.txt](./pin_assignment.txt) - this specifies which pin on the FPGA is connected to the external components on the DE1-SoC board. This is be added into the .qsf file.


NOTE: remember to put the various SV modules in ./mylib folder.