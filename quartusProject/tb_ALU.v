module tb_alu;
    
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

    // Inputs
    reg [15:0] a;              // First operand (Rdest)
    reg [15:0] b;              // Second operand (Rsrc or Imm)
    reg [3:0] op_code;         // Operation code
	reg [3:0] ext_code;        // Extended op code
    reg immediate_mode;        // Immediate mode flag
    reg carry_in;              // Carry input for ADDC/SUBC

    // Outputs
    wire [15:0] result;        // Result
    wire carry;                // Carry flag
    wire low;                  // Low flag (L)
    wire flag;                 // Overflow flag (F)
    wire zero;                 // Zero flag (Z)
    wire negative;             // Negative flag (N)

    // Instantiate the ALU module
    alu uut (
        .a(a), 
        .b(b), 
        .op_code(op_code),
		.ext_code(ext_code),
        .immediate_mode(immediate_mode), 
        .carry_in(carry_in), 
        .result(result), 
        .carry(carry),
        .low(low), 
        .flag(flag), 
        .zero(zero), 
        .negative(negative)
    );

	initial begin
		op_code = 0;
		immediate_mode = 0;
		carry_in = 0;
		
		$display("BeginALU test");
		// And test
		ext_code = AND_REG;

		a = 65535;
		b = 65535;
		#1 if (result != (a & b)) $display("And error ", a, " & ", b, ", expected: ",  a & b, ", got: ", result);

		a = 65535;
		b = 0;
		#1 if (result != (a & b)) $display("And error ", a, " & ", b, ", expected: ",  a & b, ", got: ", result);

		a = 0;
		b = 65535;
		#1 if (result != (a & b)) $display("And error ", a, " & ", b, ", expected: ",  a & b, ", got: ", result);

		for(a = 0; a < 65490; a = a + 19) begin
			for(b = 0; b < 65490; b = b + 37) begin
				#1 if (result != (a & b)) $display("And error ", a, " & ", b, ", expected: ",  a & b, ", got: ", result);
			end
		end

		$display("And tests done");

		// OR test
		ext_code = OR_REG;

		a = 65535;
		b = 65535;
		#1 if (result != (a | b)) $display("Or error ", a, " | ", b, ", expected: ",  a | b, ", got: ", result);

		a = 65535;
		b = 0;
		#1 if (result != (a | b)) $display("Or error ", a, " | ", b, ", expected: ",  a | b, ", got: ", result);

		a = 0;
		b = 65535;
		#1 if (result != (a | b)) $display("Or error ", a, " | ", b, ", expected: ",  a | b, ", got: ", result);

		for(a = 0; a < 65490; a = a + 19) begin
			for(b = 0; b < 65490; b = b + 37) begin
				#1 if (result != (a | b)) $display("Or error ", a, " | ", b, ", expected: ",  a | b, ", got: ", result);
			end
		end

		$display("Or tests done");

		// XOR test
		ext_code = XOR_REG;

		a = 65535;
		b = 65535;
		#1 if (result != (a ^ b)) $display("Xor error ", a, " ^ ", b, ", expected: ",  a ^ b, ", got: ", result);

		a = 65535;
		b = 0;
		#1 if (result != (a ^ b)) $display("Xor error ", a, " ^ ", b, ", expected: ",  a ^ b, ", got: ", result);

		a = 0;
		b = 65535;
		#1 if (result != (a ^ b)) $display("Xor error ", a, " ^ ", b, ", expected: ",  a ^ b, ", got: ", result);

		for(a = 0; a < 65490; a = a + 19) begin
			for(b = 0; b < 65490; b = b + 37) begin
				#1 if (result != (a ^ b)) $display("Xor error ", a, " ^ ", b, ", expected: ",  a ^ b, ", got: ", result);
			end
		end

		$display("Xor tests done");

		// addition tests
		a = 0;
		b = 0;
		ext_code = ADD_REG;

		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
		
		a = 65535;
		b = 65535;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);

		a = 65535;
		b = 1;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
		
		a = 1;
		b = 65535;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);

		for(a = 0; a < 65490; a = a + 19) begin
			for(b = 0; b < 65490; b = b + 37) begin
				#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
			end
		end

		ext_code = ADDU_REG;

		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
		
		a = 65535;
		b = 65535;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);

		a = 65535;
		b = 1;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
		
		a = 1;
		b = 65535;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);

		//ADDC_REG
		ext_code = ADDC_REG;

		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
		
		a = 65535;
		b = 65535;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);

		a = 65530;
		b = 1;
		carry_in = 1;
		#1 if (result != (a + b + 1)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b + 1, ", got: ", result);
		a = 1;
		b = 65535;
		carry_in = 0;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);


		
		$display("Addition tests done");

		// subtratct tests
		a = 0;
		b = 0;
		ext_code = SUB_REG;

		#1 if (result != (a - b)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b, ", got: ", result);
		
		a = 65535;
		b = 65535;
		#1 if (result != (a - b)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b, ", got: ", result);

		a = 65535;
		b = 1;
		#1 if (result != (a - b)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b, ", got: ", result);
		
		a = 1;
		b = 65535;
		#1 if (result != (a - b)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b, ", got: ", result);

		for(a = 0; a < 65490; a = a + 19) begin
			for(b = 0; b < 65490; b = b + 37) begin
				#1 if (result != (a - b)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b, ", got: ", result);
			end
		end

		ext_code = SUBC_REG;

		#1 if (result != (a - b)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b, ", got: ", result);
		
		a = 65535;
		b = 65535;
		#1 if (result != (a - b)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b, ", got: ", result);

		b = 1;
		a = 65535;
		carry_in = 1;
		#1 if (result != (a - b - 1)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b - 1, ", got: ", result);
		
		a = 1;
		b = 65535;
		carry_in = 0;
		#1 if (result != (a - b)) $display("Subtract error ", a, " - ", b, ", expected: ",  a - b, ", got: ", result);

		
		$display("Subtract tests done");

				// Shift tests
		a = 16'b0000_0000_0000_0000; // 0
		b = 16'b0000_0000_0000_0001; // Shift by 1
		ext_code = LSH_REG;                   // Left Shift

		#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

		a = 16'b1111_1111_1111_1111; // -1 (all bits set)
		b = 16'b0000_0000_0000_0001; // Left Shift by 1
		#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

		a = 16'b0111_1111_1111_1111; // Max positive value
		b = 16'b0000_0000_0000_0001; // Left Shift by 1
		#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

		a = 16'b1000_0000_0000_0000; // Min negative value
		b = 16'b0000_0000_0000_0000; // Left Shift 1
		#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

		// Testing Right Shift
		a = 16'b0000_0000_0000_0000; // 0
		b = 16'b1000_0000_0000_0000; // Shift by -1 (MSB for right shift)

		#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);

		a = 16'b1111_1111_1111_1111; // -1 (all bits set)
		b = 16'b1000_0000_0000_0000; // Shift by -1 (MSB for right shift)
		#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);

		a = 16'b0000_0000_0000_0001; // Small positive value
		b = 16'b1000_0000_0000_0000; // Shift by -1 (MSB for right shift)
		#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);

		a = 16'b1000_0000_0000_0000; // Min negative value
		b = 16'b1000_0000_0000_0000; // Shift by -1 (MSB for right shift)
		#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);

		// Additional cases with loops to test shifts across a range
		for (a = 0; a < 16'hFFFF; a = a + 1) begin
			
			// Left shift
			b = 16'b0000_0000_0000_0000; 
			#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

			// Right shift
			b = 16'b1000_0000_0000_0000; 
			#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);
		
		end
		
		$display("Shift tests done");
		$display("Second time around but with immediate mode");
		immediate_mode = 1;
		op_code = ANDI;

		a = 65535;
		b = 255;
		#1 if (result != (a & b)) $display("And error ", a, " & ", b, ", expected: ",  a & b, ", got: ", result);

		a = 65535;
		b = 0;
		#1 if (result != (a & b)) $display("And error ", a, " & ", b, ", expected: ",  a & b, ", got: ", result);

		a = 0;
		b = 255;
		#1 if (result != (a & b)) $display("And error ", a, " & ", b, ", expected: ",  a & b, ", got: ", result);

		for(a = 0; a < 65490; a = a + 19) begin
			for(b = 0; b < 255; b = b + 37) begin
				#1 if (result != (a & b)) $display("And error ", a, " & ", b, ", expected: ",  a & b, ", got: ", result);
			end
		end

		$display("And tests done");

		// OR test
		op_code = ORI;

		a = 65535;
		b = 255;
		#1 if (result != (a | b)) $display("Or error ", a, " | ", b, ", expected: ",  a | b, ", got: ", result);

		a = 65535;
		b = 0;
		#1 if (result != (a | b)) $display("Or error ", a, " | ", b, ", expected: ",  a | b, ", got: ", result);

		a = 0;
		b = 255;
		#1 if (result != (a | b)) $display("Or error ", a, " | ", b, ", expected: ",  a | b, ", got: ", result);

		for(a = 0; a < 65490/3; a = a + 19) begin
			for(b = 0; b < 255; b = b + 37) begin
				#1 if (result != (a | b)) $display("Or error ", a, " | ", b, ", expected: ",  a | b, ", got: ", result);
			end
		end

		$display("ORI tests done");

		// XOR test
		op_code = XORI;

		a = 65535;
		b = 255;
		#1 if (result != (a ^ b)) $display("Xor error ", a, " ^ ", b, ", expected: ",  a ^ b, ", got: ", result);

		a = 65535;
		b = 0;
		#1 if (result != (a ^ b)) $display("Xor error ", a, " ^ ", b, ", expected: ",  a ^ b, ", got: ", result);

		a = 0;
		b = 255;
		#1 if (result != (a ^ b)) $display("Xor error ", a, " ^ ", b, ", expected: ",  a ^ b, ", got: ", result);

		for(a = 0; a < 65490; a = a + 19) begin
			for(b = 0; b < 255; b = b + 37) begin
				#1 if (result != (a ^ b)) $display("Xor error ", a, " ^ ", b, ", expected: ",  a ^ b, ", got: ", result);
			end
		end

		$display("XORI tests done");

		// addition tests
		a = 0;
		b = 0;
		op_code = ADDI;

		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
		
		a = 65535;
		b = 127;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);

		a = 65535;
		b = 1;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
		
		a = 1;
		b = 127;
		#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);

		for(a = 0; a < 65490; a = a + 19) begin
			for(b = 0; b < 127; b = b + 37) begin
				#1 if (result != (a + b)) $display("Addition error ", a, " + ", b, ", expected: ",  a + b, ", got: ", result);
			end
		end
		$display("ADDI tests done");
						// Shift tests
		a = 16'b0000_0000_0000_0000; // 0
		b = 16'b0000_0001; // Shift by 1
		op_code = LSHI;                   // Left Shift

		#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

		a = 16'b1111_1111_1111_1111; // -1 (all bits set)
		b = 16'b0000_0001; // Left Shift by 1
		#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

		a = 16'b0111_1111_1111_1111; // Max positive value
		b = 16'b0000_0001; // Left Shift by 1
		#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

		a = 16'b1000_0000_0000_0000; // Min negative value
		b = 16'b0000_0000; // Left Shift 1
		#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

		// Testing Right Shift
		a = 16'b0000_0000_0000_0000; // 0
		b = 16'b1000_0000; // Shift by -1 (MSB for right shift)

		#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);

		a = 16'b1111_1111_1111_1111; // -1 (all bits set)
		b = 16'b1000_0000; // Shift by -1 (MSB for right shift)
		#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);

		a = 16'b0000_0000_0000_0001; // Small positive value
		b = 16'b1000_0000; // Shift by -1 (MSB for right shift)
		#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);

		a = 16'b1000_0000_0000_0000; // Min negative value
		b = 16'b1000_0000; // Shift by -1 (MSB for right shift)
		#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);

		// Additional cases with loops to test shifts across a range
		for (a = 0; a < 16'hFFFF; a = a + 1) begin
			
			// Left shift
			b = 16'b0000_0000; 
			#1 if (result != (a << 1)) $display("Left Shift error: ", a, " << ", 1, ", expected: ", a << 1, ", got: ", result);

			// Right shift
			b = 16'b1000_0000; 
			#1 if (result != (a >> 1)) $display("Right Shift error: ", a, " >> ", 1, ", expected: ", a >> 1, ", got: ", result);
		
		end
		// Test Flags
		$display("LSHI tests done");
		op_code = REG_OP;
		ext_code = ADD_REG;

		//carry
		a = 2;
		b = 3;
		#1 if (carry) $display("Carry error ", a, " + ", b, ", expected: ",  0, ", got: ", carry);

		a = 65535;
		b = 65535;
		#1 if (!carry) $display("Carry error ", a, " + ", b, ", expected: ",  1, ", got: ", carry);

		a = 60000;
		b = 34567;
		#1 if (!carry) $display("Carry error ", a, " + ", b, ", expected: ",  1, ", got: ", carry);

		ext_code = SUB_REG;

		a = 65535;
		b = 65535;
		#1 if (carry) $display("Carry error ", a, " - ", b, ", expected: ",  0, ", got: ", carry);

		a = 1;
		b = 2;

		#1 if (!carry) $display("Carry error ", a, " - ", b, ", expected: ",  1, ", got: ", carry);

		ext_code = CMP_REG;
		//low
		a = 1;
		b = 0;
		#1 if (low) $display("Low error ", a, " - ", b, ", expected: ",  0, ", got: ", low);

		a = 0;
		b = 1;
		#1 if (!low) $display("Low error ", a, " - ", b, ", expected: ",  1, ", got: ", low);
		
		ext_code = ADD_REG;


		//flag / signed overflow
		a = $signed(5);
		b = $signed(10);
		#1 if (flag) $display("Flag error ", a, " + ", b, ", expected: ",  0, ", got: ", flag);

		a = $signed(-8);
		b = $signed(-20);
		#1 if (flag) $display("Flag error ", a, " + ", b, ", expected: ",  0, ", got: ", flag);

		a = $signed(32767);
		b = $signed(100);
		#1 if (!flag) $display("Flag error ", a, " + ", b, ", expected: ",  1, ", got: ", flag);

		a = $signed(-32765);
		b = $signed(-100);
		#1 if (!flag) $display("Flag error ", a, " + ", b, ", expected: ",  1, ", got: ", flag);

		ext_code = SUB_REG;

		a = $signed(-32765);
		b = $signed(100);

		#1 if (!flag) $display("Flag error ", a, " + ", b, ", expected: ",  1, ", got: ", flag);

		ext_code = ADD_REG;

		//zero
		a = $signed(-5);
		b = $signed(5);
		#1 if (!zero) $display("zero error ", a, " + ", b, ", expected: ",  1, ", got: ", zero);

		a = $signed(5);
		b = $signed(5);
		#1 if (zero) $display("zero error ", a, " + ", b, ", expected: ",  0, ", got: ", zero);
		
		ext_code = AND_REG;
		a = $signed(255);
		b = $signed(255);
		#1 if (zero) $display("zero error ", a, " & ", b, ", expected: ",  0, ", got: ", zero);

		a = $signed(1);
		b = $signed(2);
		#1 if (!zero) $display("zero error ", a, " & ", b, ", expected: ",  1, ", got: ", zero);
		ext_code = ADD_REG;

		//negative

		ext_code = CMP_REG;
		a = $signed(1);
		b = $signed(0);
		#1 if (negative) $display("negative error ", a, " - ", b, ", expected: ",  0, ", got: ", negative);

		a = $signed(0);
		b = $signed(1);
		#1 if (!negative) $display("negative error ", a, " - ", b, ", expected: ",  1, ", got: ", negative);

		a = $signed(5);
		b = $signed(-5);
		#1 if (negative) $display("negative error ", a, " - ", b, ", expected: ",  0, ", got: ", negative);

		a = $signed(-100);
		b = $signed(-50);
		#1 if (!negative) $display("negative error ", a, " - ", b, ", expected: ",  1, ", got: ", negative);


		$display("Flags tests done");

		// Immediate mode
		#5 $display("All tests finished.");

	end

endmodule
