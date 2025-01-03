/********************************************************************************
* GPU Module - 3D Graphics Pipeline Implementation
*
* This module is a VGA-based graphics processor that renders 3D scenes with textured
* walls using a raycasting technique. It features a parallel pipeline of 8 lookahead 
* units to maintain high throughput despite complex per-pixel calculations.
*
* Core Features:
* - 8-stage parallel pipeline for distance/texture processing
* - VGA-compatible timing and output signals
* - Texture mapping with multiple texture support
* - Fixed-point distance calculations
* - Double-buffered scanline rendering
*
* Pipeline Operation:
* - Each of 8 lookahead stages processes one column segment at a time
* - Processes walls based on distance and texture information
* - Computes UV coordinates for texture mapping
* - Handles wall visibility and sky/floor rendering
*
* Signal Flow:
* 1. Input: Receives distance and texture data per column
* 2. Processing: 
*    - Divides screen into 8 parallel segments
*    - Each segment processes distance to determine wall height
*    - Computes texture coordinates based on wall distance and position
* 3. Output:
*    - Generates RGB color values based on texture sampling
*    - Produces VGA sync and timing signals
*    - Controls pixel clock and display timing
*
* State Machine:
* - 8 states (LOOKAHEAD_1 through LOOKAHEAD_8) for pipeline stages
* - Each state loads new distance/texture data and processes one segment
* - Round-robin processing ensures continuous pixel output
*
* Memory Management:
* - Maintains arrays for active distances, texture coordinates
* - Uses texture ROM for wall patterns
* - Double-buffered processing for smooth display
*
* Color Output:
* - 8-bit RGB channels
* - Sky color: RGB(48,48,48) above walls
* - Floor color: RGB(96,96,96) below walls
* - Wall colors: Sampled from texture based on UV coordinates
*
* Timing Control:
* - VGA clock division for 25MHz pixel clock
* - Pixel clock division for processing synchronization
* - Horizontal/Vertical sync generation for display timing
*
* Key Parameters:
* - LOOKAHEAD_COUNT: Number of parallel processing stages (8)
* - h_front_porch_width: VGA timing parameter (145)
*
* Inputs:
* - clk: System clock input
* - clr: Reset signal
* - distance[15:0]: Wall distance data
* - texture[15:0]: Texture and UV coordinate data
*
* Outputs:
* - h_sync, v_sync: VGA synchronization signals
* - red[7:0], green[7:0], blue[7:0]: RGB color output
* - reading_index[8:0]: Memory read address for distance/texture data
* - vga_clock: Pixel clock output
* - vga_sync, vga_blank: Additional VGA control signals
********************************************************************************/

module GPU(
   input wire clk,
   input wire clr,
	input wire [15:0] distance,
	input wire [15:0] texture,
   output wire h_sync,
   output wire v_sync,
	output wire [7:0] red,
   output wire [7:0] green,
   output wire [7:0] blue,
	output wire [8:0] reading_index, // enough to address 320 addresses
	output wire vga_clock,
	output wire vga_sync,
	output wire vga_blank
);

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

assign reading_index = (column_internal - h_front_porch_width)/2 + LOOKAHEAD_COUNT;
reg [15:0] active_distances[LOOKAHEAD_COUNT - 1:0];
wire [5:0] texture_uv_ys[LOOKAHEAD_COUNT - 1:0];
reg [5:0] texture_uv_xs[LOOKAHEAD_COUNT - 1:0];	
reg [1:0] texture_ids[LOOKAHEAD_COUNT - 1:0];	

wire inside_wall[LOOKAHEAD_COUNT - 1:0];
wire above_wall[LOOKAHEAD_COUNT - 1:0];

wire above_column;
wire row_clr = ~above_column && clr;

reg active_inside_wall;
reg active_above_wall;
reg [5:0] active_uv_x;
reg [5:0] active_uv_y;
reg [1:0] active_id;

gpuLookup l0(.distance(active_distances[0]), .screen_y(real_row), .above_wall(above_wall[0]), .inside_wall(inside_wall[0]), .uv_y(texture_uv_ys[0]));
gpuLookup l1(.distance(active_distances[1]), .screen_y(real_row), .above_wall(above_wall[1]), .inside_wall(inside_wall[1]), .uv_y(texture_uv_ys[1]));
gpuLookup l2(.distance(active_distances[2]), .screen_y(real_row), .above_wall(above_wall[2]), .inside_wall(inside_wall[2]), .uv_y(texture_uv_ys[2]));
gpuLookup l3(.distance(active_distances[3]), .screen_y(real_row), .above_wall(above_wall[3]), .inside_wall(inside_wall[3]), .uv_y(texture_uv_ys[3]));
gpuLookup l4(.distance(active_distances[4]), .screen_y(real_row), .above_wall(above_wall[4]), .inside_wall(inside_wall[4]), .uv_y(texture_uv_ys[4]));
gpuLookup l5(.distance(active_distances[5]), .screen_y(real_row), .above_wall(above_wall[5]), .inside_wall(inside_wall[5]), .uv_y(texture_uv_ys[5]));
gpuLookup l6(.distance(active_distances[6]), .screen_y(real_row), .above_wall(above_wall[6]), .inside_wall(inside_wall[6]), .uv_y(texture_uv_ys[6]));
gpuLookup l7(.distance(active_distances[7]), .screen_y(real_row), .above_wall(above_wall[7]), .inside_wall(inside_wall[7]), .uv_y(texture_uv_ys[7]));

wire [7:0] color;

textureROM texture_lookup(
	.texture_id(active_id),
	.x(active_uv_x),
	.y(active_uv_y),
	.q(color)
);

assign red = active_inside_wall ? {color[7:5], color[7:5], color[7:6]}  : (active_above_wall ? 48: 96);
assign green = active_inside_wall ? {color[4:2], color[4:2], color[4:3]} : (active_above_wall ? 48: 96);
assign blue = active_inside_wall ? {color[1:0], color[1:0], color[1:0], color[1:0]} : (active_above_wall ? 48: 96);

always @ (posedge clk) begin
	if (pixel_clk) begin

		if (~row_clr)
			state <= LOOKAHEAD_1;	
		else begin
			case (state)
				LOOKAHEAD_1: begin
									active_distances[0] <= distance;
									texture_uv_xs[0] <= texture[5:0];
									texture_ids[0] <= texture[9:8];
								 end
				LOOKAHEAD_2: begin
									active_distances[1] <= distance;
									texture_uv_xs[1] <= texture[5:0];
									texture_ids[1] <= texture[9:8];
								 end
				LOOKAHEAD_3: begin
									active_distances[2] <= distance;
									texture_uv_xs[2] <= texture[5:0];
									texture_ids[2] <= texture[9:8];
								 end
				LOOKAHEAD_4: begin
									active_distances[3] <= distance;
									texture_uv_xs[3] <= texture[5:0];
									texture_ids[3] <= texture[9:8];
								 end
				LOOKAHEAD_5: begin
									active_distances[4] <= distance;
									texture_uv_xs[4] <= texture[5:0];
									texture_ids[4] <= texture[9:8];
								 end
				LOOKAHEAD_6: begin
									active_distances[5] <= distance;
									texture_uv_xs[5] <= texture[5:0];
									texture_ids[5] <= texture[9:8];
								 end
				LOOKAHEAD_7: begin
									active_distances[6] <= distance;
									texture_uv_xs[6] <= texture[5:0];
									texture_ids[6] <= texture[9:8];
								 end
				LOOKAHEAD_8: begin
									active_distances[7] <= distance;
									texture_uv_xs[7] <= texture[5:0];
									texture_ids[7] <= texture[9:8];
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
							active_above_wall = above_wall[0];
							active_uv_y = texture_uv_ys[0];
							active_uv_x = texture_uv_xs[0];
							active_id = texture_ids[0];
						 end
		LOOKAHEAD_2: begin
							next_state = LOOKAHEAD_3;
							active_inside_wall = inside_wall[1];
							active_above_wall = above_wall[1];
							active_uv_y = texture_uv_ys[1];
							active_uv_x = texture_uv_xs[1];
							active_id = texture_ids[1];
						 end
		LOOKAHEAD_3: begin
							next_state = LOOKAHEAD_4;
							active_inside_wall = inside_wall[2];
							active_above_wall = above_wall[2];
							active_uv_y = texture_uv_ys[2];
							active_uv_x = texture_uv_xs[2];
							active_id = texture_ids[2];
						 end
		LOOKAHEAD_4: begin
							next_state = LOOKAHEAD_5;
							active_inside_wall = inside_wall[3];
							active_above_wall = above_wall[3];
							active_uv_y = texture_uv_ys[3];
							active_uv_x = texture_uv_xs[3];
							active_id = texture_ids[3];
						 end
		LOOKAHEAD_5: begin
							next_state = LOOKAHEAD_6;
							active_inside_wall = inside_wall[4];
							active_above_wall = above_wall[4];
							active_uv_y = texture_uv_ys[4];
							active_uv_x = texture_uv_xs[4];
							active_id = texture_ids[4];
						 end
		LOOKAHEAD_6: begin
							next_state = LOOKAHEAD_7;
							active_inside_wall = inside_wall[5];
							active_above_wall = above_wall[5];
							active_uv_y = texture_uv_ys[5];
							active_uv_x = texture_uv_xs[5];
							active_id = texture_ids[5];
						 end
		LOOKAHEAD_7: begin
							next_state = LOOKAHEAD_8;
							active_inside_wall = inside_wall[6];
							active_above_wall = above_wall[6];
							active_uv_y = texture_uv_ys[6];
							active_uv_x = texture_uv_xs[6];
							active_id = texture_ids[6];
						 end
		LOOKAHEAD_8: begin
							next_state = LOOKAHEAD_1;
							active_inside_wall = inside_wall[7];
							active_above_wall = above_wall[7];
							active_uv_y = texture_uv_ys[7];
							active_uv_x = texture_uv_xs[7];
							active_id = texture_ids[7];
						 end				 
		default: begin
						next_state = LOOKAHEAD_1;
						active_inside_wall = 1'b1;
						active_above_wall = 1'b0;
						active_uv_y = 0;
						active_uv_x = 0;
						active_id = 0;
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
	.clr(1'b1), 
	.h_sync(h_sync), 
	.v_sync(v_sync), 
	.in_display(vga_blank), 
	.row(row),
	.column_internal(column_internal),
	.above_column(above_column)
);

endmodule
