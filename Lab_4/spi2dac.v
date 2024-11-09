//------------------------------
// Module name: spi2dac
// Function: SPI interface for MPC4911 DAC
// Creator:  Peter Cheung
// Version:  1.3
// Date:     8 Nov 2016
//------------------------------

module spi2dac (clk, data_in, load, dac_sdi, dac_cs, dac_sck, dac_ld);

	input	clk;				// 50MHz system clock of DE0
	input	[9:0]	data_in;	// input data to DAC
	input	load;				// Pulse to load data to dac
	output dac_sdi;		// SPI serial data out
	output dac_cs;			// chip select - low when sending data to dac
	output dac_sck;		// SPI clock, 16 cycles at half clk freq
	output dac_ld;

//-------------Input Ports-----------------------------
// All the input ports should be wires
	wire			clk, load;
	wire [9:0]	data_in;
	
//-------------Output Ports-----------------------------
// Output port can be a storage element (reg) or a wire
	reg			dac_cs, dac_ld;
	wire			dac_sck, dac_sdi;
	
	parameter	BUF=1'b1;		// 0:no buffer, 1:Vref buffered
	parameter	GA_N=1'b1;		// 0:gain = 2x, 1:gain = 1x
	parameter	SHDN_N=1'b1;	// 0:power down, 1:dac active
	
	wire [3:0] cmd = {1'b0,BUF,GA_N,SHDN_N};  // wire to VDD or GND
	
	// --- Submodule: Generate internal clock at 1 MHz -----
	reg			clk_1MHz;	// 1Mhz clock derived from 50MHz
	reg [4:0]	ctr;			// internal counter
	parameter	TIME_CONSTANT = 5'd24;  // change this for diff clk freq
	initial begin
		clk_1MHz = 0;			// don't need to reset - don't care if it is 1 or 0 to start
		ctr = 5'b0;				//  ... Initialise when FPGA is configured
	end
		
	always @ (posedge clk)   // 
	  if (ctr==0) begin
		  ctr <= TIME_CONSTANT;
		  clk_1MHz <= ~clk_1MHz; // toggle the output clock for squarewave
		end
	  else
		  ctr <= ctr - 1'b1;
	// ---- end internal clock generator ----------

	// ---- Detect posedge of load with a small state machine
	// .... FF set on posedge of load
	// .... reset when dac_cs goes high at the end of DAC output cycle
	reg [1:0] 	sr_state;
	parameter	IDLE  = 2'b00,WAIT_CSB_FALL = 2'b01, WAIT_CSB_HIGH = 2'b10;
	reg			dac_start;		 // set if a DAC write is detected
	
	initial begin
		sr_state = IDLE;
		dac_start = 1'b0;	// set while sending data to DAC
		end
	
	always @ (posedge clk)
		case (sr_state)
			IDLE:	if (load==1'b0) sr_state <= IDLE;
					else	begin
						sr_state <= WAIT_CSB_FALL;
						dac_start <= 1'b1;
						end  				
			WAIT_CSB_FALL: if (dac_cs==1'b1) sr_state <= WAIT_CSB_FALL;
					else sr_state <= WAIT_CSB_HIGH;
					
			WAIT_CSB_HIGH: if (dac_cs==1'b0) sr_state <= WAIT_CSB_HIGH;
					else begin
						sr_state <= IDLE;
						dac_start <= 1'b0;
						end	
			default: sr_state <= IDLE;
		endcase
	//------- End circuit to detect start and end of conversion	

	//------- spi controller designed as a state machine
	// .... with 17 states (idle, and S1-S16 
	// .... for the 16 cycles each sending 1-bit to dac)
	reg [4:0] 	state;
	
	initial	begin	
		state = 5'b0; dac_ld = 1'b0; dac_cs = 1'b1; 
		end
		
	always @(posedge clk_1MHz)  begin
		// default outputs and state transition
		dac_cs <= 1'b0; dac_ld <= 1'b1; 
		state <= state + 1'b1;	// move to next state by default
		case (state)
			5'd0:	if (dac_start == 1'b0)  begin  
						state <= 5'd0; 				// still waiting
						dac_cs <= 1'b1; 
						end
			5'd16: begin  
						dac_cs <= 1'b1; dac_ld <= 1'b0; 
						state <= 5'd0;  // go back to idle state
					end
			default:   begin					// all other states
					dac_cs <= 1'b0; dac_ld <= 1'b1; 
					state <= state + 1'b1;	// default state transition
					end
			endcase
		end	// ... always
	
	// shift register for output data
	reg [15:0] shift_reg;
	initial	begin	
		shift_reg = 16'b0; 
		end

	always @(posedge clk_1MHz)
		if((dac_start==1'b1)&&(dac_cs==1'b1))		// parallel load data to shift reg
			shift_reg <= {cmd,data_in,2'b00};
		else 													// .. else start shifting
			shift_reg <= {shift_reg[14:0],1'b0};
	
	// Assign outputs to drive SPI interface to DAC
			assign dac_sck = !clk_1MHz&!dac_cs;
			assign dac_sdi = shift_reg[15];
endmodule