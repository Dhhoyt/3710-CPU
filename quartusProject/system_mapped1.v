// Top module

// Pulls together the CPU, GPU, UART controller, and memory
// module. Takes a receive signal for controller input and ouputs the
// relevant VGA controller signals for writing to a display.
module system_mapped1
    (input wire clock, reset,
     // Receive signal from IO Arduino
     input wire rx,
     // VGA controller signals
     output wire h_sync,
     output wire v_sync,
     output wire [7:0] red,
     output wire [7:0] green,
     output wire [7:0] blue,
     output wire vga_clock,
     output wire vga_sync,
     output wire vga_blank
     );
    
    // Memory read/write data, address, and write enable signals
    // from/to CPU and GPU
    wire [15:0] cpu_write_data, gpu_write_data;
    wire [15:0] cpu_address, gpu_address;
    wire cpu_write_enable, gpu_write_enable;
    wire [15:0] cpu_read_data, gpu_read_data;

    wire [7:0] IOData;

    cpu cpu1
        (.clock(clock), 
         .reset(reset), 
         .memory_read_data(cpu_read_data), 
         .memory_write_enable(cpu_write_enable), 
         .memory_address(cpu_address), 
         .memory_write_data(cpu_write_data)
         );
    uartrx uart(.clk50Mhz(clock),
                .portRX(rx),
                .data(IOData));
    memoryMappedIO memoryAndIO
        (clock, 
         cpu_write_data, gpu_write_data,
         cpu_address, gpu_address,
         cpu_write_enable, gpu_write_enable,
         IOData,
         cpu_read_data, gpu_read_data
         );
    GPUController gpu
        (.clk(clock),
         .clr(reset),
         .read_data(gpu_read_data),
         .write_enable(gpu_write_enable),
         .write_data(gpu_write_data),
         .read_address(gpu_address),
         .h_sync(h_sync),
         .v_sync(v_sync),
         .red(red),
         .green(green),
         .blue(blue),
         .vga_clock(vga_clock),
         .vga_sync(vga_sync),
         .vga_blank(vga_blank)
         );
endmodule
