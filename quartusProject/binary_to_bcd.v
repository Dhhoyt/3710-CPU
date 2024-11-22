module binary_to_bcd (
    input      [15:0] binary,  // 16-bit binary input
    output reg [19:0] bcd      // 20-bit BCD output (4 digits: each 4 bits for 0-9)
);
    integer i; // Loop variable

    always @(*) begin
        // Initialize the BCD output to 0
        bcd = 20'b0;

        // Shift the binary input into the BCD output
        for (i = 15; i >= 0; i = i - 1) begin
            // Check each BCD digit and add 3 if it is 5 or greater
            if (bcd[3:0]   >= 5) bcd[3:0]   = bcd[3:0]   + 3;
            if (bcd[7:4]   >= 5) bcd[7:4]   = bcd[7:4]   + 3;
            if (bcd[11:8]  >= 5) bcd[11:8]  = bcd[11:8]  + 3;
            if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;

            // Shift the entire BCD register left by 1 bit
            bcd = {bcd[18:0], binary[i]};
        end
    end
endmodule