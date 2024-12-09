module test4;
    reg reset;
	 
	 // Testbench uses a 50 MHz clock
	// Want to interface to 9600 baud UART
	// 50000000 / 9600 = 5208 Clocks Per Bit.
	parameter c_CLOCK_PERIOD_NS = 20000;
	parameter BAUD_RATE         = 9600;
	parameter c_BIT_PERIOD      = 104166667;
	
	reg r_Clock = 0;
	reg r_Tx_DV = 0;
	wire w_Tx_Done;
	reg r_Rx_Serial;

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


	 
	system_mapped1 sm(
		.clock(r_Clock), .reset(reset),
		.rx(r_Rx_Serial)
	);
	  
    always
		#(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;

    initial begin
        reset = 1'b0;
		r_Rx_Serial <= 1'b1;

		#(c_CLOCK_PERIOD_NS * 5);

        reset = 1'b1;

		forever begin
			// Send a command to the UART (exercise Rx)
			@(posedge r_Clock);
			UART_WRITE_BYTE(8'h00);
			@(posedge r_Clock);

			#(c_CLOCK_PERIOD_NS * 100);
			
			@(posedge r_Clock);
			UART_WRITE_BYTE(8'hff);
			@(posedge r_Clock);

			#(c_CLOCK_PERIOD_NS * 100);
		end
	end
endmodule
