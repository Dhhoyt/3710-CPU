// https://projectf.io/posts/square-root-in-verilog/

module sqrt(
    input wire [15:0] x,
    output wire [15:0] res
);

assign res[15:12] = 4'b0000;

wire [15:0] diff [10:0];

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

module attemptSqrtSubtraction(
    input wire [1:0] brought_down,  
    input wire [15:0] x,
    input wire [15:0] existing_answer,
    output wire [15:0] res,
    output wire subtract
);

wire [15:0] minuend = {x, brought_down};
wire [15:0] subtrahend = {existing_answer, 2'b01};

assign subtract = minuend >= subtrahend;
wire [15:0] difference = minuend - subtrahend;;

assign res = subtract ? difference : minuend;

endmodule

