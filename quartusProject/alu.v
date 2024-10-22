// ALU Implementation
module alu (
    // Core inputs
    input wire [15:0] a,              // First operand (Rdest)
    input wire [15:0] b,              // Second operand (Rsrc or immediate)
    input wire [3:0] op_code,         // Primary op code (bits 15-12 of instruction)
    input wire [3:0] ext_code,        // Extended op code (bits 7-4 of instruction)
    input wire immediate_mode,         // 1 for immediate ops, 0 for register ops
    input wire carry_in,              // Previous carry flag for ADDC/SUBC
    input wire is_branch_op,          // 1 if doing branch address calculation
    input wire [15:0] pc,             // Program counter for branch calculation
    
    // Outputs
    output reg [15:0] result,         // ALU result
    output reg carry,                 // Carry flag (C)
    output reg low,                   // Low flag (L)
    output reg flag,                  // Flag (F)
    output reg zero,                  // Zero flag (Z)
    output reg negative               // Negative flag (N)
);

    // 1. Regular Register Operation
    // These use op_code=0000 and ext_code for operation
    localparam REG_OP        = 4'b0000;   // Regular operation identifier

    // Basic Arithmetic Operations
    localparam ADD_REG       = 4'b0101;   // Add registers
    localparam ADDU_REG      = 4'b0110;   // Add unsigned registers
    localparam ADDC_REG      = 4'b0111;   // Add with carry
    localparam SUB_REG       = 4'b1001;   // Subtract registers
    localparam SUBC_REG      = 4'b1010;   // Subtract with carry
    localparam CMP_REG       = 4'b1011;   // Compare registers

    // Basic Logic Operations
    localparam AND_REG       = 4'b0001;   // AND registers
    localparam OR_REG        = 4'b0010;   // OR registers
    localparam XOR_REG       = 4'b0011;   // XOR registers

    // 1-bit Shift Operation
    localparam LSH_REG       = 4'b0100;   // Logical shift register

    localparam MOV_REG       = 4'b1101;   // Move register

    // 2. Immediate Operations
    // These use op_code directly for operation

    // Basic Arithmetic Operations (Immediate)
    localparam ADDI          = 4'b0101;   // Add immediate
    localparam ADDUI         = 4'b0110;   // Add unsigned immediate
    localparam SUBI          = 4'b1001;   // Subtract immediate
    localparam CMPI          = 4'b1011;   // Compare immediate

    // Basic Logic Operations (Immediate)
    localparam ANDI          = 4'b0001;   // AND immediate
    localparam ORI           = 4'b0010;   // OR immediate
    localparam XORI          = 4'b0011;   // XOR immediate

    // 1-bit Shift Operation (Immediate)
    localparam LSHI          = 4'b1000;   // Logical shift immediate
    
    localparam LUI           = 4'b1111;   // Load upper immediate
    
    // 3. Branch Jump Operation
    // Branch calculations: PC + sign-extended displacement
    // Jump calculations: Direct register value
    localparam BRANCH_OP     = 4'b1100;   // Branch operation
    localparam JUMP_OP       = 4'b0100;   // Jump operation

    // Internal signals
    reg [16:0] temp;                  // For carry/borrow detection
    reg [15:0] operand_a;             // First operand after input selection
    reg [15:0] operand_b;             // Second operand after input selection
    
    // Immediate extension signals
    wire [15:0] sign_extended_imm = {{8{b[7]}}, b[7:0]};    // For arithmetic
    wire [15:0] zero_extended_imm = {8'b0, b[7:0]};         // For logical ops
    
    // Overflow detection
    wire overflow_detect = (operand_a[15] == operand_b[15]) && 
                          (result[15] != operand_a[15]);

    // Input operand selection based on operation type
    always @(*) begin
        // Default to regular ALU inputs
        operand_a = a;
        operand_b = b;

        if (is_branch_op) begin
            // For branch calculations:
            operand_a = pc;
            operand_b = sign_extended_imm;
        end
        else if (immediate_mode) begin
            // For immediate operations:
            case (op_code)
                ADDI, SUBI, CMPI: operand_b = sign_extended_imm;
                ANDI, ORI, XORI, LSHI: operand_b = zero_extended_imm;
                LUI:              operand_b = {b[7:0], 8'b0};
                default:          operand_b = b;
            endcase
        end
    end

    // Main ALU logic
    always @(*) begin
        // Default values
        {carry, low, flag, zero, negative} = 5'b00000;
        result = 16'b0;

        // Handle different operation types
        if (is_branch_op) begin
            // Branch address calculation: PC + displacement
            temp = {1'b0, operand_a} + {1'b0, operand_b};
            result = temp[15:0];
        end
        else if (op_code == REG_OP) begin
            // Regular register-to-register operations
            case (ext_code)
                // Basic Arithmetic Operations
                ADD_REG: begin
                    temp = {1'b0, operand_a} + {1'b0, operand_b};
                    result = temp[15:0];
                    carry = temp[16];
                    flag = overflow_detect;
                    zero = (result == 16'b0);
                end

                ADDU_REG: begin
                    result = operand_a + operand_b;
                    // No flags affected
                end

                ADDC_REG: begin
                    temp = {1'b0, operand_a} + {1'b0, operand_b} + {16'b0, carry_in};
                    result = temp[15:0];
                    carry = temp[16];
                    flag = overflow_detect;
                    zero = (result == 16'b0);
                end

                SUB_REG: begin
                    temp = {1'b0, operand_a} - {1'b0, operand_b};
                    result = temp[15:0];
                    carry = temp[16];
                    flag = overflow_detect;
                    zero = (result == 16'b0);
                end

                SUBC_REG: begin
                    temp = {1'b0, operand_a} - {1'b0, operand_b} - {16'b0, carry_in};
                    result = temp[15:0];
                    carry = temp[16];
                    flag = overflow_detect;
                    zero = (result == 16'b0);
                end

                CMP_REG: begin
                    temp = {1'b0, operand_a} - {1'b0, operand_b};
                    result = temp[15:0];  // Not written back
                    zero = (operand_a == operand_b);
                    low = (operand_a < operand_b);  // Unsigned
                    negative = ($signed(operand_a) < $signed(operand_b));  // Signed
                end

                // Basic Logic Operations
                AND_REG: begin
                    result = operand_a & operand_b;
                    zero = (result == 16'b0);
                end

                OR_REG: begin
                    result = operand_a | operand_b;
                    zero = (result == 16'b0);
                end

                XOR_REG: begin
                    result = operand_a ^ operand_b;
                    zero = (result == 16'b0);
                end

                // 1-bit Shift Operation
                LSH_REG: begin
                    // operand_b[15] determines direction
                    // For baseline, only ±1 shift amount is supported
                    if (operand_b[15]) begin  // Right shift (negative)
                        result = {1'b0, operand_a[15:1]};  // Shift right by 1
                    end else begin            // Left shift (positive)
                        result = {operand_a[14:0], 1'b0};  // Shift left by 1
                    end
                    zero = (result == 16'b0);
                end

                MOV_REG: begin
                    result = operand_b;
                    zero = (result == 16'b0);
                end
            endcase
        end
        else begin
            // Immediate operations
            case (op_code)
                // Basic Arithmetic Operations (Immediate)
                ADDI: begin
                    temp = {1'b0, operand_a} + {1'b0, operand_b};
                    result = temp[15:0];
                    carry = temp[16];
                    flag = overflow_detect;
                    zero = (result == 16'b0);
                end

                SUBI: begin
                    temp = {1'b0, operand_a} - {1'b0, operand_b};
                    result = temp[15:0];
                    carry = temp[16];
                    flag = overflow_detect;
                    zero = (result == 16'b0);
                end

                CMPI: begin
                    temp = {1'b0, operand_a} - {1'b0, operand_b};
                    result = temp[15:0];
                    zero = (operand_a == operand_b);
                    low = (operand_a < operand_b);
                    negative = ($signed(operand_a) < $signed(operand_b));
                end

                // Basic Logic Operations (Immediate)
                ANDI, ORI, XORI: begin
                    case (op_code)
                        ANDI: result = operand_a & operand_b;
                        ORI:  result = operand_a | operand_b;
                        XORI: result = operand_a ^ operand_b;
                    endcase
                    zero = (result == 16'b0);
                end

                // 1-bit Shift Operation (Immediate)
                LSHI: begin
                    // operand_b[7] determines direction for LSHI
                    // s = sign (0=left, 2s comp) from ISA doc
                    if (operand_b[7]) begin   // Right shift
                        result = {1'b0, operand_a[15:1]};
                    end else begin            // Left shift
                        result = {operand_a[14:0], 1'b0};
                    end
                    zero = (result == 16'b0);
                end

                LUI: begin
                    result = {operand_b[7:0], 8'b0};
                    zero = (result == 16'b0);
                end
            endcase
        end
    end

endmodule
