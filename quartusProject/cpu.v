module cpu
    (input clock, reset,

     input [15:0] memory_read_data,
     output memory_write_enable,
     output [15:0] memory_address,
     output [15:0] memory_write_data);


    wire [1:0] alu_a_select;
    wire alu_b_select;
    wire [2:0] alu_operation;

    wire program_counter_write_enable;

    wire status_write_enable;

    wire [15:0] instruction;
    wire instruction_write_enable;

    wire register_write_enable;

    controller controller1
        (clock, reset,
         alu_a_select, alu_b_select, alu_operation,
         program_counter_write_enable,
         status_write_enable,
         instruction[15:12], instruction[7:4], instruction_write_enable,
         register_write_enable,
         memory_write_enable);
    datapath datapath1
        (clock, reset,
         alu_a_select, alu_b_select, alu_operation,
         program_counter_write_enable,
         status_write_enable,
         instruction_write_enable, instruction,
         register_write_enable,
         memory_read_data, memory_address);
endmodule
