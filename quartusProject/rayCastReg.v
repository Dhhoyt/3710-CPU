/*******************************************************************************
* Ray Casting Register Controller
*
* This module manages the sequential loading and storage of ray casting parameters,
* coordinating the intersection tests between rays and walls. It acts as a register
* file and controller for the rayCast computation module.
*
* Operation:
* 1. Sequentially loads ray and wall coordinates through dual input ports
* 2. Coordinates are loaded based on control signals and enables
* 3. Triggers ray casting computation once parameters are loaded
* 4. Stores and formats computation results for the graphics pipeline
*
* Key Features:
* - Dual input ports (A/B) for efficient coordinate loading
* - Fixed-point Q8.8 format for positions and directions  
* - Control signals for managing different parameter types
* - Automated result handling for failed intersection tests
*******************************************************************************/

module rayCastReg (
   input wire clk,
   input wire a_en, b_en,         // Control enables for input ports A and B
   input wire [15:0] a,           // X coordinate inputs (Q8.8)
   input wire [15:0] b,           // Y coordinate inputs (Q8.8)
   input wire [2:0] control_a,    // Parameter type selector for port A
   input wire [2:0] control_b,    // Parameter type selector for port B 
   output reg [15:0] ray_distance, // Distance to intersection for wall scaling
   output reg [15:0] uv_x         // Texture coordinate for wall rendering
);
   // Storage registers for ray casting parameters, all in Q8.8 fixed-point
   reg signed [15:0] player_x;     // Player/camera X position 
   reg signed [15:0] player_y;     // Player/camera Y position
   reg signed [15:0] ray_dx;       // Ray direction vector X component
   reg signed [15:0] ray_dy;       // Ray direction vector Y component  
   reg signed [15:0] wall_x1;      // Current wall segment start X
   reg signed [15:0] wall_y1;      // Current wall segment start Y
   reg signed [15:0] wall_x2;      // Current wall segment end X
   reg signed [15:0] wall_y2;      // Current wall segment end Y
   
   // Parameter loading control codes - correspond to assembly instructions
   localparam [2:0]
       CTRL_PLAYER_POS = 3'b000,  // LODP - Load player position
       CTRL_RAY_DIR    = 3'b001,  // LODR - Load ray direction
       CTRL_WALL_START = 3'b010,  // Load wall start point
       CTRL_WALL_END   = 3'b011,  // Load wall end point  
       CTRL_WALL_PTR   = 3'b100;  // LODW - Load wall from memory
       
   // Interface signals with ray casting computation module
   wire intersection_found;        // Valid intersection detected flag
   wire [15:0] computed_distance; // Raw intersection distance result
   wire [7:0] computed_uv;       // Raw texture coordinate result
   wire [31:0] t_param, u_param; // Intersection parameters for validation

   // Ray casting computation instance
   rayCast ray_compute (
       .x1(player_x),    // Ray origin X
       .y1(player_y),    // Ray origin Y
       .x2(ray_dx),      // Ray direction X 
       .y2(ray_dy),      // Ray direction Y
       .x3(wall_x1),     // Wall start X
       .y3(wall_y1),     // Wall start Y
       .x4(wall_x2),     // Wall end X
       .y4(wall_y2),     // Wall end Y
       .intersection(intersection_found),
       .ray_distance(computed_distance),
       .t(t_param),
       .u(u_param),
       .uv_x(computed_uv)
   );

   // X coordinate loading logic
   always @(posedge clk) begin
       if (a_en) begin
           case (control_a)
               CTRL_PLAYER_POS: player_x <= a;  // Load player X position
               CTRL_RAY_DIR:    ray_dx <= a;    // Load ray direction X
               CTRL_WALL_START: wall_x1 <= a;   // Load wall start X
               CTRL_WALL_END:   wall_x2 <= a;   // Load wall end X
           endcase
       end
   end

   // Y coordinate loading logic  
   always @(posedge clk) begin
       if (b_en) begin
           case (control_b)
               CTRL_PLAYER_POS: player_y <= b;  // Load player Y position
               CTRL_RAY_DIR:    ray_dy <= b;    // Load ray direction Y
               CTRL_WALL_START: wall_y1 <= b;   // Load wall start Y
               CTRL_WALL_END:   wall_y2 <= b;   // Load wall end Y
           endcase
       end
   end

   // Result processing and output formatting
   always @(posedge clk) begin
       if (intersection_found) begin
           ray_distance <= computed_distance;          // Store valid distance
           uv_x <= {8'b0, computed_uv};              // Format texture coordinate
       end else begin
           ray_distance <= 16'hFFFF;                  // Max distance if no hit
           uv_x <= 16'h0000;                         // No texture if no hit
       end
   end
endmodule
