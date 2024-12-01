module sin_cos(
    input signed [15:0] angle,   // Q8.8 input angle
    output signed [15:0] sine,  // Q8.8 sine output
    output signed [15:0] cosine // Q8.8 cosine output
);

    // Quarter-wave symmetry LUT for sine (512 entries)
    reg signed [15:0] sin_lut [511:0];

    initial begin
        // Include generated lookup table values here
        $readmemh("/home/casey/Documents/School/ECE3710/3710-CPU/quartusProject/data_files/sin_lut.hex", sin_lut);
    end
    wire [10:0] norm_angle = angle[10:0];
    wire [8:0] lut_index = angle[8:0];
    // Quadrant identification
    wire [1:0] quadrant = norm_angle[10:9];

    // Determine sine and cosine based on quadrant
    assign sine = (quadrant == 2'b00) ? sin_lut[lut_index] :
                  (quadrant == 2'b01) ? sin_lut[511 - lut_index] :
                  (quadrant == 2'b10) ? -sin_lut[lut_index] :
                                        -sin_lut[511 - lut_index];

    assign cosine = (quadrant == 2'b00) ? sin_lut[511 - lut_index] :
                    (quadrant == 2'b01) ? -sin_lut[lut_index] :
                    (quadrant == 2'b10) ? -sin_lut[511 - lut_index] :
                                          sin_lut[lut_index];
endmodule