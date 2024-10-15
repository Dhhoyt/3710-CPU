//https://coertvonk.com/hw/building-math-circuits/parameterized-divider-in-verilog-30776

`define ATTEMPT_SUBTRACT_LINE(num) sixteenWideAttemptSubtractLine asl``num``(.x_shifted(d_arr[num]), .x_new_bit(dividend[14 - num]), .y(divisor), .os(os[22- num]), .d(d_arr[num + 1]))
`define ATTEMPT_SUBTRACT_LINE_ZERO_X(num) sixteenWideAttemptSubtractLine asl``num``(.x_shifted(d_arr[num]), .x_new_bit(1'b0), .y(divisor), .os(os[22- num]), .d(d_arr[num + 1]))

module attemptSubtractDivision (
    input wire [15:0] dividend,
    input wire [15:0] divisor,
    output wire [15:0] quotient
);

	wire [15:0] d_arr[23:0];

	wire [23:0] os;

	assign quotient = ~os[15:0];
	
	sixteenWideAttemptSubtractLine aslstart(.x_shifted(16'b0), .x_new_bit(dividend[15]), .y(divisor), .os(os[23]), .d(d_arr[0]));
	`ATTEMPT_SUBTRACT_LINE(0);
	`ATTEMPT_SUBTRACT_LINE(1);
	`ATTEMPT_SUBTRACT_LINE(2);
	`ATTEMPT_SUBTRACT_LINE(3);
	`ATTEMPT_SUBTRACT_LINE(4);
	`ATTEMPT_SUBTRACT_LINE(5);
	`ATTEMPT_SUBTRACT_LINE(6);
	`ATTEMPT_SUBTRACT_LINE(7);
	`ATTEMPT_SUBTRACT_LINE(8);
	`ATTEMPT_SUBTRACT_LINE(9);
	`ATTEMPT_SUBTRACT_LINE(10);
	`ATTEMPT_SUBTRACT_LINE(11);
	`ATTEMPT_SUBTRACT_LINE(12);
	`ATTEMPT_SUBTRACT_LINE(13);
	`ATTEMPT_SUBTRACT_LINE(14);

	`ATTEMPT_SUBTRACT_LINE_ZERO_X(15);
	`ATTEMPT_SUBTRACT_LINE_ZERO_X(16);
	`ATTEMPT_SUBTRACT_LINE_ZERO_X(17);
	`ATTEMPT_SUBTRACT_LINE_ZERO_X(18);
	`ATTEMPT_SUBTRACT_LINE_ZERO_X(19);
	`ATTEMPT_SUBTRACT_LINE_ZERO_X(20);
	`ATTEMPT_SUBTRACT_LINE_ZERO_X(21);
	`ATTEMPT_SUBTRACT_LINE_ZERO_X(22);

endmodule

`define ATTEMPT_SUBTRACT_MODULE(num) attemptSubtractModule asm``num``(.x(x[num]), .y(y[num]), .b(b[num - 1]), .os(os), .b0(b[num]), .d(d[num]))

module sixteenWideAttemptSubtractLine (
    input wire [15:0] x_shifted, // There needs to be bits + 1 subtraction modules. This is not a typo
    input wire x_new_bit, // There needs to be bits + 1 subtraction modules. This is not a typo
    input wire [15:0] y,
    output wire os,
    output wire [15:0] d
);

	wire [16:0] x;
	assign x = {x_shifted, x_new_bit};

	wire b[16:0];

	assign os = b[16];

	attemptSubtractModule asm0(.x(x[0]), .y(y[0]), .b(1'b0), .os(os), .b0(b[0]), .d(d[0]));
	`ATTEMPT_SUBTRACT_MODULE(1);
	`ATTEMPT_SUBTRACT_MODULE(2);
	`ATTEMPT_SUBTRACT_MODULE(3);
	`ATTEMPT_SUBTRACT_MODULE(4);
	`ATTEMPT_SUBTRACT_MODULE(5);
	`ATTEMPT_SUBTRACT_MODULE(6);
	`ATTEMPT_SUBTRACT_MODULE(7);
	`ATTEMPT_SUBTRACT_MODULE(8);
	`ATTEMPT_SUBTRACT_MODULE(9);
	`ATTEMPT_SUBTRACT_MODULE(10);
	`ATTEMPT_SUBTRACT_MODULE(11);
	`ATTEMPT_SUBTRACT_MODULE(12);
	`ATTEMPT_SUBTRACT_MODULE(13);
	`ATTEMPT_SUBTRACT_MODULE(14);
	`ATTEMPT_SUBTRACT_MODULE(15);
	attemptSubtractModule asm16(.x(x[16]), .y(1'b0), .b(b[15]), .os(os), .b0(b[16]));

endmodule

module attemptSubtractModule (
    input wire x, // Dividend
    input wire y, // Divisor
    input wire b, // Whether all the bits before this have y > x, also if we're borrowing
    input wire os, // Controls whether the line subtracts or not. A 1 is no subtract, 0 means subtract
    output wire b0, // y > x
    output wire d // Result of conditional subtraction
);

	wire d_prime;
	assign d_prime = x ^ y ^ b;
	assign d = (os & x) | (~os & d_prime);
	assign b0 = (~x & y) | (b & (x ~^ y));

endmodule