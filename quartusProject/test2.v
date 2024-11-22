module test2;
    reg clock, reset;
    wire [15:0] data_write_data, 
                data_address;
    reg [15:0] data_read_data;
    wire data_write_enable;

    cpu cpu1(clock, reset, data_read_data, data_write_enable, data_address, data_write_data);

    reg [15:0] ram[2**16-1:0];
    initial begin
        $readmemh("/home/u1242965/repositories/3710-cpu/instruction_ram.data", ram);
    end

    // Port B 
    always @(posedge clock)
	begin
	    if (data_write_enable) 
		begin
		    ram[data_address] <= data_write_data;
		    data_read_data <= data_write_data;
		end
	    else 
		begin
		    data_read_data <= ram[data_address];
		end 
	end

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        reset = 1'b0;
        #20;
        reset = 1'b1;
    end
endmodule
