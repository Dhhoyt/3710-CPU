/*
Basic UART Reciever, samples once per bit and assumes a specified baudrate

Inputs
clk50Mhz: 50Mhz clock
portRX: UART input bus port (mapped to GPIO_0, on JP2)

Output
data: 1 byte wide register holding the last received byte


*/


module uartrx#(parameter BAUD_RATE=9650) (
	input clk50Mhz,
	input portRX,
	output reg [7:0] data = 86);

	//assume 50Mhz clock
	parameter CLKS_PER_BIT = 50000000 / BAUD_RATE;

	
	parameter STATE_IDLE = 0;
	parameter STATE_START_BIT = 1;
	parameter STATE_DATA_BITS = 2;
	parameter STATE_STOP_BIT = 3;

	reg [1:0] state;
	reg [1:0] nextState;

	reg rxReg;

	reg [7:0] workingData;
	reg workingInput;

	reg  timerReset;
	reg  timerEn = 1;
	reg  [15:0] timerMaximum;
	wire [15:0] timerCount;
	wire timerRollover;
	
	
	counter #(.width(16)) timer (
						.clk(clk50Mhz),
						.reset(timerReset),
						.enable(timerEn),
						.maximum(timerMaximum),
						.count(timerCount),
						.rollover(timerRollover));

	wire [3:0] bitCount;
	wire bitCountRollover;
	reg bitCountEnable;

	counter #(.width(4)) bitCounter (
						.clk(clk50Mhz),
						.reset(timerReset),
						.enable(bitCountEnable),
						.maximum(8),
						.count(bitCount),
						.rollover(bitCountRollover));

	// register for the input
	always @(posedge clk50Mhz) rxReg <= portRX;

	// Combonational next state 
	always @(*) begin
		case (state)
			STATE_IDLE: begin // wait for data
				nextState <= rxReg? STATE_IDLE : STATE_START_BIT;
			end
			STATE_START_BIT: begin // delay until middle of first data bit
				nextState <= timerRollover? STATE_DATA_BITS : STATE_START_BIT;
			end
			STATE_DATA_BITS: // read 8 bits
				nextState <= bitCountRollover? STATE_STOP_BIT : STATE_DATA_BITS;
			STATE_STOP_BIT: // wait again until end of transmission
				nextState <= timerRollover? STATE_IDLE : STATE_STOP_BIT;
			default: nextState <= STATE_IDLE;
		endcase

	end

	// clock the next state
	always @(posedge clk50Mhz) begin
		state <= nextState;
		workingInput <= portRX;
	end

	// outputs
	always @(posedge clk50Mhz) begin
		timerMaximum <= 16'hffff; // largest value
		timerReset <= 1;
		workingData <= workingData;
		bitCountEnable <= 0;
		data <= data;
		case (state)
			STATE_IDLE: begin
				timerReset <= 0;
				workingData <= 0;
			end
			STATE_START_BIT:
				timerMaximum <= (CLKS_PER_BIT / 2); // wait for middle of data bit
			STATE_DATA_BITS: begin
				timerMaximum <= CLKS_PER_BIT;
				// add each bit to the working data
				if (timerRollover) begin
					workingData[bitCount] <= workingInput;
					bitCountEnable <= 1;
				end
			end
			STATE_STOP_BIT: begin
				timerMaximum <= CLKS_PER_BIT;
				// clock the working data into the output port
				if (timerRollover) begin
					data <= workingData;
				end
			end
			default;
		endcase

	end

	

	



endmodule

module counter  #(parameter width = 8)
                (input clk,
                input reset,
					 input enable,
					 input [width-1:0]maximum,
					 output reg [width-1:0]count,
					 output reg rollover);

	always @ (*) begin
		rollover <= 0;
		if (count >= maximum) rollover <= 1;
	end
	
	always @ (posedge clk) begin
		if (reset == 0) begin
			count <= 0;
		end
		else if (enable)
			if (count >= maximum) count <= 0;
			else count <= count + 1;
	
	end
	
	
endmodule

