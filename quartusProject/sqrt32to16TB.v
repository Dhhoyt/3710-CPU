// Run this file then direct the output to "output.txt", then run the python file to check outputs

module tb_sqrt32to16;

    // Declare testbench signals
    reg [31:0] x;
    wire [15:0] res;

    // Instantiate the sqrt32to16 module
    sqrt32to16 uut (
        .x(x),
        .res(res)
    );

    // Testbench initial block
    initial begin
        // Loop to increment x by 283
        for (integer i = 0; i < 32'hFFFFFFFF - 3293; i = i + 3293) begin
            x = i; // Set x to the current value of i
            #10; // Wait for a short time for the output to stabilize
            // Output the values of x and res in hexadecimal format
            $display("%h\t%h", x, res);
        end

        $finish; // End the simulation
    end

endmodule