module cpu
    (input clock, reset,

     input [15:0] data_read_data,
     output data_write_enable,
     output [15:0] data_address,
     output [15:0] data_write_data,

     input [15:0] instruction_read_data,
     output [15:0] instruction_address
);

    wire [1:0] alu_a_select;
    wire [1:0] alu_b_select;
    wire [2:0] alu_operation;

    wire program_counter_write_enable;
    wire program_counter_select;

    wire status_write_enable;

    wire [15:0] instruction;
    wire instruction_write_enable;

    wire register_write_enable;
    wire [2:0] register_write_data_select;

    wire data_address_select;

    wire instruction_address_select;

    controller controller1
        (clock, reset,
         alu_a_select, alu_b_select, alu_operation,
         program_counter_write_enable, program_counter_select,
         status_write_enable,
         instruction[15:12], instruction[7:4], instruction_write_enable,
         register_write_enable, register_write_data_select,
         data_write_enable, data_address_select,
         instruction_address_select);
    datapath datapath1
        (clock, reset,
         alu_a_select, alu_b_select, alu_operation,
         program_counter_write_enable, program_counter_select,
         status_write_enable,
         instruction_write_enable, instruction,
         register_write_enable, register_write_data_select,
         data_read_data, data_address_select, data_address, data_write_data,
         instruction_read_data, instruction_address_select, instruction_address);
endmodule
