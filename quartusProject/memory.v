

/*
IO mapping:

0-f7ff:     Unampped Memory
f800-f93f:  Distance Buffer 1
f940-f9ff:  Blank (Allignment)
fa00-fb3f:  Texture  UV Buffer 1
fb40-fbff:  Blank (Allignment)
fc00-fd3f:  Distance Buffer 2
fd40-fdff:  Blank (Allignment)
fe00-ff3f:  Texture  UV Buffer 2
fffd:       Joystick X magnitude
fffe:       Joystick Y magnitude
ffff:       GPU Flags (Input buffer switch, output frame timing)

*/


module memory #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) (
	input [(DATA_WIDTH-1):0] inputA, inputB,
	input [(ADDR_WIDTH-1):0] addressA, addressB,
	input writeEnableA, writeEnableB,
	input clk,
	input [(DATA_WIDTH-1):0] GPUInput, // ideally the GPU should just use its write port
	input [7:0] accessoryInput,
	output reg [(DATA_WIDTH-1):0] outputA, outputB
	);

	parameter GPU_DATA_ADDRESS = 16'hffff;
	parameter JOYSTICK_X_ADDRESS = 16'hfffd; // joystick
	parameter JOYSTICK_Y_ADDRESS = 16'hfffd;
	

	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	reg [ADDR_WIDTH-1:0] addressAReg, addressBReg;

	reg [7:0] accessoryInputReg;

	initial begin
		$readmemh("/home/casey/Documents/School/ECE3710/quartusProjects/CPUMemory/raminit.dat", ram);
	end

	always @(posedge clk) begin
		accessoryInputReg <= accessoryInput;
	end

	//Port A
	always @(posedge clk) begin
		if (writeEnableA) begin
			ram[addressA] <= inputA;
		end
		addressAReg <= addressA; 
	end

	
	//Port B
	always @(posedge clk) begin
		if (writeEnableB) begin
			ram[addressB] <= inputB;
		end
		addressBReg <= addressB;
	end

	//Port A
	always @(*) begin
		if (addressAReg == GPU_DATA_ADDRESS) begin // memory mapped GPU 
			outputA = GPUInput;
		end
		else if (addressAReg == JOYSTICK_X_ADDRESS) begin // memory mapped input (from a joystick or something)
			outputA = accessoryInputReg[3:0];
		end
		else if (addressAReg == JOYSTICK_Y_ADDRESS) begin // memory mapped input (from a joystick or something)
			outputA = accessoryInputReg[7:4];
		end
		else 
			outputA = ram[addressAReg];
	end

	//Port B
	always @(*) begin
		if (addressBReg == GPU_DATA_ADDRESS) begin // memory mapped GPU 
			outputB = GPUInput;
		end
		else if (addressBReg == JOYSTICK_X_ADDRESS) begin // memory mapped input (from a joystick or something)
			outputB = accessoryInputReg[3:0];
		end
		else if (addressBReg == JOYSTICK_Y_ADDRESS) begin // memory mapped input (from a joystick or something)
			outputB = accessoryInputReg[7:4];
		end
		else
			outputB = ram[addressBReg];
	end
	
	


endmodule
