/*
 Datapath for a 3-stage, non-pipelined, 16-bit CR16 CPU.

 The datapath takes as input the control lines from the controller
 module and memory read data, modifies internal state, and returns a
 memory address, memory write data, and the current value of the
 instruction register as output.  
 
 Internal state consists of program counter, instruction register,
 status register, for which there are corresponding flip-flop
 registers with reset and enable signals.
 */
module datapath 
    (input clock, reset,
     
     input [1:0] alu_a_select,
     input [1:0] alu_b_select,
     input [2:0] alu_operation,
     
     input program_counter_write_enable,
     input [1:0] program_counter_select,
     
     input status_write_enable,
     
     input instruction_write_enable,
     output [15:0] instruction,
     
     input register_write_enable,
     input [3:0] register_write_data_select,
     
     input raycast_write_enable,
     input [3:0] raycast_write_select,
     
     input [15:0] memory_read_data,
     input [1:0] memory_address_select,
     input [2:0] memory_offset,
     output [15:0] memory_address,
     output [15:0] memory_write_data);

    // ALU input `a` mux selectors
    parameter ALU_A_PROGRAM_COUNTER = 3'b000;
    parameter ALU_A_SOURCE = 3'b001;
    parameter ALU_A_IMMEDIATE_SIGN_EXTENDED = 3'b010;
    parameter ALU_A_IMMEDIATE_ZERO_EXTENDED = 3'b011;
    parameter ALU_A_SHIFT_SOURCE = 3'b100;
    parameter ALU_A_SHIFT_IMMEDIATE = 3'b101;
    
    // ALU input `b` mux selectors
    parameter ALU_B_DESTINATION = 1'b0;
    parameter ALU_B_CONSTANT_ONE = 1'b1;

    // Condition codes
    parameter EQ = 4'b0000;
    parameter NE = 4'b0001;
    parameter GE = 4'b1101;
    parameter CC = 4'b0011;
    parameter HI = 4'b0100;
    parameter LS = 4'b0101;
    parameter LO = 4'b1010;
    parameter HS = 4'b1011;
    parameter GT = 4'b0110;
    parameter LE = 4'b0111;
    parameter FS = 4'b1000;
    parameter FC = 4'b1001;
    parameter LT = 4'b1100;
    parameter UC = 4'b1110;
    parameter IT = 4'b1111;
    
    // Flag bit indexes in the status register
    parameter ZERO = 4'd6;
    parameter NEGATIVE = 4'd7;
    parameter LOW = 4'd2;
    parameter FLAG = 4'd5;
    parameter CARRY = 4'd0;
    
    localparam CONSTANT_ONE =  16'b1;
    
    wire [15:0] program_counter;
    wire [15:0] program_counter_next, 
                alu_a, alu_b, alu_d, 
                source, destination, register_write_data,
                status;
    wire [15:0] sin_value, cos_value;
    wire [15:0] distance, tuvx;
    wire intersection;
    reg condition;
    reg [15:0] raycast_register[8:0];
    // Instruction decoding fields
    wire [3:0] register_address_destination = instruction[11:8];
    wire [3:0] register_address_source = instruction[3:0];
    wire [7:0] immediate = instruction[7:0];
    wire [15:0] immediate_sign_extended = { {8{immediate[7]}}, immediate };
    wire [15:0] immediate_zero_extended = { 8'h00, immediate };
    wire [15:0] immediate_upper = { immediate, destination[7:0] };
    // ALU flags
    wire negative, zero, flag, low, carry;
    // Condition, combinational logic based on flags
    wire [15:0] immediate_sign_extended_condition = condition ? immediate_sign_extended : 16'd1;
    // TODO: Better names
    wire [15:0] source_condition = condition ? source : 16'b0;
    wire [15:0] program_counter_increment = program_counter + 16'd1;
    wire [15:0] program_counter_condition = condition ? source : program_counter_increment;
    wire [15:0] destination_with_offset = destination + memory_offset;												
    
    // Flip-flop registers with enable and reset signals for holding datapath internal state
    flop_enable_reset #(16) program_counter_register
        (clock, reset, program_counter_write_enable, program_counter_next, program_counter);
    flop_enable_reset #(16) instruction_register
        (clock, reset, instruction_write_enable, memory_read_data, instruction);
    flop_enable_reset #(16) status_register
        (clock, reset, status_write_enable, 
         { 4'b0, // Reserved
           4'b0, // I, P, E, 0
           negative,
           zero,
           flag,
           2'b0, // 0
           low, 
           1'b0, // T
           carry },
         status);

    // Muxes for controlling inputs to program counter register, alu
    // `a` and `b` inputs, register write data, and memory address
    // output
    mux4 #(16) program_counter_mux(program_counter_increment, alu_d, 
                                   program_counter_condition, program_counter_condition,
                                   program_counter_select, program_counter_next);
    mux4 #(16) alu_a_mux(program_counter, source, immediate_sign_extended, immediate_zero_extended,
                         alu_a_select, alu_a);
    mux4 #(16) alu_b_mux(destination, CONSTANT_ONE, immediate_sign_extended_condition, source_condition,
                         alu_b_select, alu_b);
    mux16 #(16) register_write_data_mux(alu_d, source, immediate_zero_extended, immediate_upper,
                                        memory_read_data, program_counter_increment, sin_value, cos_value,
                                        distance, tuvx, 16'd0, 16'd0,
                                        register_write_data_select, register_write_data);
    mux4 #(16) memory_address_select_mux(program_counter, source, 
					 destination_with_offset, destination_with_offset,
                                         memory_address_select, 
                                         memory_address);

    assign memory_write_data = destination;

    // Set `condition` according to the contents of the status register
    always @(*) begin
        case (register_address_destination)
            EQ: condition <= status[ZERO];
            NE: condition <= !status[ZERO];
            GE: condition <= status[NEGATIVE] || status[ZERO];
            CC: condition <= status[CARRY];
            HI: condition <= !status[CARRY];
            LS: condition <= status[LOW];
            LO: condition <= !status[LOW];
            HS: condition <= !status[LOW] && !status[ZERO];
            GT: condition <= status[NEGATIVE];
            LE: condition <= !status[NEGATIVE];
            FS: condition <= status[FLAG];
            FC: condition <= !status[FLAG];
            LT: condition <= !status[NEGATIVE] && !status[ZERO];
	    FC: condition <= !status[FLAG];
	    IT: condition <= intersection;
            UC: condition <= 1'b1;
            default: condition <= 1'b0;
        endcase
    end

    alu alu1(alu_a, alu_b, alu_operation, alu_d,
             carry, low, flag, zero, negative);
    sin_cos trig_unit(.angle(destination), .sine(sin_value), .cosine(cos_value));
    // Read `a` and `b` are source and destination fields and write is
    // always destination field
    register_file register_file1
        (clock, register_write_enable,
         register_address_source,
         register_address_destination,
         register_address_destination,
         register_write_data, 
         source, destination);
	  
    always @ (posedge clock) begin
	if (raycast_write_enable) begin
	    case (raycast_write_select)
		4'b0000: begin raycast_register[0] <= destination; raycast_register[1] <= source; end
		4'b0001: begin raycast_register[0] <= destination; raycast_register[1] <= source; end
		4'b0010: begin raycast_register[2] <= destination; raycast_register[3] <= source; end
		4'b0011: begin raycast_register[2] <= destination; raycast_register[3] <= source; end
		4'b0100: raycast_register[4] <= memory_read_data;
		4'b0101: raycast_register[5] <= memory_read_data;
		4'b0110: raycast_register[6] <= memory_read_data;
		4'b0111: raycast_register[7] <= memory_read_data;
		4'b1000: raycast_register[8] <= memory_read_data;	
	    endcase
	end
    end
	  
    rayCast rc(raycast_register[0], raycast_register[1], 
	       raycast_register[2], raycast_register[3], 
	       raycast_register[4], raycast_register[5], 
	       raycast_register[6], raycast_register[7],
	       raycast_register[8],
	       intersection,
	       distance, tuvx);
endmodule

/* 
 Arithmetic and Logic Unit.
 
 Perform the operation `f` on inputs `a` and `b`, returning 
 `d = f(a, b)`. Also set status flags according to `a`, `b`, and `d`.
 */
module alu
    (input [15:0] a, b,
     input [2:0] f,
     output reg [15:0] d,
     // Flags:
     output reg carry, output reg low, output reg flag, output reg zero, output reg negative
);

    parameter ADD = 3'b000;
    parameter SUBTRACT = 3'b001;
    parameter COMPARE = 3'b010;
    parameter AND = 3'b011;
    parameter OR = 3'b100;
    parameter XOR = 3'b101;
    parameter SHIFT = 3'b110;
    parameter MULTIPLY = 3'b111;

    reg [16:0] t; // Temporary
    reg [31:0] m; // Intermediate multiplication result

    // For carry/borrow detection
    wire [16:0] ae = {1'b0, a}; // 1-bit extended a and b so that we can get signed bit from the result
    wire [16:0] be = {1'b0, b};
    wire overflow_detect = (a[15] == b[15]) && (d[15] != a[15]);

    always @(*)
        begin
            // Set defaults so that logic is combinational
            carry <= 0; 
            low <= 0; 
            flag <= 0;
            zero <= 0; 
            negative <= 0;
            m = 0; 
            t = 0;
            
            case (f)
                ADD: 
                    begin
                        t = ae + be;
                        d = t[15:0];
                        // TODO: Mixing <= and =?
                        carry <= t[16];
                        flag <= overflow_detect;
                        zero <= (d == 16'b0);
                    end
                SUBTRACT: 
                    begin
                        t = ae - be;
                        d = t[15:0];
                        carry <= t[16];
                        flag <= ~overflow_detect;
                        zero <= (d == 16'b0);
                    end
                COMPARE:
                    begin
                        t = ae - be;
                        d = t[15:0];
                        zero <= (a == b);
                        low <= (a < b);
                        negative <= ($signed(a) < $signed(b));
                    end
                AND:
                    begin
                        d <= a & b;
                    end
                OR:
                    begin
                        d <= a | b;
                    end
                XOR:
                    begin
                        d <= a ^ b;
                    end
                SHIFT:
                    begin
                        d <= a[0] ? b << 1 : b >> 1;
                    end
                MULTIPLY:
                    begin
                        m = $signed(a) * $signed(b);
                        d = m[23:8];
                    end
                default:
                    begin
                        d <= 0;
                    end
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

    // Initialize registers to zero
    integer i;
    initial begin
        for (i = 0; i < 16; i = i+1) registers[i] = 0;
    end

    always @(posedge clock)
        if (write_enable) registers[write_address] <= write_data;

    assign read_data1 = registers[read_address1];
    assign read_data2 = registers[read_address2];
endmodule
