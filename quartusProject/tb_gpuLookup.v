module tb_gpuLookup;

    // Parameters
    parameter TEXTURE_SIZE = 64;
    parameter SCREEN_HEIGHT = 16'b1111000000000000; // Q8.8 format

    // Inputs
    reg [15:0] distance;
    reg [9:0] screen_y;

    // Outputs
    wire [$clog2(TEXTURE_SIZE)-1:0] uv_y;
    wire inside_wall;
    wire above_wall;

    // Instantiate the module under test
    gpuLookup #(
        .TEXTURE_SIZE(TEXTURE_SIZE),
        .SCREEN_HEIGHT(SCREEN_HEIGHT)
    ) uut (
        .distance(distance),
        .screen_y(screen_y),
        .uv_y(uv_y),
        .inside_wall(inside_wall),
        .above_wall(above_wall)
    );

    // Testbench logic
    initial begin
        // Initialize inputs
        distance = 16'h0080; // Fixed distance
        screen_y = 0;        // Start from 0

        // Loop to increment screen_y
        repeat (1024) begin // Loop for the range of a 10-bit screen_y
            #10; // Simulate a small delay between iterations
            screen_y = screen_y + 1;
        end

        // Finish simulation
        #10;
        $finish;
    end

endmodule