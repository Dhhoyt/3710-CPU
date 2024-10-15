module vgaContoller(
    input wire clk,
	 input wire en,
    input wire clr,
    output wire in_display,
	 output wire above_column,
    output wire h_sync,
    output reg [9:0] column,
    output wire v_sync,
    output reg [9:0] row,
	 output reg [9:0] column_internal, // We hold this here because the blanking intervals means the pixel on screen is different from what count we're at
	 output reg [9:0] row_internal
);

// Define the constants for the vga 640x480 @ 60 hz spec
parameter h_pulse_width = 96;
parameter h_front_porch_width = 48;
parameter h_display_width = 640;
parameter h_back_porch_width = 16;

parameter h_width = h_pulse_width + h_front_porch_width + h_display_width + h_back_porch_width;

parameter v_pulse_width = 2;
parameter v_front_porch_width = 31;
parameter v_display_width = 480;
parameter v_back_porch_width = 11;

parameter v_width = v_pulse_width + v_front_porch_width + v_display_width + v_back_porch_width;


// Pulse logic
assign h_sync = column_internal >= h_pulse_width;
assign v_sync = row_internal >= v_pulse_width;


assign above_column = (column_internal < (4));
// Check if we're not in a blanking interval
wire in_display_column = (column_internal >= (h_pulse_width + h_front_porch_width)) && (column_internal < (h_width - h_back_porch_width));
wire in_display_row = (row_internal >= (v_pulse_width + v_front_porch_width)) && (row_internal < (v_width - v_back_porch_width));

assign in_display = in_display_column & in_display_row;

always @ (posedge clk) begin
    if (clr == 1'b0) begin
	     column_internal <= 0;
		  row_internal <= 0;
	 end else if (en) begin
        column_internal <= column_internal + 1; // count up
	 end
	 // Carry over
    if (column_internal >= h_width) begin
        column_internal <= 0;
        row_internal <= row_internal + 1;
    end
	 
	 // Wrap around vertical number
    if (row_internal >= v_width) begin
        row_internal <= 0;
    end
	 
	 // Set the output column and row 
    if (in_display) begin
        column = column_internal - (h_pulse_width + h_front_porch_width);
        row = row_internal - (v_pulse_width + v_front_porch_width);
    end else begin
        column <= 0;
        row = 0;
    end
end

endmodule