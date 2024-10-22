
//testbench for an ALU

module tb_alu;

	parameter AND = 3'b000;
	parameter OR  = 3'b001;
	parameter XOR = 3'b010;
	parameter ADD = 3'b011;
	parameter SUB = 3'b100;
	parameter LSHIFT = 3'b101;
	parameter RSHIFT = 3'b110;

	reg [15:0] src1, src2;
	reg [2:0] controlCode;
	wire [15:0] result;
	
	wire carry, low, flag, zero, negative;


	alu DUT (controlCode, src1, src2, result, carry, low, flag, zero, negative);

	initial begin
		$display("BeginALU test");

		

		// And test
		controlCode = AND;

		src1 = 65535;
		src2 = 65535;
		#1 if (result != (src1 & src2)) $display("And error ", src1, " & ", src2, ", expected: ",  src1 & src2, ", got: ", result);

		src1 = 65535;
		src2 = 0;
		#1 if (result != (src1 & src2)) $display("And error ", src1, " & ", src2, ", expected: ",  src1 & src2, ", got: ", result);

		src1 = 0;
		src2 = 65535;
		#1 if (result != (src1 & src2)) $display("And error ", src1, " & ", src2, ", expected: ",  src1 & src2, ", got: ", result);

		for(src1 = 0; src1 < 65490; src1 = src1 + 19) begin
			for(src2 = 0; src2 < 65490; src2 = src2 + 37) begin
				#1 if (result != (src1 & src2)) $display("And error ", src1, " & ", src2, ", expected: ",  src1 & src2, ", got: ", result);
			end
		end

		$display("And tests done");


		// Or test
		controlCode = OR;

		src1 = 65535;
		src2 = 65535;
		#1 if (result != (src1 | src2)) $display("Or error ", src1, " | ", src2, ", expected: ",  src1 | src2, ", got: ", result);

		src1 = 65535;
		src2 = 0;
		#1 if (result != (src1 | src2)) $display("Or error ", src1, " | ", src2, ", expected: ",  src1 | src2, ", got: ", result);

		src1 = 0;
		src2 = 65535;
		#1 if (result != (src1 | src2)) $display("Or error ", src1, " | ", src2, ", expected: ",  src1 | src2, ", got: ", result);

		for(src1 = 0; src1 < 65490; src1 = src1 + 19) begin
			for(src2 = 0; src2 < 65490; src2 = src2 + 37) begin
				#1 if (result != (src1 | src2)) $display("Or error ", src1, " | ", src2, ", expected: ",  src1 | src2, ", got: ", result);
			end
		end

		$display("Or tests done");


		// XOR test
		controlCode = XOR;

		src1 = 65535;
		src2 = 65535;
		#1 if (result != (src1 ^ src2)) $display("Xor error ", src1, " ^ ", src2, ", expected: ",  src1 ^ src2, ", got: ", result);

		src1 = 65535;
		src2 = 0;
		#1 if (result != (src1 ^ src2)) $display("Xor error ", src1, " ^ ", src2, ", expected: ",  src1 ^ src2, ", got: ", result);

		src1 = 0;
		src2 = 65535;
		#1 if (result != (src1 ^ src2)) $display("Xor error ", src1, " ^ ", src2, ", expected: ",  src1 ^ src2, ", got: ", result);

		for(src1 = 0; src1 < 65490; src1 = src1 + 19) begin
			for(src2 = 0; src2 < 65490; src2 = src2 + 37) begin
				#1 if (result != (src1 ^ src2)) $display("Xor error ", src1, " ^ ", src2, ", expected: ",  src1 ^ src2, ", got: ", result);
			end
		end

		$display("Xor tests done");


		// addition tests
		src1 = 0;
		src2 = 0;
		controlCode = ADD;

		#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);
		
		src1 = 65535;
		src2 = 65535;
		#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);

		src1 = 65535;
		src2 = 1;
		#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);
		
		src1 = 1;
		src2 = 65535;
		#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);

		for(src1 = 0; src1 < 65490; src1 = src1 + 19) begin
			for(src2 = 0; src2 < 65490; src2 = src2 + 37) begin
				#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);
			end
		end
		
		$display("Addition tests done");


		// subtratct tests
		src1 = 0;
		src2 = 0;
		controlCode = SUB;

		#1 if (result != (src1 - src2)) $display("Subtract error ", src1, " - ", src2, ", expected: ",  src1 - src2, ", got: ", result);
		
		src1 = 65535;
		src2 = 65535;
		#1 if (result != (src1 - src2)) $display("Subtract error ", src1, " - ", src2, ", expected: ",  src1 - src2, ", got: ", result);

		src1 = 65535;
		src2 = 1;
		#1 if (result != (src1 - src2)) $display("Subtract error ", src1, " - ", src2, ", expected: ",  src1 - src2, ", got: ", result);
		
		src1 = 1;
		src2 = 65535;
		#1 if (result != (src1 - src2)) $display("Subtract error ", src1, " - ", src2, ", expected: ",  src1 - src2, ", got: ", result);

		for(src1 = 0; src1 < 65490; src1 = src1 + 19) begin
			for(src2 = 0; src2 < 65490; src2 = src2 + 37) begin
				#1 if (result != (src1 - src2)) $display("Subtract error ", src1, " - ", src2, ", expected: ",  src1 - src2, ", got: ", result);
			end
		end
		
		$display("Subtract tests done");

		

		//R shift tests
		
		controlCode = RSHIFT;
		src1 = 0;
		src2 = 0;
		
		#1 if (result != (src1 >> src2[3:0])) $display("R shift error ", src1, " >> ", src2, ", expected: ",  src1 >> src2[3:0], ", got: ", result);

		src1 = 65535;
		src2 = 16;
		
		#1 if (result != (src1 >> src2[3:0])) $display("R shift error ", src1, " >> ", src2, ", expected: ",  src1 >> src2[3:0], ", got: ", result);

		src1 = 65535;
		src2 = 0;
		
		#1 if (result != (src1 >> src2[3:0])) $display("R shift error ", src1, " >> ", src2, ", expected: ",  src1 >> src2[3:0], ", got: ", result);

		for(src1 = 0; src1 < 65490; src1 = src1 + 37) begin
			for(src2 = 0; src2 < 16; src2 = src2 + 1) begin
				#1 if (result != (src1 >> src2[3:0])) $display("R shift error ", src1, " >> ", src2, ", expected: ",  src1 >> src2[3:0], ", got: ", result);
			end
		end

		$display("RShift tests done");


		//LShift tests
		controlCode = LSHIFT;
		src1 = 0;
		src2 = 0;
		
		#1 if (result != (src1 << src2[3:0])) $display("L shift error ", src1, " << ", src2, ", expected: ",  src1 << src2[3:0], ", got: ", result);

		src1 = 65535;
		src2 = 16;
		
		#1 if (result != (src1 << src2[3:0])) $display("L shift error ", src1, " << ", src2, ", expected: ",  src1 << src2[3:0], ", got: ", result);

		src1 = 65535;
		src2 = 0;
		
		#1 if (result != (src1 << src2[3:0])) $display("L shift error ", src1, " << ", src2, ", expected: ",  src1 << src2[3:0], ", got: ", result);

		for(src1 = 0; src1 < 65490; src1 = src1 + 37) begin
			for(src2 = 0; src2 < 16; src2 = src2 + 1) begin
				#1 if (result != (src1 << src2[3:0])) $display("L shift error ", src1, " << ", src2, ", expected: ",  src1 << src2[3:0], ", got: ", result);
			end
		end

		$display("L Shift tests done");


		//Test flags


		controlCode = ADD;

		//carry
		src1 = 2;
		src2 = 3;
		#1 if (carry) $display("Carry error ", src1, " + ", src2, ", expected: ",  0, ", got: ", carry);

		src1 = 65535;
		src2 = 65535;
		#1 if (!carry) $display("Carry error ", src1, " + ", src2, ", expected: ",  1, ", got: ", carry);

		src1 = 60000;
		src2 = 34567;
		#1 if (!carry) $display("Carry error ", src1, " + ", src2, ", expected: ",  1, ", got: ", carry);

		//low
		src1 = 1;
		src2 = 0;
		#1 if (low) $display("Low error ", src1, " + ", src2, ", expected: ",  0, ", got: ", low);

		src1 = 0;
		src2 = 1;
		#1 if (!low) $display("Low error ", src1, " + ", src2, ", expected: ",  1, ", got: ", low);


		//flag / signed overflow
		src1 = $signed(5);
		src2 = $signed(10);
		#1 if (flag) $display("Flag error ", src1, " + ", src2, ", expected: ",  0, ", got: ", flag);

		src1 = $signed(-8);
		src2 = $signed(-20);
		#1 if (flag) $display("Flag error ", src1, " + ", src2, ", expected: ",  0, ", got: ", flag);

		src1 = $signed(32765);
		src2 = $signed(100);
		#1 if (!flag) $display("Flag error ", src1, " + ", src2, ", expected: ",  1, ", got: ", flag);

		src1 = $signed(-32765);
		src2 = $signed(-100);
		#1 if (!flag) $display("Flag error ", src1, " + ", src2, ", expected: ",  1, ", got: ", flag);


		//zero
		src1 = $signed(-5);
		src2 = $signed(5);
		#1 if (!zero) $display("zero error ", src1, " + ", src2, ", expected: ",  1, ", got: ", zero);

		src1 = $signed(5);
		src2 = $signed(5);
		#1 if (zero) $display("zero error ", src1, " + ", src2, ", expected: ",  0, ", got: ", zero);
		
		controlCode = AND;
		src1 = $signed(255);
		src2 = $signed(255);
		#1 if (zero) $display("zero error ", src1, " & ", src2, ", expected: ",  0, ", got: ", zero);

		src1 = $signed(1);
		src2 = $signed(2);
		#1 if (!zero) $display("zero error ", src1, " & ", src2, ", expected: ",  1, ", got: ", zero);
		controlCode = ADD;

		//negative
		src1 = $signed(1);
		src2 = $signed(0);
		#1 if (negative) $display("negative error ", src1, " + ", src2, ", expected: ",  0, ", got: ", negative);

		src1 = $signed(0);
		src2 = $signed(1);
		#1 if (!negative) $display("negative error ", src1, " + ", src2, ", expected: ",  1, ", got: ", negative);

		src1 = $signed(5);
		src2 = $signed(-5);
		#1 if (negative) $display("negative error ", src1, " + ", src2, ", expected: ",  0, ", got: ", negative);

		src1 = $signed(-100);
		src2 = $signed(-50);
		#1 if (!negative) $display("negative error ", src1, " + ", src2, ", expected: ",  1, ", got: ", negative);


		$display("Flags tests done");


		#5 $display("All tests finished.");

	end



endmodule



