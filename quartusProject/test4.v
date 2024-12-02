module test4;
    reg clock, reset;
	 reg [15:0] switches;
	 
	 reg rx;
	 
	 // Testbench uses a 50 MHz clock
	// Want to interface to 9600 baud UART
	// 50000000 / 9600 = 5208 Clocks Per Bit.
	parameter c_CLOCK_PERIOD_NS = 20000;
	parameter BAUD_RATE         = 9600;
	parameter c_BIT_PERIOD      = 104166667;
	
	// Takes in input byte and serializes it 
	task UART_WRITE_BYTE;
		input [7:0] i_Data;
		integer     ii;
		begin
			 
			// Send Start Bit
			r_Rx_Serial <= 1'b0;
			#(c_BIT_PERIOD);
			//#1000; // what ???
			 
			 
			// Send Data Byte
			for (ii=0; ii<8; ii=ii+1)
				begin
					r_Rx_Serial <= i_Data[ii];
					#(c_BIT_PERIOD);
				end
			 
			// Send Stop Bit
			r_Rx_Serial <= 1'b1;
			#(c_BIT_PERIOD);
		 end
	endtask // UART_WRITE_BYTE

	reg r_Clock = 0;
	reg r_Tx_DV = 0;
	wire w_Tx_Done;
	reg r_Rx_Serial;
	wire [7:0] w_Rx_Byte;
	 
	 system_mapped1 sm(
	   .clock(clock), .reset(reset),
		.rx(rx)
	  );
	  
    initial begin
		 clock = 1'b0;
       forever #1 clock = ~clock;
    end

    initial begin
        reset = 1'b0;
        #20;
        reset = 1'b1;
   end
endmodule
