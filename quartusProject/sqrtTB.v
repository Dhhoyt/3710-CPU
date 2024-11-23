module tb_sqrt;

  // Define inputs and outputs
  reg [15:0] x;
  wire [15:0] res;

  // Instantiate the sqrt module
  sqrt sqrt_inst (
    .x(x),
    .res(res)
  );

  // Task to print out x and res in hex format
  initial begin

    // Run through every 16-bit number
    for (x = 16'h0000; x < 16'hFFFF; x = x + 1) begin
      #1; // Small delay to allow for any module delays
      $display("%h\t%h", x, res);
    end

    // Display last value
    x = 16'hFFFF;
    #1;
    $display("%h\t%h", x, res);

    $finish;
  end

endmodule