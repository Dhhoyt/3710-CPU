/* 
Separate file for memory mapped IO. This helps quartus
detect the RAM megafunction in memory.v. Memory mapped addresses 
are documented in memmap_layout.txt
*/

module memoryMappedIO
    (input clock,
     input [15:0] write_data_a, write_data_b,
     input [15:0] address_a, address_b,
     input write_enable_a, write_enable_b,
	  input [7:0] IODataIn,
     output reg [15:0] muxReadDataA, muxReadDataB );

	wire [15:0] readDataMemoryA;
	wire [15:0] readDataMemoryB;

	// RAM
	memory memory1(
        clock, 
        write_data_a, write_data_b,
        address_a, address_b,
        write_enable_a, write_enable_b,
        readDataMemoryA, readDataMemoryB
    );

	// multiplexers for each port and each special address
	always @(*) begin
		if (address_a == 65533) muxReadDataA = IODataIn[3:0];
		else if (address_a == 65534) muxReadDataA = {12'd0, IODataIn[7:4]};
		else muxReadDataA = readDataMemoryA;
	end

	always @(*) begin
		if (address_b == 65533) muxReadDataB = IODataIn[3:0];
		else if (address_b == 65534) muxReadDataB = {12'd0, IODataIn[7:4]};
		else muxReadDataB = readDataMemoryB;
	end


endmodule
