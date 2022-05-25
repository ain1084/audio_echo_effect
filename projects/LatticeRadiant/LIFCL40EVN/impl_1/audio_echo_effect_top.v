`default_nettype none

module audio_echo_effect_top(
    input wire sclk,
    input wire lrclk,
    input wire sdin,
    input wire clk256,
    input wire nreset,
    output wire spdif);

    localparam audio_width = 16;
    localparam delay_samples = 4096;

    GSR GST_INST(.GSR_N(nreset));

    wire reset = !nreset;

    wire clk;
    OSCA #(.HF_OSC_EN("ENABLED"), .HF_CLK_DIV("10")) OSC_INST(
        .HFOUTEN(1'b1),
        .HFSDSCEN(1'b0),
        .HFCLKOUT(clk)
    );

    // Decoder
    wire decoder_valid;
    wire decoder_ready;
    wire decoder_is_left;
    wire [audio_width-1:0] decoder_audio;
    wire decoder_is_error;
    serial_audio_decoder #(.audio_width(audio_width)) decoder_(
        .sclk(sclk),
        .reset(reset),
        .lrclk(lrclk),
        .sdin(sdin),
        .is_i2s(1'b1),
        .lrclk_polarity(1'b0),
        .is_error(decoder_is_error),
        .o_valid(decoder_valid),
        .o_ready(decoder_ready),
        .o_is_left(decoder_is_left),
        .o_audio(decoder_audio)
    );
    wire reset_with_error = reset | decoder_is_error;

    // Synchronize sclk to clk domain
    wire decoder_sync_ready;
    wire decoder_sync_valid;
    wire decoder_sync_is_left;
    wire [audio_width-1:0] decoder_sync_audio;
    dual_clock_buffer #(.width(audio_width + 1)) decoder_sync_ (
        .reset(reset_with_error),
        .i_clk(sclk),
        .i_valid(decoder_valid),
        .i_ready(decoder_ready),
        .i_data({ decoder_is_left, decoder_audio }),
        .o_clk(clk),
        .o_valid(decoder_sync_valid),
        .o_ready(decoder_sync_ready),
        .o_data({ decoder_sync_is_left, decoder_sync_audio })
    );

    // Process (echo)
    wire echo_valid;
    wire echo_ready;
    wire echo_is_left;
    wire [audio_width-1:0] echo_audio;
    audio_echo_effect #(.audio_width(audio_width), .delay_samples(delay_samples)) echo_ (
        .reset(reset_with_error),
        .clk(clk),
        .i_valid(decoder_sync_valid),
        .i_ready(decoder_sync_ready),
        .i_is_left(decoder_sync_is_left),
        .i_audio(decoder_sync_audio),
        .o_valid(echo_valid),
        .o_ready(echo_ready),
        .o_is_left(echo_is_left),
        .o_audio(echo_audio)
    );


    spdif_audio_encoder #(.audio_width(audio_width)) encoder_ (
        .reset(reset_with_error),
        .clk(clk),
        .clk256(clk256),
        .i_valid(echo_valid),
        .i_ready(echo_ready),
        .i_is_left(echo_is_left),
        .i_audio(echo_audio),
        .spdif(spdif)
    );

endmodule
