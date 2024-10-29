module GPU(
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

reg [15:0] distances [319:0];

initial begin
	$display("Loading memory");
	$readmemb("C:/Users/dhhoy/3710-CPU/quartusProject/distances.txt", distances);
	$display("done loading");
end

parameter LOOKAHEAD_COUNT = 8;

parameter [2:0] LOOKAHEAD_1 = 3'b000;
parameter [2:0] LOOKAHEAD_2 = 3'b001;
parameter [2:0] LOOKAHEAD_3 = 3'b010;
parameter [2:0] LOOKAHEAD_4 = 3'b011;
parameter [2:0] LOOKAHEAD_5 = 3'b100;
parameter [2:0] LOOKAHEAD_6 = 3'b101;
parameter [2:0] LOOKAHEAD_7 = 3'b110;
parameter [2:0] LOOKAHEAD_8 = 3'b111;

parameter h_front_porch_width = 48 + 96 + 1;

wire vga_clk_en;
wire pixel_clk;

reg [2:0] next_state;
reg [2:0] state;

wire [9:0] row;
wire [9:0] real_row = row/2;
wire [9:0] column_internal;

wire [9:0] lookahead_column = (column_internal - h_front_porch_width)/2 + LOOKAHEAD_COUNT;
reg [15:0] active_distances[LOOKAHEAD_COUNT - 1:0];
wire [7:0] texture_uv_ys[LOOKAHEAD_COUNT - 1:0];	
wire inside_wall[LOOKAHEAD_COUNT - 1:0];

wire above_column;
wire row_clr = ~above_column && clr;

reg active_inside_wall;
reg [7:0] active_uv_y;

gpuLookup l0(.distance(active_distances[0]), .screen_y(real_row), .inside_wall(inside_wall[0]), .uv_y(texture_uv_ys[0]));
gpuLookup l1(.distance(active_distances[1]), .screen_y(real_row), .inside_wall(inside_wall[1]), .uv_y(texture_uv_ys[1]));
gpuLookup l2(.distance(active_distances[2]), .screen_y(real_row), .inside_wall(inside_wall[2]), .uv_y(texture_uv_ys[2]));
gpuLookup l3(.distance(active_distances[3]), .screen_y(real_row), .inside_wall(inside_wall[3]), .uv_y(texture_uv_ys[3]));
gpuLookup l4(.distance(active_distances[4]), .screen_y(real_row), .inside_wall(inside_wall[4]), .uv_y(texture_uv_ys[4]));
gpuLookup l5(.distance(active_distances[5]), .screen_y(real_row), .inside_wall(inside_wall[5]), .uv_y(texture_uv_ys[5]));
gpuLookup l6(.distance(active_distances[6]), .screen_y(real_row), .inside_wall(inside_wall[6]), .uv_y(texture_uv_ys[6]));
gpuLookup l7(.distance(active_distances[7]), .screen_y(real_row), .inside_wall(inside_wall[7]), .uv_y(texture_uv_ys[7]));


assign red   = active_inside_wall ? 8'b00000000 : 8'b11111111;
assign green = active_inside_wall ? {active_uv_y, 2'b00} : 8'b00000000;
assign blue = 8'b00000000;

always @ (posedge clk) begin
	if (pixel_clk) begin
		if (~row_clr)
			state <= LOOKAHEAD_1;	
		else begin
			case (state)
				LOOKAHEAD_1: begin
									active_distances[0] <= distances[lookahead_column];
								 end
				LOOKAHEAD_2: begin
									active_distances[1] <= distances[lookahead_column];
								 end
				LOOKAHEAD_3: begin
									active_distances[2] <= distances[lookahead_column];
								 end
				LOOKAHEAD_4: begin
									active_distances[3] <= distances[lookahead_column];
								 end
				LOOKAHEAD_5: begin
									active_distances[4] <= distances[lookahead_column];
								 end
				LOOKAHEAD_6: begin
									active_distances[5] <= distances[lookahead_column];
								 end
				LOOKAHEAD_7: begin
									active_distances[6] <= distances[lookahead_column];
								 end
				LOOKAHEAD_8: begin
									active_distances[7] <= distances[lookahead_column];
								 end
			endcase
			state <= next_state;
		end
	end
end

always @ (*) begin
	case (state)
		LOOKAHEAD_1: begin
							next_state = LOOKAHEAD_2;
							active_inside_wall = inside_wall[0];
							active_uv_y = texture_uv_ys[0];
						 end
		LOOKAHEAD_2: begin
							next_state = LOOKAHEAD_3;
							active_inside_wall = inside_wall[1];
							active_uv_y = texture_uv_ys[1];
						 end
		LOOKAHEAD_3: begin
							next_state = LOOKAHEAD_4;
							active_inside_wall = inside_wall[2];
							active_uv_y = texture_uv_ys[2];
						 end
		LOOKAHEAD_4: begin
							next_state = LOOKAHEAD_5;
							active_inside_wall = inside_wall[3];
							active_uv_y = texture_uv_ys[3];
						 end
		LOOKAHEAD_5: begin
							next_state = LOOKAHEAD_6;
							active_inside_wall = inside_wall[4];
							active_uv_y = texture_uv_ys[4];
						 end
		LOOKAHEAD_6: begin
							next_state = LOOKAHEAD_7;
							active_inside_wall = inside_wall[5];
							active_uv_y = texture_uv_ys[5];
						 end
		LOOKAHEAD_7: begin
							next_state = LOOKAHEAD_8;
							active_inside_wall = inside_wall[6];
							active_uv_y = texture_uv_ys[6];
						 end
		LOOKAHEAD_8: begin
							next_state = LOOKAHEAD_1;
							active_inside_wall = inside_wall[7];
							active_uv_y = texture_uv_ys[7];
						 end				 
		default: begin
						next_state = LOOKAHEAD_1;
						active_inside_wall = 1'b1;
						active_uv_y = 0;
					end
	endcase
end

assign vga_sync = 1'b0;

clockDivider #(.DIVISIONS(2)) vgaClkDiv(.clk(clk), .clr(clr), .divided_clk(vga_clk_en));
clockDivider #(.DIVISIONS(4), .INITIAL_VALUE(0)) pixelClkDiv(.clk(clk), .clr(row_clr), .divided_clk(pixel_clk));
assign vga_clock = ~vga_clk_en;
vgaContoller vga_cont(
	.clk(clk),
	.en(vga_clk_en),
	.clr(clr), 
	.h_sync(h_sync), 
	.v_sync(v_sync), 
	.in_display(vga_blank), 
	.row(row),
	.column_internal(column_internal),
	.above_column(above_column)
);

endmodule