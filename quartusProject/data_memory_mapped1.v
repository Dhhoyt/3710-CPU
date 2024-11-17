module data_memory_mapped1
    (input clock,
     input [15:0] switches,
     input [15:0] write_data,
     input [15:0] address,
     input write_enable,
     output reg [15:0] read_data,
     output reg [15:0] leds);

    reg [15:0] ram[2**16-1:0];
    integer i;
    initial begin
        $readmemh("/home/jackson/repositories/3710-CPU/quartusProject/data_ram.data", ram);
    end

    // Port A
    always @(posedge clock)
        begin
            if (write_enable)
                begin
                    if (address == 15'd255) begin
                        leds <= write_data;
                    end else begin
                        ram[address] <= write_data;
                    end
                    read_data <= write_data;
                end
            else
                begin
                    if (address == 15'd255) begin
                        read_data <= switches;
                    end else begin
                        read_data <= ram[address];
                    end
                end
        end
endmodule
