module rayCast(
    input wire signed [15:0] x1, // Ray point 1 x-coordinate (Q8.8)
    input wire signed [15:0] y1, // Ray point 1 y-coordinate (Q8.8)
    input wire signed [15:0] x2, // Ray point 2 x-coordinate (Q8.8)
    input wire signed [15:0] y2, // Ray point 2 y-coordinate (Q8.8)
    input wire signed [15:0] x3, // Wall point 1 x-coordinate (Q8.8)
    input wire signed [15:0] y3, // Wall point 1 y-coordinate (Q8.8)
    input wire signed [15:0] x4, // Wall point 2 x-coordinate (Q8.8)
    input wire signed [15:0] y4, // Wall point 2 y-coordinate (Q8.8)
    output wire intersection, // Goes high if the intersection is valid
    output wire signed [15:0] ray_distance, // Distance the ray travels to intersection
    output wire signed [15:0] uv_x // How far along the wall for texture sampling
);

	
	 wire signed [31:0] offset = 1 <<< 16;


	 // Q8.8 means a number (Posssibly with a decimal value * 2^8 and given 16 bits)
    // https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_points_on_each_line_segment
	 // Please kill me
	 // Q8.8 numbers subtracted yield other Q8.8 noumbers. Nothing special has to be done
    wire signed [15:0] ray_dx = x1 - x2;
    wire signed [15:0] ray_dy = y1 - y2;
    wire signed [15:0] wall_dx = x3 - x4;
    wire signed [15:0] wall_dy = y3 - y4;
	 // Multiplying a Q8.8 number, x, with another, y, is ((x * 2^8) * (y *2^8)) = z * 2^16 
	 // so we have 16 decmimal places and 16 interger places (Because squaring can double the interger digits)
	 // After the multiplication, the subtraciton respects the exponent
    wire signed [31:0] demnominator = (ray_dx * wall_dy) - (ray_dy * wall_dx); // Q16.16 wire 
    wire signed [31:0] t_numerator =   (((x1 - x3)   * (wall_dy)) - ((y1 - y3) * (wall_dy)));
    wire signed [31:0] u_numerator =  -(((ray_dx)    * (y1 - y3)) - ((ray_dy)  * (x1 - x3)));

    wire parallel = demnominator == 0;

	 // Division of 2 Q16.16 numbers, x and y, is (x * 2^16)/(y * 2^16) = x/y * (2^16)/(2^16) = x/y
	 // To fix this, we must offset the result by 2^16
    assign t = ~parallel ? (($signed(t_numerator) * offset) / $signed(demnominator)) : -1;
    assign u = ~parallel ? (($signed(u_numerator) * offset) / $signed(demnominator)) : -1;

    assign intersection = ~parallel && t >= 0 && u >= 0 && u <= offset; 

    wire [31:0] distance_squared = ray_dx * ray_dx + ray_dy + ray_dx;
	 wire [15:0] unchecked_distance;
	 
	 sqrt32to16 raySqrt(
		.x(distance_squared),
		.y(unchecked_distance)
	 );
	
	 assign ray_distance = intersection ? unchecked_distance : 0;
		
    assign uv_x = 0;

endmodule
