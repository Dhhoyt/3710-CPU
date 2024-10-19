//testbench for an ALU

module tb_alu;

	// these need to be setup for our ALU
	parameter ALUADD             =  3'd2;
	parameter ALUSUB             =  3'd1;
	parameter ALUOR              =  3'd1;
	parameter ALUAND             =  3'd0;
	parameter ALUXOR             =  3'd4;
	parameter ALUSHIFT           =  3'd5;
	parameter ALUSHIFTSIGNEXTEND =  3'd6;
	parameter ALUMUL             =  3'd7;


	// these are all too small rn
	reg [7:0] src1, src2;
	reg [2:0] controlCode;
	wire [7:0] result;

	alu DUT (src1, src2, controlCode, result);

	initial begin
		$display("BeginALU test");

		// addition tests
		src1 = 0;
		src2 = 0;
		controlCode = ALUADD;

		#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);
		
		src1 = 255;
		src2 = 255;
		#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);

		src1 = 255;
		src2 = 1;
		#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);
		
		src1 = 1;
		src2 = 255;
		#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);

		for(src1 = 0; src1 < 240; src1 = src1 + 7) begin
			for(src2 = 0; src2 < 240; src2 = src2 + 13) begin
				#1 if (result != (src1 + src2)) $display("Addition error ", src1, " + ", src2, ", expected: ",  src1 + src2, ", got: ", result);
			end
		end
		
		$display("Addition tests done");


		controlCode = ALUAND;

		src1 = 255;
		src2 = 255;
		#1 if (result != (src1 & src2)) $display("And error ", src1, " & ", src2, ", expected: ",  src1 & src2, ", got: ", result);

		src1 = 255;
		src2 = 0;
		#1 if (result != (src1 & src2)) $display("And error ", src1, " & ", src2, ", expected: ",  src1 & src2, ", got: ", result);

		src1 = 0;
		src2 = 255;
		#1 if (result != (src1 & src2)) $display("And error ", src1, " & ", src2, ", expected: ",  src1 & src2, ", got: ", result);

		for(src1 = 0; src1 < 240; src1 = src1 + 7) begin
			for(src2 = 0; src2 < 240; src2 = src2 + 13) begin
				#1 if (result != (src1 & src2)) $display("And error ", src1, " & ", src2, ", expected: ",  src1 & src2, ", got: ", result);
			end
		end

		$display("And tests done");



		#5 $display("All tests finished.");

	end



endmodule

