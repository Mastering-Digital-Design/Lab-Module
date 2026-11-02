//------------------------------
// Module name: spi2adc
// Function: SPI interface for MCP3002 ADC
// Creator:  Peter Cheung
// Version:  1.1
// Date:     24 Jan 2014
//------------------------------

module spi2adc (sysclk, start, channel, data_from_adc, data_valid, 
						sdata_to_adc, adc_cs, adc_sck, sdata_from_adc);

	input	sysclk;			// 50MHz system clock of DE0
	input	start;			// Pulse to start ADC, minimum wide = clock period
	input	channel;			// channel 0 or 1 to be converted
	output [9:0] data_from_adc;	// 10-bit ADC result
	output data_valid;	// High indicates that converted data valid
	output sdata_to_adc;	// Serial commands send to adc chip
	output adc_cs;			// chip select - low when converting
	output adc_sck;		// SPI clock - active during conversion
	input sdata_from_adc;	// Converted serial data from ADC, MSB first

//-------------Input Ports-----------------------------
// All the input ports should be wires
	wire	sysclk, start, sdata_from_adc;

//-------------Output Ports-----------------------------
// Output port can be a storage element (reg) or a wire
	reg [9:0]	data_from_adc;
	reg			adc_cs;
	wire			sdata_to_adc, adc_sck, data_valid;
	
//-------------Configuration parameters for ADC --------
	parameter	SGL=1'b1;	// 0:diff i/p, 1:single-ended
	parameter	MSBF=1'b1;	// 0:LSB first, 1:MSB first
			
// --- Submodule: Generate internal clock at 1 MHz -----
	reg			clk_1MHz;	// 1Mhz clock derived from 50MHz
	reg [4:0]	ctr;			// internal counter
	parameter	TIME_CONSTANT = 5'd24;  // change this for diff clk freq
	initial begin
		clk_1MHz = 0;			// don't need to reset - don't care if it is 1 or 0 to start
		ctr = 5'b0;				//  ... to start.  Initialise to make simulation easier
	end
		
	always @ (posedge sysclk)   // 
	  if (ctr==0) begin
		  ctr <= TIME_CONSTANT;
		  clk_1MHz <= ~clk_1MHz; // toggle the output clock for squarewave
		end
	  else
		  ctr <= ctr - 1'b1;
// ---- end internal clock generator ----------

// ---- Detect start is asserted with a small state machine
	// .... FF set on positive edge of start
	// .... reset when adc_cs goes high again
	reg [1:0] 	sr_state;
	parameter	IDLE  = 2'b00,WAIT_CSB_FALL = 2'b01, WAIT_CSB_HIGH = 2'b10;
	reg			adc_start;
	
	initial begin
		sr_state = IDLE;
		adc_start = 1'b0;	// set while sending data to ADC
		end
	
	always @ (posedge sysclk)
		case (sr_state)
			IDLE:	if (start==1'b0) sr_state <= IDLE;
					else	begin
						sr_state <= WAIT_CSB_FALL;
						adc_start <= 1'b1;
						end  				
			WAIT_CSB_FALL: if (adc_cs==1'b1) sr_state <= WAIT_CSB_FALL;
					else sr_state <= WAIT_CSB_HIGH;
					
			WAIT_CSB_HIGH: if (adc_cs==1'b0) sr_state <= WAIT_CSB_HIGH;
					else begin
						sr_state <= IDLE;
						adc_start <= 1'b0;
						end	
			default: sr_state <= IDLE;
		endcase
//------- End circuit to detect start and end of conversion	

	
// spi controller designed as a state machine
// .... with 16 states (idle, and S1-S15 indicated by state value

	reg [4:0] 	state;
	reg  	adc_done, adc_din, shift_ena;
	
	initial	begin	
		state = 5'b0; adc_cs = 1'b1; adc_done = 1'b0; 
		adc_din = 1'b0; shift_ena <= 1'b0;
		end
		
	always @(posedge clk_1MHz)  begin
	
	// default outputs and state transition
		adc_cs <= 1'b0;  adc_done <= 1'b0;  adc_din <= 1'b0; shift_ena <= 1'b0;
		state <= state + 1'b1;
		case (state)
			5'd0:	begin
						if (adc_start==1'b0) begin
							state <= 5'd0;			// still idle
							adc_cs <= 1'b1;		// chip select not active
							end
						else begin
							state <= 5'd1;			// start converting
							adc_din <= 1'b1;		// start bit is 1
							end
					end
			5'd1:	adc_din <= SGL;				// SGL bit
			5'd2:	adc_din <= channel;			// CH bit
			5'd3:	adc_din <= MSBF;				// MSB first bit
			5'd4: shift_ena <= 1'b1;  			// start shifting data from adc
			5'd15: begin
						shift_ena <= 1'b0;
						adc_done <= 1'b1;
					 end
			5'd16: begin  
						adc_cs <= 1'b1;		// last state - disable chip select
						state <= 5'd0;  		// go back to idle state
					 end
			default: 				
						shift_ena <= 1'b1;	// unspecified states are covered by default above
			endcase
		end	// ... always
	
	// shift register for output data
	reg [9:0] shift_reg;
	initial	begin
			shift_reg = 10'b0;
			data_from_adc = 10'b0;
			end
	
	always @(negedge clk_1MHz)
		if((adc_cs==1'b0)&&(shift_ena==1'b1))		// start shifting data_in
				shift_reg <= {shift_reg[8:0],sdata_from_adc};
	
	// Latch converted output data
	always @(posedge clk_1MHz)
		if(adc_done) 					
				data_from_adc = shift_reg;

	// Assign outputs to drive SPI interface to DAC
		assign adc_sck = !clk_1MHz & !adc_cs;
		assign sdata_to_adc = adc_din;
		assign data_valid = adc_cs;
endmodule