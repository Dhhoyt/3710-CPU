module datapath 
    (input clock, reset,

     input [1:0] alu_a_select,
     input alu_b_select,
     input [1:0] alu_operation,

     input program_counter_write_enable,

     input instruction_write_enable,
     output [15:0] instruction,

     input register_write_enable,

     input [15:0] memory_read_data,
     output [15:0] memory_address);

    parameter ALU_A_PROGRAM_COUNTER = 2'b00;
    parameter ALU_A_SOURCE = 2'b01;
    parameter ALU_A_IMMEDIATE_SIGN_EXTENDED = 2'b10;
    parameter ALU_A_IMMEDIATE_ZERO_EXTENDED = 2'b11;

    parameter ALU_B_DESTINATION = 1'b0;
    parameter ALU_B_CONSTANT_ONE = 1'b1;

    localparam CONSTANT_ONE =  16'b1;

    wire [15:0] program_counter, next_program_counter, 
                alu_a, alu_b, alu_d, 
                result, source, destination, 
                immediate, immediate_sign_extended, immediate_zero_extended;
    wire [3:0] register_address_destination, register_address_source, operation_extra;

    // TODO: Will want to mux with output from ALU
    assign memory_address = program_counter;
    // TODO: Will want to mux with several other things
    assign next_program_counter = alu_d;

    // Instruction decoding fields
    assign register_address_destination = instruction[11:8];
    assign register_address_source = instruction[3:0];
    assign operation_extra = instruction[7:4];

    assign immediate = instruction[7:0];
    assign immediate_sign_extended = { {8{immediate[7]}}, immediate };
    assign immediate_zero_extended = { 8'h00, immediate };

    flop_enable_reset #(16) program_counter_register
        (clock, reset, program_counter_write_enable, next_program_counter, program_counter);
    flop_enable_reset #(16) instruction_register
        (clock, reset, instruction_write_enable, memory_read_data, instruction);
    // TODO: Do we need this?
    flop_reset #(16) alu_result_register
        (clock, reset, alu_d, result);

    mux4 alu_a_mux(program_counter, source, immediate_sign_extended, immediate_zero_extended, 
                   alu_a_select, alu_a);
    mux2 alu_b_mux(destination, CONSTANT_ONE, alu_b_select, alu_b);
    // TODO: Don't think we need this, it will always just be the destination
    // mux2(instr[REGBITS+15:16], instr[REGBITS+10:11], regdst, wa);

    alu alu1(alu_a, alu_b, alu_operation, alu_d);
    register_file register_file1
    (clock, register_write_enable,
     register_address_source,
     register_address_destination,
     // TODO: Will it ever change? See above commented out mux2
     register_address_destination,
     result, 
     source, destination);
endmodule

// Arithmetic and Logic Unit
//
// d <- o(a, b)
//
// Operations:
// - ADD: Addition
module alu
    (input [15:0] a, b,
     input [1:0] o,
     output reg [15:0] d);

    parameter ADD = 2'b00;
    parameter SUBTRACT = 2'b01;

    always @(*)
        begin
            case (o)
                ADD: d <= a + b;
                SUBTRACT: d <= a + (~b) + 1;
            endcase
        end
endmodule

// Register file
// 
// We need dual ported read because we need to read the source and
// destination similultaneously during decode.
module register_file 
    (input clock,
     input write_enable,
     input [3:0] read_address1, read_address2, write_address,
     input [15:0] write_data,
     output [15:0] read_data1, read_data2);
   
    reg [15:0] registers [15:0];

    integer i;
    initial begin
        for (i = 0; i < 16; i = i+1) registers[i] = 0;
    end

    always @(posedge clock)
        if (write_enable) registers[write_address] <= write_data;

    // Register 0 is hardwired to 0
    assign read_data1 = read_address1 ? registers[read_address1] : 0;
    assign read_data2 = read_address2 ? registers[read_address2] : 0;
endmodule

