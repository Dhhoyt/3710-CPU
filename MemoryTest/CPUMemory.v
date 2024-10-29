module CPUMemory(input clk, nextButton, resetButton, 
				output [9:0] leds, 
				output [6:0] hexA,
				output [6:0] hexB,
				output [6:0] hexC,
				output [6:0] hexD);
	

	parameter READ1   = 3'd0;
	parameter READ2   = 3'd1;
	parameter WRITE1  = 3'd2;
	parameter WRITE2  = 3'd3;
	parameter READ3   = 3'd4;
	parameter READ4   = 3'd5;
	parameter READ5   = 3'd6;
	parameter READ6   = 3'd7;

	reg [2:0] state;
	reg [2:0] nextState;

	reg writeEnableA;
	reg writeEnableB;
	reg [15:0] dataA;
	reg dataB;
	reg [15:0] addressA;
	reg addressB;
	wire [15:0] GPUData;
	wire [15:0] accessoryData;
	wire [15:0] outputA, outputB;

	memory #(.ADDR_WIDTH(12)) ram(dataA, dataB, addressA, addressB, writeEnableA, writeEnableB, clk, GPUData, accessoryData, outputA, outputB);

	hexTo7Seg readHigh(outputA[7:4], hexA);
	hexTo7Seg readLow(outputA[3:0], hexB);
	hexTo7Seg writeHigh(dataA[7:4], hexC);
	hexTo7Seg writeLow(dataA[3:0], hexD);

	assign leds = addressA[9:0];

	assign GPUData = 'h42;
	assign accessoryData = 'h37;

	always @(*) begin
		nextState = state + 1;
	end


	// rising edge detector on button
	reg buttonUp;
	always @ (posedge clk) begin
		if (!resetButton) state = 0;
		else if (nextButton && (!buttonUp)) state = nextState;
		buttonUp = nextButton;
	end


	always @(*) begin
		if (!resetButton) begin //reset button
			addressA <= 1;
			dataA <= 'h3A;
			writeEnableA <= 1;

			addressB <= 512;
			dataB <= 'h10;
			writeEnableB <= 1;
		end
		else begin
			writeEnableB = 0;
			dataB = 0;
			addressB = 0;

			writeEnableA <= 0;
			dataA <= 0;
			case (state) 
				READ1: addressA <= 1; // should read 3A
				READ2: addressA <= 512; // 10
				WRITE1: begin
					addressA <= 1;
					dataA <= 'hA0; // A0
					writeEnableA <= 1;
				end
				WRITE2: begin
					addressA <= 512;
					dataA <= 'h20; // 20
					writeEnableA <= 1;
				end
				READ3: addressA <= 1; // A0
				READ4: addressA <= 512; // 20
				READ5: addressA <= 20; //42
				READ6: addressA <= 21; //37
			endcase
		end
	end


	
	
	
endmodule
	