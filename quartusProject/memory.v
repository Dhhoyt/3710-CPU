module memory
    (input clock,
     input [15:0] write_data_a, write_data_b,
     input [15:0] address_a, address_b,
     input write_enable_a, write_enable_b,
     output reg [15:0] read_data_a, read_data_b );

    reg [15:0] ram[2**16-1:0];
    initial begin
        $readmemh("/home/casey/Documents/School/ECE3710/3710-CPU/assembler/3test.hex", ram);
    end

    // Port A
    always @(negedge clock)
        begin
            if (write_enable_a)
                begin
                    ram[address_a] <= write_data_a;
                    // TODO: Why?
                    // To make it combinational?
                    read_data_a <= write_data_a;
                end
            else
                begin
                    read_data_a <= ram[address_a];
                end
        end

    // Port B	
   always @(negedge clock)
       begin
           if (write_enable_b)
               begin
                   ram[address_b] <= write_data_b;
                   read_data_b <= write_data_b;
               end
           else
               begin
                    read_data_b <= ram[address_b];
                end
         end
endmodule
