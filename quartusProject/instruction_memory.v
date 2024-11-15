module instruction_memory
    #(parameter WIDTH=16)
    (input clock,
     input [WIDTH-1:0] address,
     output reg [WIDTH-1:0] read_data);

    reg [15:0] ram[2**16-1:0];

    initial begin
        $readmemh("/home/jackson/repositories/3710-CPU/quartusProject/instruction_ram.data", ram);
    end

    always @(posedge clock)
        begin
            read_data <= ram[address];
        end
endmodule
