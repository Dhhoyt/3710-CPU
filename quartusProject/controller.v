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

     output reg [1:0] alu_a_select, 
     output reg alu_b_select,
     output reg [1:0] alu_operation,

     output reg program_counter_write_enable,

     input [3:0] instruction_operation,
     input [3:0] instruction_operation_extra,
     output reg instruction_write_enable,
     
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

    parameter OPERATION_EXTRA_ADD = 4'b0101;
    parameter OPERATION_EXTRA_SUB = 4'b1001;
    parameter OPERATION_EXTRA_CMP = 4'b1011;
    parameter OPERATION_EXTRA_AND = 4'b0001;
    parameter OPERATION_EXTRA_OR  = 4'b0010;
    parameter OPERATION_EXTRA_XOR = 4'b0011;
    parameter OPERATION_EXTRA_MOV = 4'b1101;
    parameter OPERATION_EXTRA_LSH = 4'b0100;
    parameter OPERATION_EXTRA_LOAD = 4'b0000;
    parameter OPERATION_EXTRA_STOR = 4'b0100;
    parameter OPERATION_EXTRA_JCOND = 4'b1100;
    parameter OPERATION_EXTRA_JAL = 4'b1000;

    // TODO: Make appropriate size
    parameter FETCH = 3'b000;
    parameter DECODE = 3'b001;
    parameter EXECUTE_ADD = 3'b010;
    parameter EXECUTE_ADDI = 3'b011;
    parameter EXECUTE_SUB = 3'b100;
    parameter WRITE = 3'b101;

    parameter ALU_A_PROGRAM_COUNTER = 2'b00;
    parameter ALU_A_SOURCE = 2'b01;
    parameter ALU_A_IMMEDIATE_SIGN_EXTENDED = 2'b10;
    parameter ALU_A_IMMEDIATE_ZERO_EXTENDED = 2'b11;

    parameter ALU_B_DESTINATION = 1'b0;
    parameter ALU_B_CONSTANT_ONE = 1'b1;

    parameter ADD = 2'b00;
    parameter SUBTRACT = 2'b01;

    reg [2:0] state, next_state;

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
                        case (instruction_operation)
                            OPERATION_RTYPE:
                                begin
                                    case (instruction_operation_extra)
                                        OPERATION_EXTRA_ADD: next_state <= EXECUTE_ADD;
                                        OPERATION_EXTRA_SUB: next_state <= EXECUTE_SUB;
                                        // TODO
                                    endcase
                                end
                            OPERATION_ADDI: next_state <= EXECUTE_ADDI;
                        endcase
                    end
                EXECUTE_ADD: next_state <= WRITE;
                EXECUTE_SUB: next_state <= WRITE;
                EXECUTE_ADDI: next_state <= WRITE;
                WRITE: next_state <= FETCH;
            endcase
        end

    // TODO: Output combinational logic
    always @(*)
        begin
            // Defaults:
            instruction_write_enable <= 0;
            program_counter_write_enable <= 0;
            register_write_enable <= 0;
            memory_write_enable <= 0;
            alu_a_select <= 0;
            alu_b_select <= 0;
            alu_operation <= 0;

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
                    end
                EXECUTE_ADD:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= ADD;
                    end
                EXECUTE_ADDI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_SIGN_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= ADD;
                    end
                EXECUTE_SUB:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= SUBTRACT;
                    end
                WRITE:
                    begin
                        register_write_enable <= 1;
                    end
            endcase
        end
endmodule
