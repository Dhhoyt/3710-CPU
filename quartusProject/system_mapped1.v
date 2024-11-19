module system_mapped1
    (input clock, reset,
     input [15:0] switches,
     output [15:0] leds);
    
    wire [15:0] memory_read_data;
    wire memory_write_enable;
    wire [15:0] memory_address;
    wire [15:0] memory_write_data;

    wire [15:0] leds_dummy;
    
    cpu cpu1(clock, reset, 
             memory_read_data, memory_write_enable, memory_address, memory_write_data);
    data_memory_mapped1 data_memory(clock, switches, 
                                    memory_write_data, memory_address,
                                    memory_write_enable, memory_read_data, 
                                    leds_dummy);

    assign leds = leds_dummy;
endmodule
