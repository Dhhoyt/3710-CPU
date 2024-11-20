module data_memory_mapped1
    (input clock,
     input [15:0] switches,
     input [15:0] write_data,
     input [15:0] address,
     input write_enable,
     output reg [15:0] read_data_condition,
     output reg [15:0] leds);

    wire condition = address == 16'd255;
    wire write_enable_condition = condition ? 1'b0 : write_enable;
    wire [15:0] read_data;

    memory memory1(clock, write_data, address, write_enable_condition, read_data);

    always @(negedge clock) begin
        read_data_condition <= condition ? switches : read_data;
    end

    always @(negedge clock) begin
        if (write_enable && condition) begin
            leds <= write_data;
        end
    end
endmodule
