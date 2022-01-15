`default_nettype none

module sample_delay_buffer #(parameter sample_width = 16, buffer_depth = 1024)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire [sample_width-1:0] i_audio,
    output reg o_valid_processor,
    input wire o_ready_processor,
    output reg [sample_width-1:0] o_current,
    output wire [sample_width-1:0] o_buffer,
    input wire i_valid_processor,
    output reg i_ready_processor,
    input wire [sample_width-1:0] i_current,
    input wire [sample_width-1:0] i_feedback,
    output reg o_valid,
    input wire o_ready,
    output reg [sample_width-1:0] o_audio);

    localparam buffer_depth_msb = $clog2(buffer_depth) - 1;
    wire [buffer_depth_msb:0] buffer_depth_last = buffer_depth - 1;

    reg [buffer_depth_msb:0] buffer_ad;
    wire [buffer_depth_msb:0] next_buffer_ad = (buffer_ad == buffer_depth_last) ? 1'd0 : buffer_ad + 1'd1;
    wire [sample_width-1:0] buffer_rd;
    reg [sample_width-1:0] buffer_wd;
    reg buffer_we;
    single_port_ram #(.width(sample_width), .size(buffer_depth)) ram_(
        .clk(clk),
        .addr(buffer_ad),
        .read_data(buffer_rd),
        .write_en(buffer_we),
        .write_data(buffer_wd)
    );

    reg [2:0] state;
    assign o_buffer = buffer_rd;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_ad <= 0;
            buffer_wd <= 0;
            buffer_we <= 1'b0;
            state <= 3'd0;
            i_ready <= 1'b1;
            o_audio <= 0;
            o_current <= 0;
            o_valid <= 1'b0;
            o_valid_processor <= 1'b0;
            i_ready_processor <= 1'b0;
        end else
            case (state)
            3'd0:
                begin
                    buffer_wd <= i_audio;
                    buffer_we <= 1'b1;
                    if (i_valid) begin
                        i_ready <= 1'b0;
                        state <= 3'd1;
                    end
                end
            3'd1:
                begin
                    buffer_we <= 1'b0;
                    buffer_ad <= next_buffer_ad;
                    if (buffer_ad == buffer_depth_last) begin
                        state <= 3'd2;
                    end else begin
                        o_audio <= buffer_wd;
                        o_valid <= 1'b1;
                        state <= 3'd7;
                    end
                end
            3'd7:
                if (o_ready) begin
                    o_valid <= 1'b0;
                    i_ready <= 1'b1;
                    state <= 3'd0;
                end
            3'd2:
                begin
                    i_ready <= 1'b1;
                    state <= 3'd3;
                end
            3'd3:
                begin
                    o_current <= i_audio;
                    if (i_valid) begin
                        i_ready <= 1'b0;
                        o_valid_processor <= 1'b1;
                        state <= 3'd4;
                    end
                end
            3'd4:
                if (o_ready_processor) begin
                    o_valid_processor <= 1'b0;
                    i_ready_processor <= 1'b1;
                    state <= 3'd5;
                end
            3'd5:
                begin
                    buffer_we <= 1'b1;
                    buffer_wd <= i_feedback;
                    o_audio <= i_current;
                    if (i_valid_processor) begin
                        i_ready_processor <= 1'b0;
                        o_valid_processor <= 1'b0;
                        o_valid <= 1'b1;
                        state <= 3'd6;
                    end
                end
            3'd6:
                begin
                    buffer_we <= 1'b0;
                    if (o_ready) begin
                        o_valid <= 1'b0;
                        buffer_ad <= next_buffer_ad;
                        state <= 3'd2;
                    end
                end
            endcase
    end
endmodule
