module rightShift(
    input wire [15:0] x,
    input wire [3:0] shift_amount,
    output reg [15:0] res
);

always @ (*) begin
    case(shift_amount)
        4'b0000: res = x >> 0;
        4'b0001: res = x >> 1;
        4'b0010: res = x >> 2;
        4'b0011: res = x >> 3;
        4'b0100: res = x >> 4;
        4'b0101: res = x >> 5;
        4'b0110: res = x >> 6;
        4'b0111: res = x >> 7;
        4'b1000: res = x >> 8;
        4'b1001: res = x >> 9;
        4'b1010: res = x >> 10;
        4'b1011: res = x >> 11;
        4'b1100: res = x >> 12;
        4'b1101: res = x >> 13;
        4'b1110: res = x >> 14;
        4'b1111: res = x >> 15;
        default: res = 0;
    endcase
end

endmodule