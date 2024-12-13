// https://projectf.io/posts/square-root-in-verilog/

/********************************************************************************
* Square Root Calculator
*
* This module implements a digit-by-digit binary square root calculator based on 
* subtraction and shifts. It processes 16-bit inputs 2 bits at a time using a 
* chain of trial subtraction stages.
*
* Algorithm:
* 1. Input bits are processed in pairs from MSB to LSB, using "bring down" process
* 2. At each stage, attempts trial subtraction to determine if current bit is 1 or 0
* 3. Upper 4 bits of result (15:12) are always 0 since sqrt(65535) < 256
* 4. Lower 12 bits (11:0) are computed through sequential trial subtractions
* 
* Example for input 0001 0001 (decimal 17):
* Stage 1: Process bits 00 -> trial number = 01 -> succeeds -> first bit is 1
* Stage 2: Process bits 01 -> trial number = 10 -> fails -> next bit is 0  
* Stage 3: Process bits 00 -> trial number = 01 -> succeeds -> next bit is 1
* Stage 4: Process bits 01 -> trial number = 01 -> fails -> final bit is 0
* Result = 0100 (decimal 4, sqrt(17)=4 remainder 1)
********************************************************************************/

module sqrt(
    input wire [15:0] x,
    output wire [15:0] res
);

// Upper 4 bits are always 0 since sqrt(65535) < 256
assign res[15:12] = 4'b0000;

// Storage for intermediate remainders between stages
wire [15:0] diff [10:0];

// Chain of 12 subtraction stages to compute each result bit
// Each stage brings down 2 new bits and attempts subtraction
// Format: (.brought_down = new bits, .x = previous remainder, 
//          .existing_answer = partial result so far, 
//          .res = new remainder, .subtract = new result bit)

attemptSqrtSubtraction ass1 (.brought_down(x[15:14]), .x(8'b0),     .existing_answer(4'b0),      .res(diff[0]),  .subtract(res[11]));
attemptSqrtSubtraction ass2 (.brought_down(x[13:12]), .x(diff[0]),  .existing_answer(res[11:11]), .res(diff[1]),  .subtract(res[10]));
attemptSqrtSubtraction ass3 (.brought_down(x[11:10]), .x(diff[1]),  .existing_answer(res[11:10]), .res(diff[2]),  .subtract(res[9]));
attemptSqrtSubtraction ass4 (.brought_down(x[9:8]),   .x(diff[2]),  .existing_answer(res[11:9]),  .res(diff[3]),  .subtract(res[8]));
attemptSqrtSubtraction ass5 (.brought_down(x[7:6]),   .x(diff[3]),  .existing_answer(res[11:8]),  .res(diff[4]),  .subtract(res[7]));
attemptSqrtSubtraction ass6 (.brought_down(x[5:4]),   .x(diff[4]),  .existing_answer(res[11:7]),  .res(diff[5]),  .subtract(res[6]));
attemptSqrtSubtraction ass7 (.brought_down(x[3:2]),   .x(diff[5]),  .existing_answer(res[11:6]),  .res(diff[6]),  .subtract(res[5]));
attemptSqrtSubtraction ass8 (.brought_down(x[1:0]),   .x(diff[6]),  .existing_answer(res[11:5]),  .res(diff[7]),  .subtract(res[4]));
attemptSqrtSubtraction ass9 (.brought_down(2'b00),    .x(diff[7]),  .existing_answer(res[11:4]),  .res(diff[8]),  .subtract(res[3]));
attemptSqrtSubtraction ass10(.brought_down(2'b00),    .x(diff[8]),  .existing_answer(res[11:3]),  .res(diff[9]),  .subtract(res[2]));
attemptSqrtSubtraction ass11(.brought_down(2'b00),    .x(diff[9]),  .existing_answer(res[11:2]),  .res(diff[10]), .subtract(res[1]));
attemptSqrtSubtraction ass12(.brought_down(2'b00),    .x(diff[10]), .existing_answer(res[11:1]),  .subtract(res[0]));

endmodule

/********************************************************************************
* Square Root Trial Subtraction Stage
*
* This module implements one stage of the digit-by-digit square root algorithm,
* computing one bit of the final result through a trial subtraction.
*
* Operation per stage:
* 1. Forms minuend by appending 2 new input bits to previous remainder
* 2. Forms trial subtrahend by appending '01' to current partial result 
* 3. If minuend ≥ subtrahend:
*    - Subtraction succeeds -> result bit is 1
*    - Remainder = difference
* 4. If minuend < subtrahend:
*    - Subtraction fails -> result bit is 0
*    - Remainder = minuend (keep original value)
*
* Example Stage:
* Previous remainder = 0001, Brought down bits = 01, Existing answer = 100
* Minuend = 000101 (previous_remainder + brought_down)
* Subtrahend = 10001 (existing_answer + '01')
* Since 000101 < 10001, subtraction fails
* Therefore result bit = 0, remainder = 000101
********************************************************************************/
module attemptSqrtSubtraction(
    input wire [1:0] brought_down,    // Two new bits from input number
    input wire [15:0] x,              // Previous remainder
    input wire [15:0] existing_answer, // Partial result computed so far 
    output wire [15:0] res,           // New remainder for next stage
    output wire subtract              // New result bit (1 if subtraction succeeds)
);

// Form number to subtract from by appending new bits to previous remainder
wire [15:0] minuend = {x, brought_down};

// Form trial value by appending '01' to existing partial result 
wire [15:0] subtrahend = {existing_answer, 2'b01};

// Determine if subtraction succeeds (result bit is 1) or fails (result bit is 0)
assign subtract = minuend >= subtrahend;

// Perform the trial subtraction
wire [15:0] difference = minuend - subtrahend;

// Select remainder based on whether subtraction succeeded
assign res = subtract ? difference : minuend;

endmodule
