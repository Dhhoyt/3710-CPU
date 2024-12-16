module clockDivider #(parameter DIVISIONS = 1, parameter INITIAL_VALUE = 0)(
    input wire clk,
	input wire clr,
    output wire divided_clk
);


reg [$clog2(DIVISIONS): 0] counter;

assign divided_clk = counter == 0;

always @ (posedge clk) begin
	if (~clr) begin
		counter = INITIAL_VALUE;
	end else begin
		counter = counter + 1;
		if (counter >= DIVISIONS) begin
			counter = 0;
		end
	end
end

endmodule
