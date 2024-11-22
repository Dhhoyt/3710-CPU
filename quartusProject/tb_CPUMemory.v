

module tb_CPUMemory;

	reg clk;
	reg writeEnableA, writeEnableB;
	reg [15:0] dataA, dataB;
	reg [15:0] addressA, addressB;
	reg [15:0] GPUData;
	reg [15:0] accessoryData;
	wire [15:0] outputA, outputB;

	CPUMemory #(.ADDR_WIDTH(16)) ram(dataA, dataB, addressA, addressB, writeEnableA, writeEnableB, clk, GPUData, accessoryData, outputA, outputB);

	always begin // simulate a clock
		//  clk = 1;
		//  #1;
		//  clk = 0;
		//  #1;
	end

	initial begin
		GPUData = 20;
		accessoryData = 40;

		clk = 0;

		dataA = 5;
		dataB = 10;
		addressA = 10;
		addressB = 11;
		writeEnableA = 1;
		writeEnableB = 1;

		#1 clk = 1;
		#1 clk = 0;

		writeEnableA = 0;
		writeEnableB = 0;

		#1 clk = 1;
		#1 clk = 0;

		addressA = 12;
		addressB = 13;

		#1 clk = 1;
		#1 clk = 0;

		addressA = 1;
		addressB = 2;

		#1 clk = 1;
		#1 clk = 0;
		
		addressA = 2;
		addressB = 1;

		#1 clk = 1;
		#1 clk = 0;

	end

	


endmodule


