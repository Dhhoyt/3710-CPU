// https://projectf.io/posts/square-root-in-verilog/
module sqrt32to16 (
    input wire [31:0] x, // Input (Q16.16)
    output wire [15:0] res // Output (Q8.8)
);

    wire [31:0] diff [14:0];

    attemptSqrtSubtraction ass1 (.brought_down(x[31:30]), .x(32'b0),     .existing_answer(16'b0),              .res(diff[0]),  .subtract(res[15]));
    attemptSqrtSubtraction ass2 (.brought_down(x[29:28]), .x(diff[0]),  .existing_answer({15'b0, res[15:15]}), .res(diff[1]),  .subtract(res[14]));
    attemptSqrtSubtraction ass3 (.brought_down(x[27:26]), .x(diff[1]),  .existing_answer({14'b0, res[15:14]}), .res(diff[2]),  .subtract(res[13]));
    attemptSqrtSubtraction ass4 (.brought_down(x[25:24]), .x(diff[2]),  .existing_answer({13'b0, res[15:13]}), .res(diff[3]),  .subtract(res[12]));
    attemptSqrtSubtraction ass5 (.brought_down(x[23:22]), .x(diff[3]),  .existing_answer({12'b0, res[15:12]}), .res(diff[4]),  .subtract(res[11]));
    attemptSqrtSubtraction ass6 (.brought_down(x[21:20]), .x(diff[4]),  .existing_answer({11'b0, res[15:11]}), .res(diff[5]),  .subtract(res[10]));
    attemptSqrtSubtraction ass7 (.brought_down(x[19:18]), .x(diff[5]),  .existing_answer({10'b0, res[15:10]}), .res(diff[6]),  .subtract(res[9]));
    attemptSqrtSubtraction ass8 (.brought_down(x[17:16]), .x(diff[6]),  .existing_answer({9'b0,  res[15: 9]}), .res(diff[7]),  .subtract(res[8]));
    attemptSqrtSubtraction ass9 (.brought_down(x[15:14]), .x(diff[7]),  .existing_answer({8'b0,  res[15: 8]}), .res(diff[8]),  .subtract(res[7]));
    attemptSqrtSubtraction ass10(.brought_down(x[13:12]), .x(diff[8]),  .existing_answer({7'b0,  res[15: 7]}), .res(diff[9]),  .subtract(res[6]));
    attemptSqrtSubtraction ass11(.brought_down(x[11:10]), .x(diff[9]),  .existing_answer({6'b0,  res[15: 6]}), .res(diff[10]), .subtract(res[5]));
    attemptSqrtSubtraction ass12(.brought_down(x[9:8]),   .x(diff[10]), .existing_answer({5'b0,  res[15: 5]}), .res(diff[11]), .subtract(res[4]));
    attemptSqrtSubtraction ass13(.brought_down(x[7:6]),   .x(diff[11]), .existing_answer({4'b0,  res[15: 4]}), .res(diff[12]), .subtract(res[3]));
    attemptSqrtSubtraction ass14(.brought_down(x[5:4]),   .x(diff[12]), .existing_answer({3'b0,  res[15: 3]}), .res(diff[13]), .subtract(res[2]));
    attemptSqrtSubtraction ass15(.brought_down(x[3:2]),   .x(diff[13]), .existing_answer({2'b0,  res[15: 2]}), .res(diff[14]), .subtract(res[1]));
    attemptSqrtSubtraction ass16(.brought_down(x[1:0]),   .x(diff[14]), .existing_answer({1'b0,  res[15: 1]}),                 .subtract(res[0]));
endmodule

module attemptSqrtSubtraction(
    input wire [1:0] brought_down,  
    input wire [31:0] x,
    input wire [15:0] existing_answer,
    output wire [31:0] res,
    output wire subtract
);

    wire [31:0] minuend = {x, brought_down};
    wire [31:0] subtrahend = {existing_answer, 2'b01};

    assign subtract = minuend >= subtrahend;
    wire [31:0] difference = minuend - subtrahend;

    assign res = subtract ? difference : minuend;

endmodule