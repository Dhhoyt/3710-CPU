/********************************************************************************
* GPU Texture Coordinate Lookup Module
*
* This module calculates texture coordinates and wall boundaries for raycasting
* rendering. It uses fixed-point Q8.8 arithmetic to compute wall heights and 
* mapping coordinates based on ray distances.
*
* Key Features:
* - Fixed-point Q8.8 arithmetic for precise distance/height calculations
* - Efficient texture coordinate mapping using ratios
* - Wall boundary detection for rendering decisions
* - Parametrized texture size and screen height settings
*
* Parameters:
* - TEXTURE_SIZE: Size of texture in pixels (default 64)
* - SCREEN_HEIGHT: Screen height in Q8.8 format (default 0xF000)
*
* Operation:
* 1. Computes projected wall height based on distance
* 2. Determines wall top/bottom screen coordinates
* 3. Tests current screen_y against wall boundaries
* 4. Calculates texture y-coordinate using ratio mapping
*
* Signal Descriptions:
* Inputs:
*   distance [15:0]     - Ray distance to wall in Q8.8 format
*   screen_y [9:0]      - Current screen y-coordinate
*
* Outputs:
*   uv_y               - Vertical texture coordinate
*   inside_wall        - High when screen_y is within wall boundaries
*   above_wall         - High when screen_y is above wall 
*
* Fixed-Point Calculations:
* - screen_wall_height = (SCREEN_HEIGHT * 256)/distance 
*   Wall height in screen pixels, adjusted for perspective
*
* - wall_top_y = screen_half_height - (screen_wall_height/2)
*   Screen y-coordinate of wall top edge
*
* - wall_bottom_y = screen_half_height + (screen_wall_height/2)
*   Screen y-coordinate of wall bottom edge
* 
* - dist_below_top = (screen_y << 8) - wall_top_y
*   Distance from top of wall in Q8.8
*
* - texture_y_ratio = (dist_below_top * 256) / total_wall_height
*   Normalized position within wall height (0.0 to 1.0)
*
* - uv_y = (texture_y_ratio * TEXTURE_SIZE) >> 8
*   Final texture coordinate scaled to texture size
*
* Notes:
* - All height/distance calculations use Q8.8 fixed-point format
* - Division operations preserve fixed-point precision
* - Final uv_y output is scaled back to integer coordinates
********************************************************************************/

module gpuLookup #(parameter TEXTURE_SIZE = 64, parameter SCREEN_HEIGHT = 16'b1111000000000000) ( // Screen Height must be in Q8.8 format.
	input wire [15:0] distance,
	input wire [9:0] screen_y,
	output wire [$clog2(TEXTURE_SIZE)-1:0] uv_y,
	output wire inside_wall,
	output wire above_wall
);

wire signed [32:0] screen_wall_height = (SCREEN_HEIGHT * 256)/distance;

parameter screen_half_height = SCREEN_HEIGHT / 2;

//attemptSubtractDivision screenHeightDiv(.dividend(SCREEN_HEIGHT), .divisor(distance), .quotient(screen_wall_height));

wire signed [32:0] wall_top_y = screen_half_height - (screen_wall_height / 2); // Q8.8 format wire
wire signed [32:0] wall_bottom_y = screen_half_height + (screen_wall_height / 2); // Q 8.8 format wire

wire signed [32:0] shifted_y = screen_y << 8;

assign above_wall = shifted_y <= wall_top_y;
assign inside_wall = shifted_y > wall_top_y && shifted_y < wall_bottom_y;

wire signed [32:0] dist_below_top = (screen_y << 8) - wall_top_y; // shift by 8 to convert to Q8.8
wire signed [32:0] total_wall_height = wall_bottom_y - wall_top_y;

wire signed [32:0] texture_y_ratio = (dist_below_top * 256) / total_wall_height;

//attemptSubtractDivision textureRatioDiv(.dividend(dist_below_top), .divisor(total_wall_height), .quotient(texture_y_ratio));

assign uv_y = (texture_y_ratio * TEXTURE_SIZE) >> 8; // TEXTURE_SIZE isn't Q8.8 but rather int so it preserves Q8.8, then shift by 8 to convert to int
endmodule
