module tb_alu;
    
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

    // Inputs
    reg [15:0] a;              // First operand (Rdest)
    reg [15:0] b;              // Second operand (Rsrc or Imm)
    reg [3:0] op;              // Operation code
    reg immediate_mode;        // Immediate mode flag
    reg carry_in;              // Carry input for ADDC/SUBC
    reg update_flags;          // Control whether flags should be updated

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
        .op(op), 
        .immediate_mode(immediate_mode), 
        .carry_in(carry_in), 
        .update_flags(update_flags), 
        .result(result), 
        .carry(carry), 
        .low(low), 
        .flag(flag), 
        .zero(zero), 
        .negative(negative)
    );

	initial begin
		immediate_mode = 0;
		carry_in = 0;
		update_flags = 0;
		$display("BeginALU test");
		// And test
		op = AND;

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
		op = OR;

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
		op = XOR;

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
		op = ADD;

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
		
		$display("Addition tests done");

		// subtratct tests
		a = 0;
		b = 0;
		op = SUB;

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
		
		$display("Subtract tests done");

		// Shift tests
		a = 16'b0000_0000_0000_0000; // 0
		b = 16'b0000_0000_0000_0001; // Shift by 1
		op = LSH;                   // Left Shift

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
		op = LSH;                   // Right Shift by 1

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

		// Test Flags

		update_flags = 1;

		op = ADD;

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

		op = SUB;

		a = 65535;
		b = 65535;
		#1 if (carry) $display("Carry error ", a, " - ", b, ", expected: ",  0, ", got: ", carry);

		a = 1;
		b = 2;

		#1 if (!carry) $display("Carry error ", a, " - ", b, ", expected: ",  1, ", got: ", carry);

		op = CMP;
		//low
		a = 1;
		b = 0;
		#1 if (low) $display("Low error ", a, " - ", b, ", expected: ",  0, ", got: ", low);

		a = 0;
		b = 1;
		#1 if (!low) $display("Low error ", a, " - ", b, ", expected: ",  1, ", got: ", low);

		op = ADD;


		//flag / signed overflow
		a = $signed(5);
		b = $signed(10);
		#1 if (flag) $display("Flag error ", a, " + ", b, ", expected: ",  0, ", got: ", flag);

		a = $signed(-8);
		b = $signed(-20);
		#1 if (flag) $display("Flag error ", a, " + ", b, ", expected: ",  0, ", got: ", flag);

		a = $signed(32765);
		b = $signed(100);
		#1 if (!flag) $display("Flag error ", a, " + ", b, ", expected: ",  1, ", got: ", flag);

		a = $signed(-32765);
		b = $signed(-100);
		#1 if (!flag) $display("Flag error ", a, " + ", b, ", expected: ",  1, ", got: ", flag);

		op = SUB;

		a = $signed(-32765);
		b = $signed(100);

		#1 if (!flag) $display("Flag error ", a, " + ", b, ", expected: ",  1, ", got: ", flag);

		op = ADD;

		//zero
		a = $signed(-5);
		b = $signed(5);
		#1 if (!zero) $display("zero error ", a, " + ", b, ", expected: ",  1, ", got: ", zero);

		a = $signed(5);
		b = $signed(5);
		#1 if (zero) $display("zero error ", a, " + ", b, ", expected: ",  0, ", got: ", zero);
		
		op = AND;
		a = $signed(255);
		b = $signed(255);
		#1 if (zero) $display("zero error ", a, " & ", b, ", expected: ",  0, ", got: ", zero);

		a = $signed(1);
		b = $signed(2);
		#1 if (!zero) $display("zero error ", a, " & ", b, ", expected: ",  1, ", got: ", zero);
		op = ADD;

		//negative

		op = CMP;
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


		#5 $display("All tests finished.");

	end

endmodule
