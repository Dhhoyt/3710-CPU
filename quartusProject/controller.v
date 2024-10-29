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
     output reg [2:0] alu_operation,

     output reg program_counter_write_enable,

     output reg status_write_enable,

     input [3:0] instruction_operation,
     input [3:0] instruction_operation_extra,
     output reg instruction_write_enable,
     
     output reg register_write_enable,
     output reg [1:0] register_write_data_select,

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
    parameter FETCH = 5'b00000;
    parameter DECODE = 5'b00001;
    parameter EXECUTE_ADD = 5'b00010;
    parameter EXECUTE_ADDI = 5'b00011;
    parameter EXECUTE_SUB = 5'b00100;
    parameter EXECUTE_SUBI = 5'b00110;
    parameter EXECUTE_CMP = 5'b00111;
    parameter EXECUTE_CMPI = 5'b01000;
    parameter EXECUTE_AND = 5'b01001;
    parameter EXECUTE_ANDI = 5'b01010;
    parameter EXECUTE_OR = 5'b01011;
    parameter EXECUTE_ORI = 5'b01100;
    parameter EXECUTE_XOR = 5'b01101;
    parameter EXECUTE_XORI = 5'b01110;
    parameter EXECUTE_MOV = 5'b01111;
    parameter EXECUTE_MOVI = 5'b10000;
    parameter WRITE = 5'b00101;

    parameter ALU_A_PROGRAM_COUNTER = 2'b00;
    parameter ALU_A_SOURCE = 2'b01;
    parameter ALU_A_IMMEDIATE_SIGN_EXTENDED = 2'b10;
    parameter ALU_A_IMMEDIATE_ZERO_EXTENDED = 2'b11;

    parameter ALU_B_DESTINATION = 1'b0;
    parameter ALU_B_CONSTANT_ONE = 1'b1;

    parameter REGISTER_WRITE_ALU_D = 2'b00;
    parameter REGISTER_WRITE_SOURCE = 2'b01;
    parameter REGISTER_WRITE_IMMEDIATE_ZERO_EXTENDED = 2'b10;

    parameter ADD = 3'b000;
    parameter SUBTRACT = 3'b001;
    parameter COMPARE = 3'b010;
    parameter AND = 3'b011;
    parameter OR = 3'b100;
    parameter XOR = 3'b101;

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
                                        OPERATION_EXTRA_CMP: next_state <= EXECUTE_CMP;
                                        OPERATION_EXTRA_AND: next_state <= EXECUTE_AND;
                                        OPERATION_EXTRA_OR: next_state <= EXECUTE_OR;
                                        OPERATION_EXTRA_XOR: next_state <= EXECUTE_XOR;
                                        OPERATION_EXTRA_MOV: next_state <= EXECUTE_MOV;
                                        // TODO
                                    endcase
                                end
                            OPERATION_ADDI: next_state <= EXECUTE_ADDI;
                            OPERATION_SUBI: next_state <= EXECUTE_SUBI;
                            OPERATION_CMPI: next_state <= EXECUTE_CMPI;
                            OPERATION_ANDI: next_state <= EXECUTE_ANDI;
                            OPERATION_ORI: next_state <= EXECUTE_ORI;
                            OPERATION_XORI: next_state <= EXECUTE_XORI;
                            OPERATION_MOVI: next_state <= EXECUTE_MOVI;
                        endcase
                    end
                EXECUTE_ADD: next_state <= WRITE;
                EXECUTE_SUB: next_state <= WRITE;
                EXECUTE_ADDI: next_state <= WRITE;
                EXECUTE_SUBI: next_state <= WRITE;
                // TODO: Does this work cleanly? Just not do anything after executing?
                EXECUTE_CMP: next_state <= FETCH;
                EXECUTE_CMPI: next_state <= FETCH;
                EXECUTE_AND: next_state <= WRITE;
                EXECUTE_ANDI: next_state <= WRITE;
                EXECUTE_OR: next_state <= WRITE;
                EXECUTE_ORI: next_state <= WRITE;
                EXECUTE_XOR: next_state <= WRITE;
                EXECUTE_XORI: next_state <= WRITE;
                EXECUTE_MOV: next_state <= FETCH;
                EXECUTE_MOVI: next_state <= FETCH;
                WRITE: next_state <= FETCH;
            endcase
        end

    // TODO: Output combinational logic
    always @(*)
        begin
            // Defaults:
            instruction_write_enable <= 0;
            status_write_enable <= 0;
            program_counter_write_enable <= 0;
            register_write_enable <= 0;
            register_write_data_select <= REGISTER_WRITE_ALU_D;
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
                        status_write_enable <= 1;
                    end
                EXECUTE_ADDI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_SIGN_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= ADD;
                        status_write_enable <= 1;
                    end
                EXECUTE_SUB:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= SUBTRACT;
                        status_write_enable <= 1;
                    end
                EXECUTE_SUBI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_SIGN_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= SUBTRACT;
                        status_write_enable <= 1;
                    end
                EXECUTE_CMP:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= COMPARE;
                        status_write_enable <= 1;
                    end
                EXECUTE_CMPI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_SIGN_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= COMPARE;
                        status_write_enable <= 1;
                    end
                EXECUTE_AND:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= AND;
                    end
                EXECUTE_ANDI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_ZERO_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= AND;
                    end
                EXECUTE_OR:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= OR;
                    end
                EXECUTE_ORI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_ZERO_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= OR;
                    end
                EXECUTE_XOR:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= XOR;
                    end
                EXECUTE_XORI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_ZERO_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= XOR;
                    end
                EXECUTE_MOV:
                    begin
                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_SOURCE;
                    end
                EXECUTE_MOVI:
                    begin
                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_IMMEDIATE_ZERO_EXTENDED;
                    end
                WRITE:
                    begin
                        register_write_enable <= 1;
                    end
            endcase
        end
endmodule
