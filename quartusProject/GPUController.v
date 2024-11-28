module GPUController(
	input wire clk,
	input wire clr,
	input wire [15:0] read_data,
	output wire [15:0] read_address,
	output wire h_sync,
    output wire v_sync,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
	output wire vga_clock,
	output wire vga_sync,
	output wire vga_blank
);

localparam DISTANCE_1 = 16'd63488;
localparam DISTANCE_2 = 16'd64512;
localparam TEXTURE_1 = 16'd64000;
localparam TEXTURE_2 = 16'd64512;

localparam WAITING = 4'd0;
localparam READING_FLAGS = 4'd0;

reg buffer_select;
wire [8:0] reading_index;
reg [3:0] state, next_state;


wire [15:0] read_distance_address = buffer_select : reading_index + DISTANCE_2 ? reading_index + DISTANCE_1;
wire [15:0] read_texture_address  = buffer_select : reading_index + TEXTURE_2 ? reading_index + TEXTURE_1  ;


mux4 memory_mux (read_distance_address)

GPU gpu( 
	.clk(clk),
    .clr(clr),
	input wire [15:0] distance,
	input wire [15:0] texture,
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

always @ (*) begin
	case(state)
		WAITING: 
			begin
				if(~h_sync)
					next_state <= READING_FLAGS;
				else
					next_state <= WAITING;
			end
		
		default:
			next_state <= WAITING;
	endcase
end

always @ (*) begin
	case(state)

	endcase
end

always @ (negedge clr) begin
	buffer_select <= 0;
	state <= WAITING;
end

endmodule