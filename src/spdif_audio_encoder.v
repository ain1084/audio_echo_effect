`default_nettype none

module spdif_audio_encoder #(parameter audio_width = 16)(
    input wire reset,
    input wire clk,
    input wire clk256,
    input wire i_valid,
    output wire i_ready,
    input wire [audio_width-1:0] i_audio,
    input wire i_is_left,
    output wire spdif);

    reg clk128;
    always @(posedge clk256 or posedge reset)
        clk128 <= (reset) ? 1'b0 : ~clk128;

    wire o_ready;
    wire o_valid;
    wire o_is_left;
    wire o_is_error;
    wire [audio_width-1:0] o_audio;
    dual_clock_buffer #(.width(audio_width+1)) dbuffer_ (
        .reset(reset),
        .i_clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_data({ i_is_left, i_audio }),
        .o_clk(clk128),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_data({ o_is_left, o_audio })
    );

    spdif_frame_encoder #(.audio_width(audio_width)) encoder_ (
        .clk128(clk128),
        .reset(reset),
        .next_sub_frame_number(),
        .i_valid(o_valid),
        .i_ready(o_ready),
        .i_is_left(o_is_left),
        .i_audio(o_audio),
        .i_user(1'b0),
        .i_control(1'b0),
        .spdif(spdif));

endmodule
