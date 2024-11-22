module test1;
    reg clock, reset;
    reg [15:0] memory_read_data;
    wire       memory_write_enable;
    wire [15:0] memory_address;
    wire [15:0] memory_write_data;

    cpu cpu1(clock, reset, 
             memory_read_data, memory_write_enable,
             memory_address, memory_write_data);

    initial begin
        memory_read_data = 16'h5102;
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        reset = 1'b0;
        #22;
        reset = 1'b1;
   end
endmodule
