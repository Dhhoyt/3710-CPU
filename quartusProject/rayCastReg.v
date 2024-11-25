module rayCastReg (
    input wire clk,                // Clock input
    input wire a_en,              // Enable for register A input
    input wire b_en,              // Enable for register B input 
    input wire [15:0] a,          // Value input A
    input wire [15:0] b,          // Value input B
    input wire [2:0] control_a,   // Control for A registers
    input wire [2:0] control_b,   // Control for B registers
    output wire [15:0] ray_distance, // Distance to intersection (Q8.8)
    output wire [15:0] uv_x       // Texture X coordinate
);

    // Storage registers for player pos, ray, and wall coordinates
    reg signed [15:0] r1x;  // Start point X (player position)
    reg signed [15:0] r1y;  // Start point Y
    reg signed [15:0] r2x;  // Ray direction X (from sin/cos)
    reg signed [15:0] r2y;  // Ray direction Y  
    
    // Wall points are loaded per-test via control signals
    wire signed [15:0] w1x;  // Wall start X
    wire signed [15:0] w1y;  // Wall start Y
    wire signed [15:0] w2x;  // Wall end X
    wire signed [15:0] w2y;  // Wall end Y
    
    // Control signal definitions for register selection
    localparam [2:0]
        LOAD_R1X = 3'b000,  // Load player X
        LOAD_R1Y = 3'b001,  // Load player Y  
        LOAD_R2X = 3'b010,  // Load ray dir X
        LOAD_R2Y = 3'b011,  // Load ray dir Y
        LOAD_W1X = 3'b100,  // Load wall point 1 X
        LOAD_W1Y = 3'b101,  // Load wall point 1 Y
        LOAD_W2X = 3'b110,  // Load wall point 2 X
        LOAD_W2Y = 3'b111;  // Load wall point 2 Y

    // RayCast module interface signals
    wire intersection_valid;
    wire [31:0] t_param;
    wire [31:0] u_param;
    wire [7:0] texture_x;

    // Instantiate ray intersection calculator
    rayCast ray_calc (
        .x1(r1x),          // Ray start X (player pos)
        .y1(r1y),          // Ray start Y
        .x2(r2x),          // Ray direction X 
        .y2(r2y),          // Ray direction Y
        .x3(w1x),          // Wall start X
        .y3(w1y),          // Wall start Y 
        .x4(w2x),          // Wall end X
        .y4(w2y),          // Wall end Y
        .intersection(intersection_valid),
        .ray_distance(ray_distance),
        .t(t_param),
        .u(u_param),
        .uv_x(texture_x)
    );

    // Register updates on port A
    always @(posedge clk) begin
        if (a_en) begin
            case (control_a) 
                LOAD_R1X: r1x <= a;
                LOAD_R1Y: r1y <= a;
                LOAD_R2X: r2x <= a;
                LOAD_R2Y: r2y <= a;
                LOAD_W1X: w1x <= a;
                LOAD_W1Y: w1y <= a;
                LOAD_W2X: w2x <= a;
                LOAD_W2Y: w2y <= a;
            endcase
        end
    end

    // Register updates on port B
    always @(posedge clk) begin
        if (b_en) begin
            case (control_b)
                LOAD_R1X: r1x <= b;
                LOAD_R1Y: r1y <= b; 
                LOAD_R2X: r2x <= b;
                LOAD_R2Y: r2y <= b;
                LOAD_W1X: w1x <= b;
                LOAD_W1Y: w1y <= b;
                LOAD_W2X: w2x <= b;
                LOAD_W2Y: w2y <= b;
            endcase
        end
    end

    // Output UV coordinate (zero extended to 16 bits)
    assign uv_x = {8'b0, texture_x};

endmodule
