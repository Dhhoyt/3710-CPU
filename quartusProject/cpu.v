module cpu
    (input clock, reset,

     input [15:0] memory_read_data,
     output memory_write_enable,
     output [15:0] memory_address,
     output [15:0] memory_write_data
);

    wire [1:0] alu_a_select;
    wire [1:0] alu_b_select;
    wire [2:0] alu_operation;

    wire program_counter_write_enable;
    wire [1:0] program_counter_select;

    wire status_write_enable;

    wire [15:0] instruction;
    wire instruction_write_enable;

    wire register_write_enable;
    wire [2:0] register_write_data_select;

    wire memory_address_select;

    controller controller1
        (clock, reset,
         alu_a_select, alu_b_select, alu_operation,
         program_counter_write_enable, program_counter_select,
         status_write_enable,
         instruction[15:12], instruction[7:4], instruction_write_enable,
         register_write_enable, register_write_data_select,
         memory_write_enable, memory_address_select);
    datapath datapath1
        (clock, reset,
         alu_a_select, alu_b_select, alu_operation,
         program_counter_write_enable, program_counter_select,
         status_write_enable,
         instruction_write_enable, instruction,
         register_write_enable, register_write_data_select,
         memory_read_data, memory_address_select, memory_address, memory_write_data);
endmodule
