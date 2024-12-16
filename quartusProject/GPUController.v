// Module: GPUController
// Description:
// The GPUController module serves as the control unit for a GPU system,
// interfacing with memory to load distance and texture data, manage flags,
// and drive VGA signals for visual output. The module operates as a finite
// state machine (FSM) that synchronizes with the vertical sync (v_sync) signal
// to coordinate the loading of graphics data and the writing of status flags.
//
// Key Features:
// - Interfaces with memory to load distance and texture data for rendering.
// - Implements a finite state machine (FSM) to handle different stages of operation:
//   1. WAITING: Awaits synchronization with the vertical sync signal.
//   2. READING_FLAGS: Reads the status flags from memory to determine GPU behavior.
//   3. READING_DISTANCE: Loads distance data from memory into an internal buffer.
//   4. READING_TEXTURE: Loads texture data from memory into an internal buffer.
//   5. DECODE_FLAGS: Decodes the flags to determine next actions.
//   6. WRITE_FLAGS: Writes updated flags back to memory to signal task completion.
// - Buffers up to 320 data points for distances and textures, enabling rendering of
//   a 320-pixel-wide frame.
// - Synchronizes with VGA signals, including horizontal sync (h_sync) and vertical
//   sync (v_sync), to ensure proper timing for rendering.
// - Provides VGA output signals for red, green, and blue color channels.
//
// Inputs:
// - clk: Clock signal for synchronization.
// - clr: Clear signal to reset the module to its initial state.
// - read_data: Data input from memory for distance, texture, or flag values.
//
// Outputs:
// - write_enable: Signal to enable writing to memory.
// - write_data: Data to be written to memory.
// - read_address: Address to read data from memory.
// - h_sync: Horizontal synchronization signal for VGA.
// - v_sync: Vertical synchronization signal for VGA.
// - red, green, blue: Color channel outputs for VGA display.
// - vga_clock: Clock signal for VGA synchronization.
// - vga_sync: Composite sync signal for VGA.
// - vga_blank: Blank signal for VGA.
//
// Internal Details:
// - The module uses an FSM with multiple states to sequence its operations:
//   WAITING, READING_FLAGS, READING_DISTANCE, READING_TEXTURE, DECODE_FLAGS, WRITE_FLAGS.
// - Internal buffers (`distances` and `textures`) store up to 320 entries for rendering.
// - Flags are used to determine which memory buffer to read/write to and whether to
//   proceed with certain operations.
// - The `mux4` and `GPU` modules are instantiated to handle memory address selection
//   and rendering operations, respectively.
//
// Usage Notes:
// - The FLAG_ADDRESS location in memory is used to signal task completion.
// - The module is designed for systems with a resolution of 320 pixels wide.

module GPUController(
	input wire clk,
	input wire clr,
	input wire [15:0] read_data,
	output reg write_enable,
	output wire [15:0] write_data,
	output wire [15:0] read_address,
	output wire h_sync,
    output wire v_sync,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
	output wire vga_clock,
	output wire vga_sync,
	output wire vga_blank
);

localparam DISTANCE_1_OFFSET = 16'd63488;
localparam DISTANCE_2_OFFSET = 16'd64512;
localparam TEXTURE_1_OFFSET = 16'd64000;
localparam TEXTURE_2_OFFSET = 16'd65024;
localparam FLAG_ADDRESS = 16'd65535;

localparam WAITING = 4'd0;
localparam READING_FLAGS = 4'd1;
localparam READING_DISTANCE = 4'd2;
localparam READING_TEXTURE = 4'd3;
localparam DECODE_FLAGS = 4'd4;
localparam WRITE_FLAGS = 4'd5;

localparam DISTANCE_SELECT = 2'b00;
localparam TEXTURE_SELECT  = 2'b01;
localparam FLAGS_SELECT    = 2'b10;

reg [15:0] flags;
wire buffer_select = flags[1];
reg started_v_sync;
reg last_hsync;

wire [8:0] reading_index;
reg add_reading, write_distance, write_texture;
reg store_flags, reset_loading_index;
reg [3:0] state, next_state;

reg [8:0] loading_index;

reg [1:0] address_select;

wire [15:0] loading_distance_address = buffer_select ? {7'b0000000, loading_index} + DISTANCE_2_OFFSET : {7'b0000000, loading_index} + DISTANCE_1_OFFSET;
wire [15:0] loading_texture_address  = buffer_select ? {7'b0000000, loading_index} + TEXTURE_2_OFFSET : {7'b0000000, loading_index} + TEXTURE_1_OFFSET;
 
reg [15:0] distances [319:0];
reg [15:0] textures  [319:0];

reg reset_started_v_sync, last_v_sync;

assign write_data = flags | 16'h0001; // For when we want to write  

mux4 memory_mux (
	loading_distance_address, loading_texture_address,
	FLAG_ADDRESS, FLAG_ADDRESS,
	address_select,
	read_address
);

GPU gpu( 
	.clk(clk),
    .clr(clr),
	.distance(distances[reading_index]),
	.texture(textures[reading_index]),
    .h_sync(h_sync),
    .v_sync(v_sync),
    .red(red),
    .green(green),
    .blue(blue),
	.reading_index(reading_index), // enough to address 320 addresses
	.vga_clock(vga_clock),
	.vga_sync(vga_sync),
	.vga_blank(vga_blank)
);

always @ (*) begin
	case(state)
		WAITING: 
			begin
				if (started_v_sync)
					next_state <= READING_FLAGS;
				else
					next_state <= WAITING;
			end
		READING_DISTANCE: next_state <= READING_TEXTURE;
		READING_TEXTURE:
			begin
				if (loading_index >= 9'd319)
					next_state <= WRITE_FLAGS;
				else
					next_state <= READING_DISTANCE;
			end
		READING_FLAGS: next_state <= DECODE_FLAGS;
		DECODE_FLAGS: 
			begin
				if (~flags[0])
					next_state <= READING_DISTANCE;
				else
					next_state <= WAITING;
			end
		WRITE_FLAGS: next_state <= WAITING;
		default:
			next_state <= WAITING;
	endcase
end

always @ (posedge clk) begin
	if (~clr) begin
		loading_index <= 0;
		state <= WAITING;
		started_v_sync <= 0;
		last_v_sync <= 1;
		flags <= 0;
	end else begin
	   if (last_v_sync == 0 && v_sync == 1)
			last_v_sync <= 1;
		else if (last_v_sync == 1 && v_sync == 0) begin
			last_v_sync <= 0;
			started_v_sync <= 1;
		end
		if (write_distance)
			distances[loading_index] <= read_data;
		if (write_texture)
			textures[loading_index] <= read_data;
		if (add_reading)
			loading_index <= loading_index + 1;
		if (store_flags)
			flags <= read_data;
		if (reset_loading_index)
			loading_index <= 0;
		if (reset_started_v_sync)
			started_v_sync <= 0;
		state <= next_state;
	end
end 

always @ (*) begin
	add_reading <= 0;
	address_select <= DISTANCE_SELECT;
	write_distance <= 0;
	write_texture <= 0;
	store_flags <= 0;
	reset_loading_index <= 0;
	write_enable <= 0;
	reset_started_v_sync <= 1;
	case(state)
		WAITING: 
			begin
				reset_loading_index <= 1;
				reset_started_v_sync <= 0;
			end
		READING_DISTANCE:
			begin
				address_select <= DISTANCE_SELECT;
				write_distance <= 1;
			end
		READING_TEXTURE:
			begin
				address_select <= TEXTURE_SELECT;
				write_texture <= 1;
				add_reading <= 1;
			end
		READING_FLAGS:
			begin
				address_select <= FLAGS_SELECT;
				store_flags <= 1;
				reset_loading_index <= 1;
			end
		WRITE_FLAGS:
			begin
				address_select <= FLAGS_SELECT;
				write_enable <= 1;
			end
	endcase
end


endmodule
