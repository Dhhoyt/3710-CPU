module GPUTest(
    input wire clock, reset,
    output wire h_sync,
    output wire v_sync,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
	output wire vga_clock,
	output wire vga_sync,
	output wire vga_blank
);

reg [15:0] distances [319:0];

wire [8:0] reading_index;

initial begin
	$readmemh("C:/Users/dhhoy/3710-CPU/quartusProject/data_files/testdist1.dat", distances);
end

GPU gpu(
     clock,
     reset,
	distances[reading_index],
	16'b0,
    h_sync,
    v_sync,
    red,
    green,
    blue,
	 reading_index, // enough to address 320 addresses
	vga_clock,
	vga_sync,
	vga_blank
);

endmodule