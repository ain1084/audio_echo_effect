`default_nettype none

module audio_echo_effect_top(
    input wire nreset,
    input wire sclk,
    input wire lrclk,
    input wire sdin,
    input wire clk256,
    output wire spdif);

    localparam audio_width = 16;
    localparam delay_samples = 2048;

    wire reset = !nreset;
    GSR GSR_INST(.GSR(reset));

    audio_echo_effect #(.audio_width(audio_width), .delay_samples(delay_samples)) echo_ (
        .reset(reset),
        .sclk(sclk),
        .lrclk(lrclk),
        .sdin(sdin),
        .clk256(clk256),
        .spdif(spdif)
    );

endmodule
