
module tb_memoryMappedIO;

	reg clock, reset;
	
	reg [15:0] cpu_write_data;
	reg [15:0] cpu_address;
	reg [7:0] IOData;

	wire [15:0] cpu_read_data;

	memoryMappedIO memoryAndIO(
        clock, 
        cpu_write_data, gpu_write_data,
        cpu_address, gpu_address,
        cpu_write_enable, gpu_write_enable,
        IOData,
        cpu_read_data, gpu_read_data
    );
	 
	 always #1 clock = ~clock;
	 
	 initial begin
		 //switches = 16'b0000000000000111;
		 clock = 1'b0;
		 
		 #5 
		 IOData = 8'h45;
		 
		 #5
		 cpu_address = 0;
		 
		 #5
		 cpu_address = 1;
		 
		 #5
		 cpu_address = 65533;
		 
		 #5
		 cpu_address = 65534;
    end
	 
	 


endmodule
