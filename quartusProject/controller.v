// Controller
//
// TODO:
module controller 
    (input clock, reset,

     output reg [1:0] alu_a_select, 
     output reg [1:0] alu_b_select,
     output reg [2:0] alu_operation,

     output reg program_counter_write_enable,
     // TODO: How many do we need?
     output reg program_counter_select,

     output reg status_write_enable,

     input [3:0] instruction_operation,
     input [3:0] instruction_operation_extra,
     output reg instruction_write_enable,
     
     output reg register_write_enable,
     output reg [2:0] register_write_data_select,

     output reg data_write_enable,
     output reg data_address_select,

     // TODO
     output reg instruction_address_select
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
    parameter OPERATION_LSH = 4'b1000;
    parameter OPERATION_SUBI = 4'b1001;
    parameter OPERATION_SUBCI = 4'b1010; // Unimplemented
    parameter OPERATION_CMPI = 4'b1011;
    parameter OPERATION_BCOND = 4'b1100;
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
    parameter OPERATION_EXTRA_LSHI_LEFT = 4'b0000;
    parameter OPERATION_EXTRA_LSHI_TWO = 4'b0001;
    parameter OPERATION_EXTRA_LOAD = 4'b0000;
    parameter OPERATION_EXTRA_STOR = 4'b0100;
    parameter OPERATION_EXTRA_JCOND = 4'b1100;
    parameter OPERATION_EXTRA_JAL = 4'b1000;

    parameter FETCH         = 5'd0;
    parameter DECODE        = 5'd1;
    parameter EXECUTE_ADD   = 5'd2;
    parameter EXECUTE_ADDI  = 5'd3;
    parameter EXECUTE_SUB   = 5'd4;
    parameter EXECUTE_SUBI  = 5'd5;
    parameter EXECUTE_CMP   = 5'd6;
    parameter EXECUTE_CMPI  = 5'd7;
    parameter EXECUTE_AND   = 5'd8;
    parameter EXECUTE_ANDI  = 5'd9;
    parameter EXECUTE_OR    = 5'd10;
    parameter EXECUTE_ORI   = 5'd11;
    parameter EXECUTE_XOR   = 5'd12;
    parameter EXECUTE_XORI  = 5'd13;
    parameter EXECUTE_MOV   = 5'd14;
    parameter EXECUTE_MOVI  = 5'd15;
    parameter EXECUTE_LSH   = 5'd16;
    parameter EXECUTE_LSHI  = 5'd17;
    parameter EXECUTE_LUI   = 5'd18;
    parameter EXECUTE_LOAD  = 5'd19;
    parameter EXECUTE_STOR  = 5'd20;
    parameter EXECUTE_BCOND = 5'd21;
    parameter EXECUTE_NOTHING = 5'd31;

    parameter ALU_A_PROGRAM_COUNTER = 2'b00;
    parameter ALU_A_SOURCE = 2'b01;
    parameter ALU_A_IMMEDIATE_SIGN_EXTENDED = 2'b10;
    parameter ALU_A_IMMEDIATE_ZERO_EXTENDED = 2'b11;

    parameter ALU_B_DESTINATION = 2'b00;
    parameter ALU_B_CONSTANT_ONE = 2'b01;
    parameter ALU_B_IMMEDIATE_SIGN_EXTENDED_COND = 2'b10;

    parameter REGISTER_WRITE_ALU_D = 3'b000;
    parameter REGISTER_WRITE_SOURCE = 3'b001;
    parameter REGISTER_WRITE_IMMEDIATE_ZERO_EXTENDED = 3'b010;
    parameter REGISTER_WRITE_IMMEDIATE_UPPER = 3'b011;
    parameter REGISTER_WRITE_DATA_READ_DATA = 3'b100;

    parameter INSTRUCTION_ADDRESS_PROGRAM_COUNTER = 1'b0;
    parameter INSTRUCTION_ADDRESS_SOURCE = 1'b1;

    parameter DATA_ADDRESS_PROGRAM_COUNTER = 1'b0;
    parameter DATA_ADDRESS_SOURCE = 1'b1;

    parameter PROGRAM_COUNTER_INCREMENT = 1'b0;
    parameter PROGRAM_COUNTER_ALU_D = 1'b1;

    parameter ADD = 3'b000;
    parameter SUBTRACT = 3'b001;
    parameter COMPARE = 3'b010;
    parameter AND = 3'b011;
    parameter OR = 3'b100;
    parameter XOR = 3'b101;
    parameter SHIFT = 3'b110;

    reg [4:0] state, state_next;

    always @(posedge clock)
        if (~reset) state <= FETCH;
        else state <= state_next;

    // TODO: Next state logic
    always @(*)
        begin
            case (state)
                FETCH: state_next <= DECODE;
                DECODE:
                    begin
                        case (instruction_operation)
                            OPERATION_RTYPE:
                                begin
                                    case (instruction_operation_extra)
                                        OPERATION_EXTRA_ADD: state_next <= EXECUTE_ADD;
                                        OPERATION_EXTRA_SUB: state_next <= EXECUTE_SUB;
                                        OPERATION_EXTRA_CMP: state_next <= EXECUTE_CMP;
                                        OPERATION_EXTRA_AND: state_next <= EXECUTE_AND;
                                        OPERATION_EXTRA_OR: state_next <= EXECUTE_OR;
                                        OPERATION_EXTRA_XOR: state_next <= EXECUTE_XOR;
                                        OPERATION_EXTRA_MOV: state_next <= EXECUTE_MOV;
                                        default: state_next <= FETCH;
                                    endcase
                                end
                            OPERATION_ADDI: state_next <= EXECUTE_ADDI;
                            OPERATION_SUBI: state_next <= EXECUTE_SUBI;
                            OPERATION_CMPI: state_next <= EXECUTE_CMPI;
                            OPERATION_ANDI: state_next <= EXECUTE_ANDI;
                            OPERATION_ORI: state_next <= EXECUTE_ORI;
                            OPERATION_XORI: state_next <= EXECUTE_XORI;
                            OPERATION_MOVI: state_next <= EXECUTE_MOVI;
                            OPERATION_LSH:
                                case (instruction_operation_extra)
                                    OPERATION_EXTRA_LSH: state_next <= EXECUTE_LSH;
                                    // TODO:
                                    OPERATION_EXTRA_LSHI_LEFT: state_next <= EXECUTE_LSHI;
                                    OPERATION_EXTRA_LSHI_TWO: state_next <= EXECUTE_LSHI;
                                    default: state_next <= FETCH;
                                endcase
                            OPERATION_LUI: state_next <= EXECUTE_LUI;
                            OPERATION_MEMORY:
                                case (instruction_operation_extra)
                                    OPERATION_EXTRA_LOAD: state_next <= EXECUTE_LOAD;
                                    OPERATION_EXTRA_STOR: state_next <= EXECUTE_STOR;
                                    default: state_next <= FETCH;
                                endcase
                            OPERATION_BCOND: state_next <= EXECUTE_BCOND;
                            default: state_next <= FETCH;
                        endcase
                    end
                EXECUTE_ADD: state_next <= EXECUTE_NOTHING;
                EXECUTE_SUB: state_next <= FETCH;
                EXECUTE_ADDI: state_next <= EXECUTE_NOTHING;
                EXECUTE_SUBI: state_next <= FETCH;
                EXECUTE_CMP: state_next <= FETCH;
                EXECUTE_CMPI: state_next <= EXECUTE_NOTHING;
                EXECUTE_AND: state_next <= FETCH;
                EXECUTE_ANDI: state_next <= FETCH;
                EXECUTE_OR: state_next <= FETCH;
                EXECUTE_ORI: state_next <= FETCH;
                EXECUTE_XOR: state_next <= FETCH;
                EXECUTE_XORI: state_next <= FETCH;
                EXECUTE_MOV: state_next <= FETCH;
                EXECUTE_MOVI: state_next <= EXECUTE_NOTHING;
                EXECUTE_LSH: state_next <= FETCH;
                EXECUTE_LSHI: state_next <= FETCH;
                EXECUTE_LUI: state_next <= FETCH;
                EXECUTE_LOAD: state_next <= EXECUTE_NOTHING;
                EXECUTE_STOR: state_next <= FETCH;
                EXECUTE_BCOND: state_next <= EXECUTE_NOTHING;
                EXECUTE_NOTHING: state_next <= FETCH;
                default: state_next <= FETCH;
            endcase
        end

    // TODO: Output combinational logic
    always @(*)
        begin
            alu_a_select <= 0;
            alu_b_select <= 0;
            alu_operation <= 0;

            // TODO?
            program_counter_write_enable <= 1;
            // Should just happen as a part of mux b input selection
            program_counter_select <= PROGRAM_COUNTER_INCREMENT;

            status_write_enable <= 0;

            instruction_write_enable <= 0;

            register_write_enable <= 0;
            register_write_data_select <= REGISTER_WRITE_ALU_D;

            instruction_address_select <= INSTRUCTION_ADDRESS_PROGRAM_COUNTER;

            data_write_enable <= 0;
            data_address_select <= DATA_ADDRESS_PROGRAM_COUNTER;

            case (state)
                FETCH:
                    begin
                        instruction_write_enable <= 1;
                        program_counter_write_enable <= 0;
                    end
                DECODE:
                    begin
                        program_counter_write_enable <= 0;
                    end
                EXECUTE_ADD:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= ADD;

                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_ALU_D;
                        // TODO: Why does status write occur? Probably in writeback
                        // status_write_enable <= 1;
                    end
                EXECUTE_ADDI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_SIGN_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= ADD;

                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_ALU_D;
                        // TODO:
                        // status_write_enable <= 1;
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
                EXECUTE_LSH:
                    begin
                        // TODO: Modify to only accept lower 4 bits?
                        // See comment in LSH spec
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= SHIFT;
                    end
                EXECUTE_LSHI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_ZERO_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= SHIFT;
                    end
                EXECUTE_LUI:
                    begin
                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_IMMEDIATE_UPPER;
                    end
                EXECUTE_LOAD:
                    begin
                        // TODO: Might not work?
                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_DATA_READ_DATA;
                        data_address_select <= DATA_ADDRESS_SOURCE;
                    end
                EXECUTE_STOR:
                    begin
                        data_address_select <= DATA_ADDRESS_SOURCE;
                        data_write_enable <= 1;
                    end
                EXECUTE_BCOND:
                    begin
                        alu_a_select <= ALU_A_PROGRAM_COUNTER;
                        alu_b_select <= ALU_B_IMMEDIATE_SIGN_EXTENDED_COND;
                        alu_operation <= ADD;
                        program_counter_write_enable <= 1;
                        program_counter_select <= PROGRAM_COUNTER_ALU_D;
                    end
                EXECUTE_NOTHING:
                    begin
                        program_counter_write_enable <= 0;
                    end
            endcase
        end
endmodule
