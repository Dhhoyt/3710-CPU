module datapath 
    (input clock, reset,

     input [1:0] alu_a_select,
     input [1:0] alu_b_select,
     input [2:0] alu_operation,

     input program_counter_write_enable,

     input status_write_enable,

     input instruction_write_enable,
     output [15:0] instruction,

     input register_write_enable,
     input [1:0] register_write_data_select,

     input [15:0] memory_read_data,
     input memory_address_select,
     output [15:0] memory_address,
     output [15:0] memory_write_data);

    parameter ALU_A_PROGRAM_COUNTER = 3'b000;
    parameter ALU_A_SOURCE = 3'b001;
    parameter ALU_A_IMMEDIATE_SIGN_EXTENDED = 3'b010;
    parameter ALU_A_IMMEDIATE_ZERO_EXTENDED = 3'b011;
    parameter ALU_A_SHIFT_SOURCE = 3'b100;
    parameter ALU_A_SHIFT_IMMEDIATE = 3'b101;

    parameter ALU_B_DESTINATION = 1'b0;
    parameter ALU_B_CONSTANT_ONE = 1'b1;

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

    parameter ZERO = 4'd6;
    parameter NEGATIVE = 4'd7;
    parameter LOW = 4'd2;
    parameter FLAG = 4'd5;
    parameter CARRY = 4'd0;

    localparam CONSTANT_ONE =  16'b1;

    wire [15:0] program_counter, next_program_counter, 
                alu_a, alu_b, alu_d, 
                result, source, destination, register_write_data,
                immediate_sign_extended, immediate_zero_extended, immediate_upper, immediate_sign_extended_condition,
                status;
    wire [7:0] immediate;
    wire [3:0] register_address_destination, register_address_source;
    // ALU flags
    wire negative, zero, flag, low, carry;
    wire condition;

    // TODO: Will want to mux with several other things
    assign next_program_counter = alu_d;
    // TODO:
    assign memory_write_data = destination;

    // Instruction decoding fields
    assign register_address_destination = instruction[11:8];
    assign register_address_source = instruction[3:0];

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
            default: condition <= 1'b0;
        endcase
    end

    assign immediate = instruction[7:0];
    assign immediate_sign_extended = { {8{immediate[7]}}, immediate };
    assign immediate_zero_extended = { 8'h00, immediate };
    assign immediate_upper = { immediate, 8'h00 };

    assign immediate_sign_extended_condition = condition ? immediate_sign_extended : 16'b0;
    assign source_condition = condition ? source : 16'b0;

    flop_enable_reset #(16) program_counter_register
        (clock, reset, program_counter_write_enable, next_program_counter, program_counter);
    flop_enable_reset #(16) instruction_register
        (clock, reset, instruction_write_enable, memory_read_data, instruction);
    flop_reset #(16) alu_result_register
        (clock, reset, alu_d, result);
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

    mux4 #(16) alu_a_mux(program_counter, source, immediate_sign_extended, immediate_zero_extended,
                   alu_a_select, alu_a);
    mux4 #(16) alu_b_mux(destination, CONSTANT_ONE, immediate_sign_extended_condition, source_condition,
                         alu_b_select, alu_b);
    mux8 #(16) register_write_data_mux(result, source, 
                                 immediate_zero_extended, immediate_upper, 
                                 memory_read_data, memory_read_data, 
                                 memory_read_data, memory_read_data, 
                                 register_write_data_select, register_write_data);
    mux2 #(16) memory_address_select_mux(program_counter, source, memory_address_select, memory_address);

    alu alu1(alu_a, alu_b, alu_operation, alu_d,
             carry, low, flag, zero, negative);
    register_file register_file1
    (clock, register_write_enable,
     register_address_source,
     register_address_destination,
     register_address_destination,
     register_write_data, 
     source, destination);
endmodule

// Arithmetic and Logic Unit
//
// d <- o(a, b)
module alu
    (input [15:0] a, b,
     input [2:0] o,
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

    // For carry/borrow detection
    reg [16:0] t;
    wire [16:0] ae = {1'b0, a};
    wire [16:0] be = {1'b0, b};
    wire overflow_detect = (a[15] == b[15]) && (d[15] != a[15]);

    always @(*)
        begin
            carry <= 0; 
            low <= 0; 
            flag <= 0;
            zero <= 0; 
            negative <= 0;
            t = 0;

            case (o)
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

    integer i;
    initial begin
        for (i = 0; i < 16; i = i+1) registers[i] = 0;
    end

    always @(posedge clock)
        if (write_enable) registers[write_address] <= write_data;

    // Register 0 is hardwired to 0
    assign read_data1 = read_address1 ? registers[read_address1] : 16'b0;
    assign read_data2 = read_address2 ? registers[read_address2] : 16'b0;
endmodule

