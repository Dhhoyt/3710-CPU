// Utilities for use in datapath

module flop_reset 
    #(parameter WIDTH = 16)
    (input c, r,
     input [WIDTH-1:0] d,
     output reg [WIDTH-1:0] q);
    
    always @(posedge c)
        if (~r) q <= 0;
        else q <= d;
endmodule

module flop_enable_reset
    #(parameter WIDTH = 16)
    (input c, r, e,
     input [WIDTH-1:0] d,
     output reg [WIDTH-1:0] q);

    always @(posedge c)
        if (~r) q <= 0;
        else if (e) q <= d;
endmodule

module mux2 
    #(parameter WIDTH = 16)
    (input [WIDTH-1:0] d0, d1,
     input s,
     output [WIDTH-1:0] y);

    assign y = s ? d1 : d0;
endmodule

module mux4
    #(parameter WIDTH = 16)
    (input [WIDTH-1:0] d0, d1, d2, d3,
     input [1:0] s, 
     output reg [WIDTH-1:0] y);

    always @(*)
        case (s)
            2'b00: y <= d0;
            2'b01: y <= d1;
            2'b10: y <= d2;
            2'b11: y <= d3;
        endcase
endmodule

module mux8
    #(parameter WIDTH = 16)
    (input [WIDTH-1:0] d0, d1, d2, d3, d4, d5, d6, d7,
     input [2:0] s, 
     output reg [WIDTH-1:0] y);

    always @(*)
        case (s)
            3'b000: y <= d0;
            3'b001: y <= d1;
            3'b010: y <= d2;
            3'b011: y <= d3;
            3'b100: y <= d4;
            3'b101: y <= d5;
            3'b110: y <= d6;
            3'b111: y <= d7;
        endcase
endmodule

module mux16
    #(parameter WIDTH = 16)
    (input [WIDTH-1:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15,
     input [3:0] s, 
     output reg [WIDTH-1:0] y);

    always @(*)
        case (s)
            3'b000: y <= d0;
            3'b001: y <= d1;
            3'b010: y <= d2;
            3'b011: y <= d3;
            3'b100: y <= d4;
            3'b101: y <= d5;
            3'b110: y <= d6;
            3'b111: y <= d7;
        endcase
endmodule
