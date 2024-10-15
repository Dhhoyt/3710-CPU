module attemptSubtractionTB;
    reg [15:0] dividend, divisor;
    wire [15:0] quotient;

    attemptSubtractDivision asd(.dividend(dividend), .divisor(divisor), .quotient(quotient));
    initial begin
        dividend = 16'b0000111100000000;
        divisor  = 16'b0000000100000000;
        #5000
        $display("Dividened: %h, Divisor: %h, Quotient: %h", dividend, divisor, quotient);
    end
endmodule