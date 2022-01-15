`default_nettype none

module single_port_ram #(parameter width = 16, size = 256)(
    input wire clk,
    input wire [$clog2(size) - 1:0] addr,
    output reg [width - 1:0] read_data,
    input wire write_en,
    input wire [width - 1:0] write_data);

    reg [width-1:0] mem [0: size - 1];
    always @(posedge clk) begin
        if (write_en)
            mem[addr] <= write_data;
        else
            read_data <= mem[addr];
    end
endmodule
