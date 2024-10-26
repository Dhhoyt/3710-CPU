module cpu
    (input clock, reset,

     input [15:0] memory_read_data,
     output memory_write_enable,
     output [15:0] memory_address,
     output [15:0] memory_write_data);


    wire [SOMETHING:0] alu_a_select, alu_b_select, alu_operation;

    wire program_counter_write_enable;

    wire [15:0] instruction;
    wire instruction_write_enable;

    wire register_write_enable;

    controller(clock, reset,
               alu_a_select, alu_b_select, alu_operation,
               program_counter_write_enable,
               instruction[15:12], instruction_write_enable, // Instruction operation code is bits 15-12
               register_write_enable,
               memory_write_enable);
    datapath(clock, reset,
             alu_a_select, alu_b_select, alu_operation
             program_counter_write_enable,
             instruction_write_enable, instruction,
             register_write_enable,
             memory_read_data, memory_address);
endmodule


// Controller
// 3-stage pipeline: fetch, decode, execute
//
// Fetch: During a fetch, we must (1) write `read_data` from memory to
// the instruction register, and (2) increment the program counter.
//
// 1. Writing the instruction register involves setting `address` to
// the contents of the program counter (TODO), and bringing
// `instruction_write_enable` high.
//
// 2. To increment the program counter, we set select the program
// counter and a constant one signal for the `a` and `b` inputs to the
// ALU, respectively, and we set the ALU operation to addition. To
// make sure the result is written back to the program counter at the
// end of the cycle, we bring `program_counter_write_enable` high.
//
//
// TODO: Update as this gets more complicated
// Decode: Decoding consists of (1) setting `next_state` appropriately
// based on the operation code and (2) directing the register file to
// read the register addresses contained in the source and destination
// fields of the instruction.
module controller 
    (input clock, reset,

     output reg [1:0] alu_a_select, alu_b_select,
     output reg [SOMETHING:0] alu_operation

     output reg program_counter_write_enable,

     input [3:0] instruction_operation,
     input instruction_write_enable,
     
     output reg register_write_enable,

     output reg memory_write_enable
     );

    parameter OPERATION_RTYPE = 4'b0000;
    parameter OPERATION_ANDI = 4'b0001;
    parameter OPERATION_ORI = 4'b0010;
    parameter OPERATION_XORI = 4'b0011;
    // TODO: Name
    parameter OPERATION_MEMORY = 4'b0100;
    parameter OPERATION_ADDI = 4'b0101;
    parameter OPERATION_ADDUI = 4'b0110; // Unimplemented
    parameter OPERATION_ADDCI = 4'b0111; // Unimplemented
    parameter OPERATION_UNUSED1 = 4'b1000; // Unused
    parameter OPERATION_SUBI = 4'b1001;
    parameter OPERATION_SUBCI = 4'b1010; // Unimplemented
    parameter OPERATION_CMPI = 4'b1011;
    parameter OPERATION_DISP = 4'b1100;
    parameter OPERATION_MOVI = 4'b1101;
    parameter OPERATION_MULI = 4'b1110; // Unimplemented
    parameter OPERATION_LUI = 4'b1111;

    // TODO: Make appropriate size
    parameter FETCH = 2'h00;
    parameter DECODE = 2'b01;
    parameter EXECUTE_RTYPE = 2'b01;

    reg [1:0] state, next_state;

    always @(posedge clock)
        if (~reset) state <= FETCH;
        else state <= next_state;

    // TODO: Next state logic
    always @(*)
        begin
            case (state)
                FETCH: next_state <= DECODE;
                DECODE:
                    begin
                        case (operation)
                            OPERATION_RTYPE: next_state <= EXECUTE_RTYPE;
                            // TODO
                        endcase
                    end
                EXECUTE_RTYPE: next_state <= FETCH;
            endcase
        end

    // TODO: Output combinational logic
    always @(*)
        begin
            case (state)
                FETCH:
                    begin
                        instruction_write_enable <= 1;
                        program_counter_write_enable <= 1;
                        alu_a_select <= ALU_A_PROGRAM_COUNTER;
                        alu_b_select <= ALU_B_CONSTANT_ONE;
                        alu_operation <= ADD;
                    end
                DECODE:
                    begin
                        // TODO
                    end
                EXECUTE_RTYPE:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= ADD;
                        // TODO
                        // Place result in a register
                    end
                WRITE_RTYPE:
                    begin
                        register_write_enable <= 1;
                        register_write_data_select <= ALU_RESULT_TODO;
                    end
            endcase
        end
endmodule

module datapath 
    #(parameter WIDTH = 16)
    (input clock, reset,

     input [1:0] alu_a_select, alu_b_select,
     input [SOMETHING:0] alu_operation,

     input program_counter_write_enable,

     input instruction_write_enable,
     output [WIDTH-1:0] instruction,

     input register_write_enable,

     input [WIDTH-1:0] memory_read_data,
     output [WIDTH-1:0] memory_address);

    localparam CONSTANT_ONE =  8'b1;

    wire [WIDTH-1:0] program_counter, next_program_counter, alu_a, alu_b, alu_d, alu_result_todo, source, destination, register_write_todo;
    wire [3:0] register_address_destination, register_address_source, register_address_write_todo, operation_extra;
    wire [7:0] immediate;

    // TODO: Will want to mux with output from ALU
    assign memory_address = program_counter;
    // TODO: Will want to mux with several other things
    assign next_program_counter = alu_d;

    // Instruction decoding fields
    assign register_address_destination = instruction[11:8];
    assign register_address_source = instruction[3:0];
    assign immediate = instruction[7:0];
    assign operation_extra = instruction[7:4];

    flop_enable_reset #(WIDTH) (clock, reset, program_counter_write_enable, next_program_counter, program_counter);
    flop_enable_reset #(WIDTH) (clock, reset, instruction_write_enable, read_data, instruction);
    flop_enable #(WIDTH) (clock, reset, alu_d, alu_result_todo);

    mux2(program_counter, SOMETHING_ELSE1, alu_a_select, alu_a);
    mux2(CONSTANT_ONE, SOMETHING_ELSE2, alu_b_select, alu_a);
    // TODO: Don't think we need this, it will always just be the destination
    // mux2(instr[REGBITS+15:16], instr[REGBITS+10:11], regdst, wa);

    alu #(WIDTH) (alu_a, alu_b, alu_operation, alu_d);
    register_file #(WIDTH) 
    (clock, register_write_enable, 
     register_address_source, 
     register_address_destination, 
     // TODO: Will it ever change? See above commented out mux2
     register_address_destination, 
     register_write_todo, source, destination);
endmodule

// Arithmetic and Logic Unit
//
// d <- o(a, b)
//
// Operations:
// - ADD: Addition
module alu
    #(parameter WIDTH = 16)
    (input [WIDTH-1:0] a, b,
     input [SOMETHING:0] o,
     output [WDITH-1:0] d);
endmodule

// Register file
// We need dual ported read because we need to read the source and destination similultaneously during decode.
//
// Parameters:
// WIDTH : Size of each register
// INDEX_BITS : `log2(n)` where `n` is the number of registers
module register_file 
    #(parameter WIDTH = 16, INDEX_BITS = 4)
    (input                  clock,
     input                  write_enable,
     input [INDEX_BITS-1:0] read_address1, read_address2, write_address,
     input [WIDTH-1:0]      write_data,
     output [WIDTH-1:0]     read_data1, read_data2);
   
    reg [WIDTH-1:0] registers [(1<<INDEX_BITS)-1:0];

    initial begin
        $readmemb$("/path/to/registers_zeros.data", registers);
    end

    always @(posedge clock)
        if (write_enable) registers[write_address] <= write_data;

    // Register 0 is hardwired to 0
    assign read_data1 = read_address1 ? REGISTERS[read_address1] : 0;
    assign read_data2 = read_address2 ? REGISTERS[read_address2] : 0;
endmodule

module memory
    #(parameter WIDTH=16)
    (input clock,
     input [WIDTH-1:0] write_data_a, write_data_b,
     input [WIDTH-1:0] address_a, address_b,
     input write_enable_a, write_enable_b,
     output reg [WIDTH-1:0] read_data_a, read_data_b);

endmodule

module flop_reset 
    #(paramater WIDTH = 16)
    (input clock, reset,
     input [WIDTH-1:0] d,
     output reg [WIDTH-1:0] q);

    always @(posedge clock)
        if (~reset) q <= 0;
        else q <= d;
endmodule

module flop_enable_reset
    #(parameter WIDTH = 16)
    (input clock, reset, enabl
     input [WIDTH-1:0] d,
     output reg [WIDTH-1:0] q);

    always @(posedge clock)
        if (~reset) q <= 0;
        else if (enable) q <= d;
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
