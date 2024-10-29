module gpuLookup #(parameter TEXTURE_SIZE = 64, parameter SCREEN_HEIGHT = 16'b1111000000000000) ( // Screen Height must be in Q8.8 format.
	input wire [15:0] distance,
	input wire [9:0] screen_y,
	output wire [$clog2(TEXTURE_SIZE):0] uv_y,
	output wire inside_wall
);

wire [15:0] screen_wall_height = (SCREEN_HEIGHT * 256)/distance;

parameter screen_half_height = SCREEN_HEIGHT / 2;

//attemptSubtractDivision screenHeightDiv(.dividend(SCREEN_HEIGHT), .divisor(distance), .quotient(screen_wall_height));

wire [15:0] wall_top_y = screen_half_height - (screen_wall_height / 2); // Q8.8 format wire
wire [15:0] wall_bottom_y = screen_half_height + (screen_wall_height / 2); // Q 8.8 format wire

assign inside_wall = (screen_y << 8) > wall_top_y && (screen_y << 8) < wall_bottom_y;

wire [15:0] dist_below_top = (screen_y << 8) - wall_top_y; // shift by 8 to convert to Q8.8
wire [15:0] total_wall_height = wall_bottom_y - wall_top_y;

wire [15:0] texture_y_ratio = (dist_below_top * 256) / total_wall_height;

//attemptSubtractDivision textureRatioDiv(.dividend(dist_below_top), .divisor(total_wall_height), .quotient(texture_y_ratio));

assign uv_y = (texture_y_ratio * TEXTURE_SIZE) >> 8; // TEXTURE_SIZE isn't Q8.8 but rather int so it preserves Q8.8, then shift by 8 to convert to int
endmodule