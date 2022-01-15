`default_nettype none

module sample_echo #(parameter audio_width = 16, delay_samples = 1024)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire i_is_left,
    input wire [audio_width-1:0] i_audio,
    output wire o_valid,
    input wire o_ready,
    output wire o_is_left,
    output wire [audio_width-1:0] o_audio);

    wire parallelizer_valid;
    wire parallelizer_ready;
    wire [audio_width-1:0] parallelizer_left;
    wire [audio_width-1:0] parallelizer_right;
    stereo_audio_parallelizer #(.audio_width(audio_width)) parallelizer_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_is_left(i_is_left),
        .i_audio(i_audio),
        .o_valid(parallelizer_valid),
        .o_ready(parallelizer_ready),
        .o_left(parallelizer_left),
        .o_right(parallelizer_right)
    );

    wire processor_valid;
    wire processor_ready;
    wire [audio_width-1:0] processor_left;
    wire [audio_width-1:0] processor_right;
    sample_processor #(.audio_width(audio_width), .delay_samples(delay_samples)) processor_(
        .reset(reset),
        .clk(clk),
        .i_valid(parallelizer_valid),
        .i_ready(parallelizer_ready),
        .i_left(parallelizer_left),
        .i_right(parallelizer_right),
        .o_valid(processor_valid),
        .o_ready(processor_ready),
        .o_left(processor_left),
        .o_right(processor_right)
    );

    wire serializer_valid;
    wire serializer_ready;
    wire serializer_is_left;
    wire [audio_width-1:0] serializer_audio;
    stereo_audio_serializer #(.audio_width(audio_width)) stereo_audio_serializer_(
        .reset(reset),
        .clk(clk),
        .i_valid(processor_valid),
        .i_ready(processor_ready),
        .i_left(processor_left),
        .i_right(processor_right),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_is_left(o_is_left),
        .o_audio(o_audio)
    );

endmodule
