module memoryMappedIO
    (input clock,
     input [15:0] write_data_a, write_data_b,
     input [15:0] address_a, address_b,
     input write_enable_a, write_enable_b,
	  input [7:0] IODataIn,
     output reg [15:0] muxReadDataA, muxReadDataB );

	wire [15:0] readDataMemoryA;
	wire [15:0] readDataMemoryB;

	memory memory1(
        clock, 
        write_data_a, write_data_b,
        address_a, address_b,
        write_enable_a, write_enable_b,
        readDataMemoryA, readDataMemoryB
    );


	always @(*) begin
		if (address_a == 65533) muxReadDataA = IODataIn[7:4];
		else if (address_a == 65534) muxReadDataA = IODataIn[3:0];
		else muxReadDataA = readDataMemoryA;
	end

	always @(*) begin
		if (address_b == 65533) muxReadDataB = IODataIn[7:4];
		else if (address_b == 65534) muxReadDataB = IODataIn[3:0];
		else muxReadDataB = readDataMemoryB;
	end


endmodule
