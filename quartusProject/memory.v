module memory
    #(parameter WIDTH=16)
    (input clock,
     input [WIDTH-1:0] write_data_a, write_data_b,
     input [WIDTH-1:0] address_a, address_b,
     input write_enable_a, write_enable_b,
     output reg [WIDTH-1:0] read_data_a, read_data_b);

endmodule
