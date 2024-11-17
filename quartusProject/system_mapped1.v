module system_mapped1
    (input clock, reset,
     input [15:0] switches,
     output [15:0] leds);
    
    wire [15:0] data_read_data;
    wire data_write_enable;
    wire [15:0] data_address;
    wire [15:0] data_write_data;
    
    wire [15:0] instruction_read_data;
    wire [15:0] instruction_address;
    
    cpu cpu1(clock, reset,
             data_read_data, data_write_enable, data_address, data_write_data,
             instruction_read_data, instruction_address);
    instruction_memory #(16) instruction_memory1(clock, instruction_address, instruction_read_data);
    data_memory_mapped1 data_memory(clock, switches, data_write_data, data_address,
                                    data_write_enable, data_read_data, leds);
endmodule
