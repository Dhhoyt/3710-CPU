// Controller

module controller 
    (input clock, reset,

     output reg [1:0] alu_a_select, 
     output reg [1:0] alu_b_select,
     output reg [2:0] alu_operation,

     output reg program_counter_write_enable,
     output reg [1:0] program_counter_select,

     output reg status_write_enable,

     input [3:0] instruction_operation,
     input [3:0] instruction_operation_extra,
     output reg instruction_write_enable,
     
     output reg register_write_enable,
     output reg [2:0] register_write_data_select,
	  output reg [2:0] register_write_data_select_extra,

     output reg memory_write_enable,
     output reg [1:0] memory_address_select,
	  output reg [2:0] memory_offset,
	  output reg raycast_write_enable,
	  output reg [3:0] raycast_write_select
);

    parameter OPERATION_RTYPE = 4'b0000; //0
    parameter OPERATION_ANDI = 4'b0001; //1
    parameter OPERATION_ORI = 4'b0010; //2
    parameter OPERATION_XORI = 4'b0011; //3
    // TODO: Name
    parameter OPERATION_MEMORY = 4'b0100; //4
    parameter OPERATION_ADDI = 4'b0101; //5
    parameter OPERATION_ADDUI = 4'b0110; // Unimplemented 6
    parameter OPERATION_ADDCI = 4'b0111; // Unimplemented 7
    parameter OPERATION_LSH = 4'b1000; //8
    parameter OPERATION_SUBI = 4'b1001; //9
    parameter OPERATION_CMPI = 4'b1011; //11
    parameter OPERATION_BCOND = 4'b1100; //12
    parameter OPERATION_MOVI = 4'b1101; //13
    parameter OPERATION_LUI = 4'b1111; //15
	 parameter OPERATION_RAYCAST = 4'b1110; //14

    parameter OPERATION_EXTRA_ADD = 4'b0101;
    parameter OPERATION_EXTRA_MUL = 4'b1100;
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
	 parameter OPERATION_EXTRA_COS = 4'b1110; 
	 parameter OPERATION_EXTRA_SIN = 4'b1111;
	 
	 parameter OPERATION_RAYCAST_LODP = 4'b0000;
	 parameter OPERATION_RAYCAST_LODR = 4'b0001;
	 parameter OPERATION_RAYCAST_LODW = 4'b0010;
	 parameter OPERATION_RAYCAST_DIST = 4'b0011;
	 parameter OPERATION_RAYCAST_TXUV = 4'b0100;

    parameter FETCH         = 6'd0;
    parameter DECODE        = 6'd1;
    parameter EXECUTE_ADD   = 6'd2;
    parameter EXECUTE_ADDI  = 6'd3;
    parameter EXECUTE_SUB   = 6'd4;
    parameter EXECUTE_SUBI  = 6'd5;
    parameter EXECUTE_CMP   = 6'd6;
    parameter EXECUTE_CMPI  = 6'd7;
    parameter EXECUTE_AND   = 6'd8;
    parameter EXECUTE_ANDI  = 6'd9;
    parameter EXECUTE_OR    = 6'd10;
    parameter EXECUTE_ORI   = 6'd11;
    parameter EXECUTE_XOR   = 6'd12;
    parameter EXECUTE_XORI  = 6'd13;
    parameter EXECUTE_MOV   = 6'd14;
    parameter EXECUTE_MOVI  = 6'd15;
    parameter EXECUTE_LSH   = 6'd16;
    parameter EXECUTE_LSHI  = 6'd17;
    parameter EXECUTE_LUI   = 6'd18;
    parameter EXECUTE_LOAD  = 6'd19;
    parameter EXECUTE_STOR  = 6'd20;
    parameter EXECUTE_BCOND = 6'd21;
    parameter EXECUTE_JCOND = 6'd22;
    parameter EXECUTE_JAL   = 6'd23;
	 parameter EXECUTE_SIN   = 6'd24;
	 parameter EXECUTE_COS   = 6'd25;
	 parameter EXECUTE_LODP  = 6'd26;
	 parameter EXECUTE_LODR  = 6'd28;
	 parameter EXECUTE_LODW1 = 6'd30;
	 parameter EXECUTE_LODW2 = 6'd31;
	 parameter EXECUTE_LODW3 = 6'd32;
	 parameter EXECUTE_LODW4 = 6'd33;
	 parameter EXECUTE_LODW5 = 6'd34;
	 parameter EXECUTE_DIST  = 6'd35;
	 parameter EXECUTE_TXUV  = 6'd36;
     parameter EXECUTE_MUL   = 6'd37;
	 
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
    parameter REGISTER_WRITE_PROGRAM_COUNTER_NEXT = 3'b101;
	 parameter REGISTER_WRITE_EXTRA = 3'b111;
	 
	 parameter REGISTER_WRITE_EXTRA_SIN = 3'b000;
	 parameter REGISTER_WRITE_EXTRA_COS = 3'b001;
	 parameter REGISTER_WRITE_EXTRA_DIST = 3'b010;
	 parameter REGISTER_WRITE_EXTRA_TXUV = 3'b011;

    parameter MEMORY_ADDRESS_PROGRAM_COUNTER = 2'b00;
    parameter MEMORY_ADDRESS_SOURCE = 2'b01;
	 parameter MEMORY_ADDRESS_DEST = 2'b10;

    parameter PROGRAM_COUNTER_INCREMENT = 2'b00;
    parameter PROGRAM_COUNTER_ALU_D = 2'b01;
    parameter PROGRAM_COUNTER_CONDITION = 2'b10;
    parameter PROGRAM_COUNTER_SOURCE = 2'b11;

    parameter ADD = 3'b000;
    parameter SUBTRACT = 3'b001;
    parameter COMPARE = 3'b010;
    parameter AND = 3'b011;
    parameter OR = 3'b100;
    parameter XOR = 3'b101;
    parameter SHIFT = 3'b110;
    parameter MULTIPLY = 3'b111;
	 
	 parameter X1 = 3'b110;
	 parameter Y1 = 3'b110;
	 parameter X2 = 3'b110;
	 parameter Y2 = 3'b110;
	 parameter X3 = 3'b110;
	 parameter Y3 = 3'b110;
	 parameter X4 = 3'b110;
	 parameter Y4 = 3'b110;

    reg [5:0] state, state_next;

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
									 OPERATION_RAYCAST:
											begin
                                    case (instruction_operation_extra)
													OPERATION_RAYCAST_LODP: state_next <= EXECUTE_LODP;
													OPERATION_RAYCAST_LODR: state_next <= EXECUTE_LODR;
													OPERATION_RAYCAST_LODW: state_next <= EXECUTE_LODW1;
													OPERATION_RAYCAST_DIST: state_next <= EXECUTE_DIST;
													OPERATION_RAYCAST_TXUV: state_next <= EXECUTE_TXUV;
													default: state_next <= FETCH;
                                    endcase
                                end
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
										OPERATION_EXTRA_SIN: state_next <= EXECUTE_SIN;
										OPERATION_EXTRA_COS: state_next <= EXECUTE_COS;
                                        OPERATION_EXTRA_MUL: state_next <= EXECUTE_MUL;
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
                                    OPERATION_EXTRA_JCOND: state_next <= EXECUTE_JCOND;
                                    OPERATION_EXTRA_JAL: state_next <= EXECUTE_JAL;
                                    default: state_next <= FETCH;
                                endcase
                            OPERATION_BCOND: state_next <= EXECUTE_BCOND;
                            default: state_next <= FETCH;
                        endcase
                    end
                EXECUTE_ADD: state_next <= FETCH;
                EXECUTE_SUB: state_next <= FETCH;
                EXECUTE_ADDI: state_next <= FETCH;
                EXECUTE_SUBI: state_next <= FETCH;
                EXECUTE_CMP: state_next <= FETCH;
                EXECUTE_CMPI: state_next <= FETCH;
                EXECUTE_AND: state_next <= FETCH;
                EXECUTE_ANDI: state_next <= FETCH;
                EXECUTE_OR: state_next <= FETCH;
                EXECUTE_ORI: state_next <= FETCH;
                EXECUTE_XOR: state_next <= FETCH;
                EXECUTE_XORI: state_next <= FETCH;
                EXECUTE_MOV: state_next <= FETCH;
                EXECUTE_MOVI: state_next <= FETCH;
                EXECUTE_LSH: state_next <= FETCH;
                EXECUTE_LSHI: state_next <= FETCH;
                EXECUTE_LUI: state_next <= FETCH;
                EXECUTE_LOAD: state_next <= FETCH;
                EXECUTE_STOR: state_next <= FETCH;
                EXECUTE_BCOND: state_next <= FETCH;
                EXECUTE_JCOND: state_next <= FETCH;
                EXECUTE_JAL: state_next <= FETCH;
                EXECUTE_MUL: state_next <= FETCH;
					 
					 EXECUTE_LODP: state_next <= FETCH;
					 
					 EXECUTE_LODR: state_next <= FETCH;
					 EXECUTE_DIST: state_next <= FETCH;
					 EXECUTE_TXUV: state_next <= FETCH;
					 
					 EXECUTE_LODW1: state_next <= EXECUTE_LODW2;
					 EXECUTE_LODW2: state_next <= EXECUTE_LODW3;
					 EXECUTE_LODW3: state_next <= EXECUTE_LODW4;
					 EXECUTE_LODW4: state_next <= EXECUTE_LODW5;
					 EXECUTE_LODW5: state_next <= FETCH;
					 
                default: state_next <= FETCH;
            endcase
        end

    // TODO: Output combinational logic
    always @(*)
        begin
            alu_a_select <= 0;
            alu_b_select <= 0;
            alu_operation <= 0;

            // Because most of these are execute stages (where we
            // write to the program counter), you have to set when to
            // /not/ write to the program counter
            program_counter_write_enable <= 1;
            program_counter_select <= PROGRAM_COUNTER_INCREMENT;

            status_write_enable <= 0;

            instruction_write_enable <= 0;

            register_write_enable <= 0;
            register_write_data_select <= REGISTER_WRITE_ALU_D;
				register_write_data_select_extra <= REGISTER_WRITE_EXTRA_SIN;

            memory_write_enable <= 0;
            memory_address_select <= MEMORY_ADDRESS_PROGRAM_COUNTER;
				
				memory_offset <= 0;
				
				raycast_write_enable <= 1'b0;
				raycast_write_select <= 3'b000;


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
                        status_write_enable <= 1;
                    end
                EXECUTE_ADDI:
                    begin
                        alu_a_select <= ALU_A_IMMEDIATE_SIGN_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= ADD;

                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_ALU_D;
                        status_write_enable <= 1;
                    end
                EXECUTE_SUB:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= SUBTRACT;
								register_write_enable <= 1;
                        status_write_enable <= 1;
                    end
                EXECUTE_SUBI:
                    begin
								register_write_enable <= 1;
                        alu_a_select <= ALU_A_IMMEDIATE_SIGN_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= SUBTRACT;
                        status_write_enable <= 1;
                    end
                EXECUTE_MUL:
                    begin
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= MULTIPLY;

                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_ALU_D;
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
								register_write_enable <= 1;
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= AND;
                    end
                EXECUTE_ANDI:
                    begin
								register_write_enable <= 1;
                        alu_a_select <= ALU_A_IMMEDIATE_ZERO_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= AND;
                    end
                EXECUTE_OR:
                    begin
								register_write_enable <= 1;
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= OR;
                    end
                EXECUTE_ORI:
                    begin
								register_write_enable <= 1;
                        alu_a_select <= ALU_A_IMMEDIATE_ZERO_EXTENDED;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= OR;
                    end
                EXECUTE_XOR:
                    begin
								register_write_enable <= 1;
                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= XOR;
                    end
                EXECUTE_XORI:
                    begin
						      register_write_enable <= 1;

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
								register_write_enable <= 1;

                        alu_a_select <= ALU_A_SOURCE;
                        alu_b_select <= ALU_B_DESTINATION;
                        alu_operation <= SHIFT;
                    end
                EXECUTE_LSHI:
                    begin
						      register_write_enable <= 1;
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
                        memory_address_select <= MEMORY_ADDRESS_SOURCE;
								register_write_data_select <= REGISTER_WRITE_DATA_READ_DATA;
								register_write_enable <= 1;

                    end
                EXECUTE_STOR:
                    begin
                        memory_address_select <= MEMORY_ADDRESS_SOURCE;
                        memory_write_enable <= 1;
                    end
                EXECUTE_BCOND:
                    begin
                        alu_a_select <= ALU_A_PROGRAM_COUNTER;
                        alu_b_select <= ALU_B_IMMEDIATE_SIGN_EXTENDED_COND;
                        alu_operation <= ADD;
                        program_counter_select <= PROGRAM_COUNTER_ALU_D;
                    end
                EXECUTE_JCOND:
                    begin
                        program_counter_select <= PROGRAM_COUNTER_CONDITION;
                    end
                EXECUTE_JAL:
                    begin
                        program_counter_select <= PROGRAM_COUNTER_SOURCE;

                        register_write_enable <= 1;
                        register_write_data_select <= REGISTER_WRITE_PROGRAM_COUNTER_NEXT;
                    end
				    EXECUTE_SIN:
                    begin
								register_write_enable <= 1;
								register_write_data_select <= REGISTER_WRITE_EXTRA;
								register_write_data_select_extra <= REGISTER_WRITE_EXTRA_SIN;

                    end
					 EXECUTE_COS:
                    begin
								register_write_enable <= 1;
								register_write_data_select <= REGISTER_WRITE_EXTRA;
								register_write_data_select_extra <= REGISTER_WRITE_EXTRA_COS;

                    end
					 EXECUTE_LODP:
					     begin
						      raycast_write_enable <= 1;
								raycast_write_select <= 0;
						  end
					 EXECUTE_LODR:
					     begin
						      raycast_write_enable <= 1;
								raycast_write_select <= 2;
						  end
					 EXECUTE_LODW1:
					     begin
								raycast_write_enable <= 1;
								raycast_write_select <= 4;
								memory_offset <= 0;
								memory_address_select <= MEMORY_ADDRESS_DEST;
						  end
					 EXECUTE_LODW2:
					     begin
								raycast_write_enable <= 1;
								raycast_write_select <= 5;
								memory_offset <= 1;
								memory_address_select <= MEMORY_ADDRESS_DEST;
								program_counter_write_enable <= 0;
						  end
				    EXECUTE_LODW3:
					     begin
								raycast_write_enable <= 1;
								raycast_write_select <= 6;
								memory_offset <= 2;
								memory_address_select <= MEMORY_ADDRESS_DEST;
								program_counter_write_enable <= 0;
						  end
					 EXECUTE_LODW4:
					     begin
								raycast_write_enable <= 1;
								raycast_write_select <= 7;
								memory_offset <= 3;
								memory_address_select <= MEMORY_ADDRESS_DEST;
								program_counter_write_enable <= 0;
						  end
					 EXECUTE_LODW5: // Placeholder for the part of the instruction to laod multiple textures
					     begin
						  		raycast_write_enable <= 1;
								raycast_write_select <= 8;
								memory_offset <= 4;
								memory_address_select <= MEMORY_ADDRESS_DEST;
								program_counter_write_enable <= 0;
						  end
					 EXECUTE_DIST:
                    begin
								register_write_enable <= 1;
								register_write_data_select <= REGISTER_WRITE_EXTRA;
								register_write_data_select_extra <= REGISTER_WRITE_EXTRA_DIST;
                    end
					 EXECUTE_TXUV:
                    begin
								register_write_enable <= 1;
								register_write_data_select <= REGISTER_WRITE_EXTRA;
								register_write_data_select_extra <= REGISTER_WRITE_EXTRA_TXUV;
                    end
            endcase
        end
endmodule
