module test4;
    reg clock, reset;
	 reg [15:0] switches;
	 wire [15:0] leds;
	 
	 system_mapped1 sm(
	   .clock(clock), .reset(reset)

	  );
	  
    initial begin
		 //switches = 16'b0000000000000111;
		 clock = 1'b0;
       forever #1 clock = ~clock;
    end

    initial begin
        reset = 1'b0;
        #20;
        reset = 1'b1;
   end
endmodule
