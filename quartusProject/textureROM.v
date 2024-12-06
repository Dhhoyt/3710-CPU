// Quartus Prime Verilog Template
// Single Port ROM

module textureROM
(
	input wire [1:0] texture_id,
	input wire [5:0] x,
	input wire [5:0] y,
	output reg [7:0] q
);

	// Declare the ROM variable
	reg [7:0] brick_rom[4095:0];
	reg [7:0] cobble_rom[4095:0];
	reg [7:0] paint1_rom[4095:0];
	reg [7:0] paint2_rom[4095:0];
	
	initial begin
		$readmemb("data_files/brick_texture.dat", brick_rom);
		$readmemb("data_files/cobblestone_texture.dat", cobble_rom);
		$readmemb("data_files/paint1_texture.dat", paint1_rom);
		$readmemb("data_files/paint2_texture.dat", paint2_rom);
	end

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.

	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file, or see the "Using $readmemb and $readmemh"
	// template later in this section.

	always @ (*) begin
		case(texture_id)
			2'b00: q <= brick_rom[{y, x}];
			2'b01: q <= cobble_rom[{y, x}];
			2'b10: q <= paint1_rom[{y, x}];
			2'b11: q <= paint2_rom[{y, x}];
		endcase
	end
	//assign q = x + y;

endmodule