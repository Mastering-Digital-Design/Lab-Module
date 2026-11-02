//------------------------------
// Module name: ex16_top.sv
// Function: 	Sample ADC at 10kHz and pass sample straight to ADC using DE1-SoC
// Creator:  Peter Cheung
// Version:  3.0
// Date:     7 Oct 2024
//------------------------------
module ex16_top (
	input  logic            CLOCK_50, 				    // system clock at 50MHz
	input  logic            ADC_SDO,					// ADC serial data out
	output logic            DAC_CS, DAC_SDI, DAC_SCK,	// DAC SPI signals
	output logic 			DAC_LD,		  				//Load new data to DAC, low active	
	output logic            ADC_CS, ADC_SCK, ADC_SDI,   // ADC chip-select & serial symmetical clock at 1MHz & data out SDI
	output logic 		    PWM_OUT,
	output logic [6:0]      HEX0, HEX1, HEX2
);
	// internal signals
	logic       tick_10k;			//  1 tick per sampling period
	logic [9:0] data_in; 			// data from ADC
	logic [9:0] data_out; 			// data to DAC and PWM
	logic	    data_valid;			// high when converted data is available
 	
	// Generate sampling tick once every 100us (10kHz sampling rate)
	clktick  GEN_10K (.clk(CLOCK_50), .rst(1'b0), .en(1'b1), .N(16'd4999),  .tick(tick_10k));

	// output via PWM - R-channel
	pwm PWM_DC(.clk(CLOCK_50),  .data_in(data_out), 
			   .load(tick_10k), .pwm_out(PWM_OUT),
			   .max(10'd1023));		


	// Analogue to Digital
	spi2adc SPI_ADC_INTERFACE (	
			.sysclk (CLOCK_50),
			.start (tick_10k),
			.channel(1'b1),
			.data_from_adc (data_in),
			.data_valid (data_valid),
			.adc_cs (ADC_CS),
			.adc_sck (ADC_SCK),
			.sdata_from_adc (ADC_SDO),
			.sdata_to_adc (ADC_SDI));
    
	// Digital to Analogue
    spi2dac MCP4911 (
		   .clk(CLOCK_50), .data_in(data_out), .load(tick_10k),
		   .dac_cs(DAC_CS), .dac_sdi(DAC_SDI), .dac_sck(DAC_SCK), .dac_ld(DAC_LD) );
			
	// do some processing on the data
	processor	ALLPASS (.sysclk(CLOCK_50), 
						 .data_in(data_in), 
						 .data_out(data_out), 
						 .data_valid(data_valid) );   
	
	// Output to the 7-segment displays
	hexto7seg		SEG0 (HEX0, data_in[3:0]);			
	hexto7seg		SEG1 (HEX1, data_in[7:4]);			
	hexto7seg		SEG2 (HEX2, {2'b0,data_in[9:8]});		
	
endmodule


