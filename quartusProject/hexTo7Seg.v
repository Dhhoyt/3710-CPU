//
// Module to take a single (4-bit) binary value and 
// display it on a 7-segment display as a hex number
// 
module hexTo7Seg(input [3:0]SW,        // input switches
		output reg [6:0]Hex ); // ouput 7-seg display

  // always @* guarantees that the synthesized circuit
  // is combinational (no clocks, registers, or latches)
  always @*
    // Note that the 7-segment displays on the DE1-SoC board are
    // "active low" - a 0 turns on the segment, and 1 turns it off
    // I've specified with 1 for "on", but then inverted the bits
    // to make them active-low
    case(SW)
      4'b0000 : Hex = ~7'b0111111; // 0
      4'b0001 : Hex = ~7'b0000110; // 1
      4'b0010 : Hex = ~7'b1011011; // 2
      4'b0011 : Hex = ~7'b1001111; // 3
      4'b0100 : Hex = ~7'b1100110; // 4
      4'b0101 : Hex = ~7'b1101101; // 5
      4'b0110 : Hex = ~7'b1111101; // 6
      4'b0111 : Hex = ~7'b0000111; // 7
      4'b1000 : Hex = ~7'b1111111; // 8
      4'b1001 : Hex = ~7'b1100111; // 9 
      4'b1010 : Hex = ~7'b1110111; // A
      4'b1011 : Hex = ~7'b1111100; // b
      4'b1100 : Hex = ~7'b1011000; // c
      4'b1101 : Hex = ~7'b1011110; // d
      4'b1110 : Hex = ~7'b1111001; // E
      4'b1111 : Hex = ~7'b1110001; // F
      default : Hex = ~7'b0000000; // Always good to have a default! 
    endcase // case (SW)
endmodule // hexTo7Seg