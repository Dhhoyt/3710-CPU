// Quartus Prime Verilog Template
// Single Port ROM

module textureROM
(
	input wire [5:0] x,
	input wire [5:0] y,
	output wire [7:0] q
);

	// Declare the ROM variable
	reg [7:0] rom[4095:0];
	
	initial begin
		$readmemb("data_files/texture.dat", rom);
	end

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.

	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file, or see the "Using $readmemb and $readmemh"
	// template later in this section.

	assign q = rom[{y, x}];
	//assign q = x + y;

endmodule