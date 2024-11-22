module gpuTester(
    input wire clk,
    input wire clr,
	 input wire buffer_select,
    output wire h_sync,
    output wire v_sync,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
	 output wire vga_clock,
	 output wire vga_sync,
	 output wire vga_blank
);

reg [5:0] uvs1       [319:0];
reg [15:0] distances1 [319:0];
reg [5:0] uvs2       [319:0];
reg [15:0] distances2 [319:0];

wire reading_buffer;

initial begin
	$readmemb("data_files/uvs1.dat", uvs1);
	$readmemb("data_files/distances1.dat", distances1);
	$readmemb("data_files/uvs2.dat", uvs2);
	$readmemb("data_files/distances2.dat", distances2);
end


reg [15:0] texture;// = uvs[reading_index];
reg [15:0] distance;// = distances[reading_index];


always @ (*) begin
	if (~reading_buffer) begin
		texture <= uvs1[reading_index];
		distance <= distances1[reading_index];
	end else begin
		texture <= uvs2[reading_index];
		distance <= distances2[reading_index];
	end
end

wire [8:0] reading_index;

GPU gpu(
    .clk(clk),
    .clr(clr),
	 .distance(distance),
	 .texture(texture),
	 .buffer_select(buffer_select),
    .h_sync(h_sync),
    .v_sync(v_sync),
    .red(red),
    .green(green),
    .blue(blue),
	 .reading_index(reading_index), // enough to address 320 addresses
	 .reading_buffer(reading_buffer),
	 .vga_clock(vga_clock),
	 .vga_sync(vga_sync),
	 .vga_blank(vga_blank)
);

endmodule