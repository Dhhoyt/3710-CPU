/*******************************************************************************
* Ray-Wall Intersection Calculator for 3D Raycasting Engine
*
* This module calculates intersections between a ray and wall segment using
* line-line intersection algorithms. It's optimized for real-time raycasting
* graphics with fixed-point arithmetic (Q8.8 format) to balance precision 
* and hardware efficiency.
*
* Fixed-Point Format:
* - Input coordinates use Q8.8 (8 integer bits, 8 fractional bits)
* - Internal calculations expand to prevent overflow
* - Careful scaling maintains precision through operations
*
* Algorithm:
* 1. Computes intersection parameters using determinant method
* 2. Validates intersection point location
* 3. Calculates distance and texture coordinates if valid
* 4. Handles edge cases (parallel lines, small denominators)
*
* Outputs provide:
* - Valid intersection detection
* - Distance to intersection for wall height calculation
* - Texture coordinate for wall rendering
*******************************************************************************/

module rayCast(
    input wire signed [15:0] x1, // Ray origin x (Q8.8)
    input wire signed [15:0] y1, // Ray origin y (Q8.8)
    input wire signed [15:0] x2, // Ray endpoint x (Q8.8)
    input wire signed [15:0] y2, // Ray endpoint y (Q8.8)
    input wire signed [15:0] x3, // Wall start x (Q8.8)
    input wire signed [15:0] y3, // Wall start y (Q8.8)
    input wire signed [15:0] x4, // Wall end x (Q8.8)
    input wire signed [15:0] y4, // Wall end y (Q8.8)
    input wire [15:0] texture_id, // Identifies which texture to use for this wall
    output wire intersection,     // High if intersection is valid
    output wire signed [15:0] ray_distance, // Distance to intersection (Q8.8)
    output wire signed [15:0] uv_x // Texture sampling coordinate (0-63)
);
    
    // Scale factor for fixed-point calculations (2^16)
    wire signed [31:0] offset = 1 <<< 16;

    // Calculate direction vectors for ray and wall
    wire signed [15:0] ray_dx = x1 - x2;  // Ray direction X
    wire signed [15:0] ray_dy = y1 - y2;  // Ray direction Y
    wire signed [15:0] wall_dx = x3 - x4; // Wall direction X
    wire signed [15:0] wall_dy = y3 - y4; // Wall direction Y

    // Calculate denominator for intersection parameters (Q16.16 format)
    wire signed [31:0] demnominator = (ray_dx * wall_dy) - (ray_dy * wall_dx);

    // Calculate numerators for intersection parameters (Q32.16 format with offset)
    wire signed [47:0] t_numerator = (((x1 - x3) * (wall_dy)) - ((y1 - y3) * (wall_dx))) * offset;
    wire signed [47:0] u_numerator = -(((ray_dx) * (y1 - y3)) - ((ray_dy) * (x1 - x3))) * offset;

    // Check for parallel lines
    wire parallel = demnominator == 0;

    // Calculate intersection parameters, accounting for parallel case
    wire signed [31:0] t_unchecked = (t_numerator / demnominator);
    wire signed [31:0] u_unchecked = (u_numerator / demnominator);
    wire signed [31:0] t = ~parallel ? t_unchecked : -1;
    wire signed [31:0] u = ~parallel ? u_unchecked : -1;

    // Prevent division by very small numbers that could cause precision issues
    wire small_denom = (demnominator > -256 && demnominator < 256);

    // Determine if intersection is valid
    assign intersection = ~parallel && ~small_denom && t >= 0 && u >= 0 && u <= offset;

    // Calculate ray length for distance computation
    wire [31:0] distance_squared_ray = ray_dx * ray_dx + ray_dy * ray_dy;
    wire [15:0] unchecked_t_distance;
    sqrt32to16 raySqrt(
        .x(distance_squared_ray),
        .res(unchecked_t_distance)
    );
    
    // Calculate final ray distance, scaled by intersection parameter
    wire [15:0] unchecked_ray_distance = (unchecked_t_distance * t) >> 16;
    assign ray_distance = intersection ? unchecked_ray_distance : 0;

    // Calculate wall length for texture coordinate computation
    wire [31:0] distance_squared_wall = wall_dx * wall_dx + wall_dy * wall_dy;
    wire [15:0] unchecked_u_distance;
    sqrt32to16 wallSqrt(
        .x(distance_squared_wall),
        .res(unchecked_u_distance)
    );
    
    // Calculate texture coordinate, incorporating texture ID and intersection position
    wire [15:0] unchecked_wall_distance = (unchecked_u_distance * u * 64) >> 24;
    assign uv_x = intersection ? {6'b0, texture_id[1:0], 2'b0, unchecked_wall_distance[5:0]} : 0;
endmodule
