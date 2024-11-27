module rayCastReg (
    input wire clk,
    input wire a_en, b_en,         // Enable signals
    input wire [15:0] a,           // Input value A
    input wire [15:0] b,           // Input value B
    input wire [2:0] control_a,    // Control for input A
    input wire [2:0] control_b,    // Control for input B
    output reg [15:0] ray_distance, // Distance for distance buffer
    output reg [15:0] uv_x         // UV coordinate for texture mapping
);

    // Register storage for raycast computation
    reg signed [15:0] player_x;     // Player position X (Q8.8)
    reg signed [15:0] player_y;     // Player position Y (Q8.8)
    reg signed [15:0] ray_dx;       // Ray direction X (Q8.8)
    reg signed [15:0] ray_dy;       // Ray direction Y (Q8.8)
    reg signed [15:0] wall_x1;      // Wall start X (Q8.8)
    reg signed [15:0] wall_y1;      // Wall start Y (Q8.8)
    reg signed [15:0] wall_x2;      // Wall end X (Q8.8)
    reg signed [15:0] wall_y2;      // Wall end Y (Q8.8)
    
    // Control signal definitions
    localparam [2:0]
        CTRL_PLAYER_POS = 3'b000,  // Load player position (LODP)
        CTRL_RAY_DIR    = 3'b001,  // Load ray direction (LODR)
        CTRL_WALL_START = 3'b010,  // Load wall start
        CTRL_WALL_END   = 3'b011,  // Load wall end
        CTRL_WALL_PTR   = 3'b100;  // Load wall pointer (LODW)
        
    // Ray intersection computation
    wire intersection_found;
    wire [15:0] computed_distance;
    wire [7:0] computed_uv;
    wire [31:0] t_param, u_param;

    // Instantiate ray cast module
    rayCast ray_compute (
        .x1(player_x),
        .y1(player_y), 
        .x2(ray_dx),
        .y2(ray_dy),
        .x3(wall_x1),
        .y3(wall_y1),
        .x4(wall_x2),
        .y4(wall_y2),
        .intersection(intersection_found),
        .ray_distance(computed_distance),
        .t(t_param),
        .u(u_param),
        .uv_x(computed_uv)
    );

    // Handle input port A
    always @(posedge clk) begin
        if (a_en) begin
            case (control_a)
                CTRL_PLAYER_POS: player_x <= a;
                CTRL_RAY_DIR:    ray_dx <= a; 
                CTRL_WALL_START: wall_x1 <= a;
                CTRL_WALL_END:   wall_x2 <= a;
            endcase
        end
    end

    // Handle input port B
    always @(posedge clk) begin
        if (b_en) begin
            case (control_b)
                CTRL_PLAYER_POS: player_y <= b;
                CTRL_RAY_DIR:    ray_dy <= b;
                CTRL_WALL_START: wall_y1 <= b;
                CTRL_WALL_END:   wall_y2 <= b;
            endcase
        end
    end

    // Update outputs on successful intersection
    always @(posedge clk) begin
        if (intersection_found) begin
            ray_distance <= computed_distance;
            uv_x <= {8'b0, computed_uv}; // Zero extend UV 
        end else begin
            ray_distance <= 16'hFFFF; // Max distance if no intersection
            uv_x <= 16'h0000;
        end
    end

endmodule
