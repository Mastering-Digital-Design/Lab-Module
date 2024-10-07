### Mastering Digital Design with SystemVerilog using FPGA

This is the github repository for the MSc ADIC lab module on "Mastering Digital Design with SystemVerilog using FPGA" delivered to MSc students in the Department of EEE at Imperial College London.

* Lab leaders: [Professor Peter Cheung](https://www.imperial.ac.uk/people/p.cheung) & [Dr Aaron Zhao](https://profiles.imperial.ac.uk/a.zhao).
* Course originally introduced by Prof Cheung in 2017 using Verilog, but updated in 2024 using SystemVerilog.

Please send feedback on any of this material (e.g. errors, typos, or other suggestions for improvement) to Peter Cheung via email. 

#### Aims

1. To ensure all students on the MSc course reach a common competence level in RTL design using FPGAs in a hardware description language; and
2. To act as revision exercise for those who are already competent in SystemVerilog and FPGA.

You will conduct this experiment in the first half of the Autumn Term. You can find a copy of the Experiment Specification Document [here](experiment/specification.pdf).

#### Learning Outcomes

This Lab Experiment has FOUR distinct parts, each with specific learning outcomes.

**Part 1:** Basic competence in using Intel/Altera’s Quartus design systems for Cyclone-V FPGA; appreciate the superiority of hardware description language over schematic capture for digital design; use of case statement to specify combinatorial circuit; use higher level constructs in Verilog to specify complex combinatorial circuits; develop competence in taking a design from description to hardware.

**Part 2:** Use SystemVerilog to specify sequential circuits; design of basic building blocks including: counters, linear-feedback shift-registers to generate pseudo-random numbers, basic state machines; using enable signals to implement globally synchronisation.

**Part 3:** Understand how digital components communicate through synchronous serial interface; interfacing digital circuits to analogue components such as ADC and DAC; use of block memory in FPGAs; number system and arithmetic operations such as adders and multipliers; digital signal generation.

**Part 4:** Understand how to implement a FIFO using counters as pointer registers and Block RAM as storage; implement a relatively complex digital circuit using different building blocks including: counters, finite state machines, registers, encoder/decoder, address computation unit, memory blocks, digital delay elements, synchronisers etc.; learn how to debug moderately complex digital circuits.

#### Lecture Notes

* Week 1: [slides](./lectures/Lecture_1_slides.pdf), [notes](./lectures/Lecture_1_notes.pdf)
* Week 2: [slides](./lectures/Lecture_2_slides.pdf), [notes](./lectures/Lecture_2_notes.pdf)
* Week 3: [slides](./lectures/Lecture_3_slides.pdf), [notes](./lectures/Lecture_3_notes.pdf)
* Week 4: [slides](./lectures/Lecture_4_slides.pdf), [notes](./lectures/Lecture_4_notes.pdf)

#### Assessment

You are expected to keep a good logbook of your lab work. There will be an oral interview at the end of the Autumn term when you will be asked to show your logbook to your assessor, who will ask questions directly from it. The [marks](experiment/marksheet.pdf) for this experiment will count towards the Coursework component of the MSc course.  Details will be published later.

#### Experiments

 There are altogether 20 experiments (ex1 to ex20) divided into four parts. Each part takes one week to complete and is supported by an accompanying lecture.  All materials required for each week are included in this repository in the four separate directories (Lab_1 to Lab_4).

* [Week 1](./Lab_1): Introduction to Mastering Digital Design
* [Week 2](./Lab_2): Counters and Finte State Machines
* [Week 3](./Lab_3): Analogue I/O and SPI interface
* [week 4](./Lab_4): Real-time audio signal processing

#### Quartus Prime Lite

* [Quartus Prime Lite Web Edition](https://www.intel.com/content/www/us/en/software-kit/660907/intel-quartus-prime-lite-edition-design-software-version-20-1-1-for-windows.html)

#### Reference Material

You can find various reference materials [here](./reference_material/)

#### Verilog Resources

* [SystemVerilog tutorial by ASIC World](https://www.asic-world.com/systemverilog/tutorial.html)
