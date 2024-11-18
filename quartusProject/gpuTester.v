module gpuTester(
    input wire clk,
    input wire clr,
    output wire h_sync,
    output wire v_sync,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
	 output wire vga_clock,
	 output wire vga_sync,
	 output wire vga_blank
);

reg [5:0] uvs       [319:0];
reg [15:0] distances [319:0];

initial begin
	$readmemb("uvs.dat", uvs);
	$readmemb("distances.dat", distances);
end


wire [15:0] texture = uvs[reading_index];
wire [15:0] distance = distances[reading_index];

wire [8:0] reading_index;

GPU gpu(
    .clk(clk),
    .clr(clr),
	 .distance(distance),
	 .texture(texture),
	 .active_buffer(0),
    .h_sync(h_sync),
    .v_sync(v_sync),
    .red(red),
    .green(green),
    .blue(blue),
	 .reading_index(reading_index), // enough to address 320 addresses
	 .vga_clock(vga_clock),
	 .vga_sync(vga_sync),
	 .vga_blank(vga_blank)
);

endmodule