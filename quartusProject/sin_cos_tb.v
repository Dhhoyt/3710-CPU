module tb_sin_cos;

    // Inputs and outputs
    integer angle;   // Q8.8 input angle
    wire [15:0] sine;   // Q8.8 sine output
    wire [15:0] cosine; // Q8.8 cosine output

    // Instantiate the sin_cos module
    sin_cos uut (
        .angle(angle[15:0]),
        .sine(sine),
        .cosine(cosine)
    );

    // Test procedure
    initial begin
        // Iterate over all 2^16 possible angle values
        for (angle = 0; angle < 65536; angle = angle + 1) begin
            #1;  // Delay for one time unit to allow sine and cosine to settle
            // Display the current angle, sine, and cosine values
            $display("%h\t%h\t%h", angle[15:0], sine, cosine);
        end

        // End the simulation after all values are tested
        $finish;
    end

endmodule