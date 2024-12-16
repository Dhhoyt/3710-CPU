/********************************************************************************
* Texture ROM Module
*
* This module implements a multi-texture ROM for wall textures in the raycasting
* engine. It supports 4 different 64x64 pixel textures, each storing 8-bit color
* values, allowing for varied wall appearances in the 3D environment.
*
* Memory Organization:
* - Each texture is stored in a separate 4096-entry ROM (64x64 pixels)
* - Address format: {y[5:0], x[5:0]} concatenates y and x coordinates
* - Each entry is 8 bits wide for color information
* - Total ROM size: 4 textures * 4096 entries * 8 bits = 16KB
*
* Supported Textures:
* - Brick (ID 00): Standard brick wall pattern
* - Cobblestone (ID 01): Cobblestone wall texture
* - Paint1 (ID 10): First painted wall variation
* - Paint2 (ID 11): Second painted wall variation
*
* Input Ports:
* - texture_id[1:0]: Selects which texture ROM to read from
*     00: brick_rom
*     01: cobble_rom
*     10: paint1_rom
*     11: paint2_rom
* - x[5:0]: X-coordinate within selected texture (0-63)
* - y[5:0]: Y-coordinate within selected texture (0-63)
*
* Output Port:
* - q[7:0]: 8-bit color value from selected texture at (x,y)
*
* Initialization:
* Textures are loaded from external data files:
* - brick_texture.dat
* - cobblestone_texture.dat  
* - paint1_texture.dat
* - paint2_texture.dat
*
* Operation:
* 1. Combines x,y coordinates into single 12-bit ROM address
* 2. Selects appropriate texture ROM based on texture_id
* 3. Outputs color value from selected location
*
* Timing:
* - Combinational output (always @ (*))
* - Single cycle lookup latency
* - No clock required (ROM contents fixed after initialization)
*
* Usage Notes:
* - Ensure texture data files exist in correct path
* - Files must contain binary texture data in correct format
* - x,y inputs should not exceed 63 (6-bit values)
* - Output timing depends on ROM implementation by synthesis tool
********************************************************************************/

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
