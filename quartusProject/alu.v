// ALU with complete flag handling and all baseline operations
module alu (
    input wire [15:0] a,          // First operand (Rdest)
    input wire [15:0] b,          // Second operand (Rsrc or Imm)
    input wire [3:0] op,          // Operation code
    input wire immediate_mode,     // 1 if operand b is immediate
    input wire carry_in,          // Carry input for ADDC/SUBC
    input wire update_flags,      // Control whether flags should be updated
    output reg [15:0] result,     // Result
    output reg carry,             // Carry flag (C)
    output reg low,               // Low flag (L)
    output reg flag,              // Overflow flag (F)
    output reg zero,              // Zero flag (Z)
    output reg negative           // Negative flag (N)
);

    // Operation codes (from ISA document)
    localparam ADD  = 4'b0101;  // Add with flags
    localparam SUB  = 4'b1001;  // Subtract with flags
    localparam AND  = 4'b0001;  // Logical AND
    localparam OR   = 4'b0010;  // Logical OR
    localparam XOR  = 4'b0011;  // Logical XOR
    localparam CMP  = 4'b1011;  // Compare
    localparam LSH  = 4'b0100;  // Logical Shift
    localparam MOV  = 4'b1101;  // Move
    localparam LUI  = 4'b1111;  // Load Upper Immediate

    // Internal signals
    reg [16:0] temp;            // For carry detection
    wire [15:0] sign_extended_b = immediate_mode ? {{8{b[7]}}, b[7:0]} : b;
    wire [15:0] zero_extended_b = immediate_mode ? {8'b0, b[7:0]} : b;
    wire [15:0] extended_b;     // Will hold either sign or zero extended value
    
    // Choose between sign and zero extension based on operation
    assign extended_b = (op == ADD || op == SUB || op == CMP) ? 
                       sign_extended_b : zero_extended_b;

    // Overflow detection for signed arithmetic
    wire signed [15:0] signed_a = a;
    wire signed [15:0] signed_b = extended_b;
    wire overflow_detect = (a[15] == extended_b[15]) && (result[15] != a[15]);

    always @(*) begin
        // Default values
        {carry, low, flag, zero, negative} = 5'b00000;
        result = 16'b0;

        case (op)
            ADD: begin
                temp = {1'b0, a} + {1'b0, extended_b};
                result = temp[15:0];
                if (update_flags) begin
                    carry = temp[16];  // Unsigned overflow
                    flag = overflow_detect;  // Signed overflow
                    zero = (result == 16'b0);
                end
            end

            SUB: begin
                temp = {1'b0, a} - {1'b0, extended_b};
                result = temp[15:0];
                if (update_flags) begin
                    carry = temp[16];  // Borrow
                    flag = ~overflow_detect;
                    zero = (result == 16'b0);
                end
            end

            AND: begin
                result = a & extended_b;
                if (update_flags) begin
                    zero = (result == 16'b0);
                end
            end

            OR: begin
                result = a | extended_b;
                if (update_flags) begin
                    zero = (result == 16'b0);
                end
            end

            XOR: begin
                result = a ^ extended_b;
                if (update_flags) begin
                    zero = (result == 16'b0);
                end
            end

            CMP: begin
                temp = {1'b0, a} - {1'b0, extended_b};
                result = temp[15:0];  // Result not written back
                if (update_flags) begin
                    zero = (a == extended_b);
                    low = (a < extended_b);  // Unsigned comparison
                    negative = ($signed(a) < $signed(extended_b));  // Signed comparison
                end
            end

            LSH: begin
                // b[15] or immediate MSB determines direction
                // For baseline, only support ±1
                if (extended_b[15]) begin  // Right shift
                    result = {1'b0, a[15:1]};
                end else begin    // Left shift
                    result = {a[14:0], 1'b0};
                end
                if (update_flags) begin
                    zero = (result == 16'b0);
                end
            end

            MOV: begin
                result = extended_b;
                if (update_flags) begin
                    zero = (result == 16'b0);
                end
            end

            LUI: begin
                result = {b[7:0], 8'b0};  // Load immediate into upper byte
                if (update_flags) begin
                    zero = (result == 16'b0);
                end
            end

            default: begin
                result = 16'b0;
                zero = 1'b1;
            end
        endcase
    end

endmodule