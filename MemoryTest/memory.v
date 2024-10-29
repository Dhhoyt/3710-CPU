



module memory #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) (
	input [(DATA_WIDTH-1):0] inputA, inputB,
	input [(ADDR_WIDTH-1):0] addressA, addressB,
	input writeEnableA, writeEnableB,
	input clk,
	input [(DATA_WIDTH-1):0] GPUInput, // ideally the GPU should just use its write port
	input [(DATA_WIDTH-1):0] accessoryInput, // also should probably make sure these are registers
	output reg [(DATA_WIDTH-1):0] outputA, outputB
	);

	parameter GPU_DATA_ADDRESS = 20;
	parameter ACCESSORY_ADDRESS = 21;


	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	reg [ADDR_WIDTH-1:0] addressAReg, addressBReg;

	initial begin
		$readmemh("/home/casey/Documents/School/ECE3710/quartusProjects/CPUMemory/raminit.dat", ram);
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
		else if (addressAReg == ACCESSORY_ADDRESS) begin // memory mapped input (from a joystick or something)
			outputA = accessoryInput;
		end
		else 
			outputA = ram[addressAReg];
	end

	//Port B
	always @(*) begin
		if (addressBReg == GPU_DATA_ADDRESS) begin // memory mapped GPU 
			outputB = GPUInput;
		end
		else if (addressBReg == ACCESSORY_ADDRESS) begin // memory mapped input (from a joystick or something)
			outputB = accessoryInput;
		end
		else
			outputB = ram[addressBReg];
	end
	
	


endmodule
