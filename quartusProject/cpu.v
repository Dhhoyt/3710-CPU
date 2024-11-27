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
	 wire [2:0] register_write_data_select_extra;


    wire [2:0] memory_address_select;
	 
	 wire raycast_write_enable;
	 wire [2:0] raycast_write_select;
	 
	 wire [2:0] memory_offset;

	controller controller1(
		 .clock(clock),
		 .reset(reset),
		 .alu_a_select(alu_a_select),
		 .alu_b_select(alu_b_select),
		 .alu_operation(alu_operation),
		 .program_counter_write_enable(program_counter_write_enable),
		 .program_counter_select(program_counter_select),
		 .status_write_enable(status_write_enable),
		 .instruction_operation(instruction[15:12]),
		 .instruction_operation_extra(instruction[7:4]),
		 .instruction_write_enable(instruction_write_enable),
		 .register_write_enable(register_write_enable),
		 .register_write_data_select(register_write_data_select),
		 .register_write_data_select_extra(register_write_data_select_extra),
		 .memory_write_enable(memory_write_enable),
		 .memory_address_select(memory_address_select),
		 .memory_offset(memory_offset),
		 .raycast_write_enable(raycast_write_enable),
		 .raycast_write_select(raycast_write_select)
	);
	
	datapath datapath1 (
		 .clock(clock),
		 .reset(reset),
		 .alu_a_select(alu_a_select),
		 .alu_b_select(alu_b_select),
		 .alu_operation(alu_operation),
		 .program_counter_write_enable(program_counter_write_enable),
		 .program_counter_select(program_counter_select),
		 .status_write_enable(status_write_enable),
		 .instruction_write_enable(instruction_write_enable),
		 .instruction(instruction),
		 .register_write_enable(register_write_enable),
		 .register_write_data_select(register_write_data_select),
		 .register_write_data_select_extra(register_write_data_select_extra),
		 .raycast_write_enable(raycast_write_enable),
		 .raycast_write_select(raycast_write_select),
		 .memory_read_data(memory_read_data),
		 .memory_address_select(memory_address_select),
		 .memory_offset(memory_offset),
		 .memory_address(memory_address),
		 .memory_write_data(memory_write_data)
	);
endmodule
