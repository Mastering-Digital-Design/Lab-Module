//------------------------------
// Module name: spi2dac
// Function: SPI interface for MPC4911 DAC
// Creator:  Peter Cheung
// Version:  2.0
// Date:     8 Nov 2016
//------------------------------

module spi2dac (
	input  logic        sysclk,		// 50MHz system clock of DE1
	input  logic [9:0]	data_in,	// input data to DAC
	input  logic 	    load,		// Pulse to load data to dac
    input  logic 	    reset,
	output logic 	    dac_sdi,	// SPI serial data out
	output logic 	    dac_cs,		// chip select - low when sending data to dac
	output logic 	    dac_sck,	// SPI clock, 16 cycles at half sysclk freq
	output logic 	    dac_ld 
);

	// --- Clock Divider - Producing a 1MHz clock -----
	logic clk_1MHz;	 // 1Mhz clock derived from 50MHz
	logic [4:0]	ctr; // internal counter
	
	parameter TC = 5'd24;  // change this for diff clk freq
    
    always_ff @(posedge sysclk or posedge reset) begin
        if (reset) begin
            clk_1MHz <= 0;
            ctr <= 5'b0;
        end else begin
            if (ctr == 0) begin
                ctr <= TC;
                clk_1MHz <= ~clk_1MHz;
            end
            else begin
                ctr <= ctr - 1'b1;
            end
        end
    end

	// ---- Load detector
	typedef enum logic [1:0] {
		IDLE = 2'b00,
		HIGH = 2'b01,
		WAIT = 2'b10
	} sr_state_t;

	sr_state_t		sr_state;
	logic			dac_start;		 // set if a DAC write is detected

    always_ff @(posedge sysclk or posedge reset) begin
        if (reset) begin
            sr_state <= IDLE;
        end else begin
            case (sr_state)
			IDLE: if (load == 1'b1)   sr_state <= HIGH;
			HIGH: if (dac_cs == 1'b0) sr_state <= WAIT;
			WAIT: if (dac_cs == 1'b1) sr_state <= IDLE;
			default:                  sr_state <= IDLE;
            endcase
        end
    end

    always_comb begin
		case (sr_state)
			IDLE: 	 dac_start = 1'b0;
			HIGH: 	 dac_start = 1'b1;
			WAIT: 	 dac_start = 1'b0;
			default: dac_start = 1'b0;
		endcase
    end

	//------- Spi controller FSM
	// Send one bit of data for 16 cycles (of 1MHz clock)
	logic [4:0] 	state;
	
	always_ff @(posedge clk_1MHz or posedge reset)  begin // FSM state transition
        if (reset) begin
            state <= 5'b0;
        end else begin 
		case (state)
			5'd0:	if (dac_start == 1'b1)    // kick-off counter
						state <= state + 1'b1; 
					else 
						state <= 5'b0; 
			5'd17: 	state <= 5'd0;  // go back to idle state
			default: state <= state + 1'b1;	// default go to next state
		endcase
        end
    end
	
	// FSM Outputs
	always_comb begin
    	case (state)
    	    5'd0:    {dac_cs, dac_ld} = 2'b11;
    	    5'd17:   {dac_cs, dac_ld} = 2'b10;
    	    default: {dac_cs, dac_ld} = 2'b01;
    	endcase
	end

	
	// --- Shift register
	parameter BUF=1'b1;		// 0:no buffer, 1:Vref buffered
	parameter GA_N=1'b1;	// 0:gain = 2x, 1:gain = 1x
	parameter SHDN_N=1'b1;	// 0:power down, 1:dac active
	
	logic [3:0] cmd = {1'b0,BUF,GA_N,SHDN_N};  // wire to VDD or GND
	logic [15:0] shift_reg;

	always_ff @(posedge clk_1MHz or posedge reset) begin
        if (reset) begin
            shift_reg <= 16'b0;
        end else begin
            
		if( dac_start && dac_cs )		// parallel load data to shift reg
			shift_reg <= {cmd,data_in,2'b00};
		else 						   // otherwise shift data through
			shift_reg <= {shift_reg[14:0],1'b0};
        end
    end
	
	// Assign outputs to drive SPI interface to DAC
	assign dac_sck = (!clk_1MHz) & (!dac_cs);
	assign dac_sdi = shift_reg[15]; // Send single-bit to DAC

endmodule
