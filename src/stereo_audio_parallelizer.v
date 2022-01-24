`default_nettype none


module stereo_audio_parallelizer #(parameter audio_width = 32)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire i_is_left,
    input wire [audio_width-1:0] i_audio,
    output wire o_valid,
    input wire o_ready,
    output reg [audio_width-1:0] o_left,
    output reg [audio_width-1:0] o_right);

    assign o_valid = !i_ready;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i_ready <= 1'b1;
            o_left <= 0;
            o_right <= 0;
        end else begin
            if (i_ready && i_valid) begin
                if (i_is_left) begin
                    o_left <= i_audio;
                    i_ready <= 1'b1;
                end else begin
                    o_right <= i_audio;
                    i_ready <= 1'b0;
                end
            end else if (o_valid) begin
                i_ready <= o_ready;
            end
        end
    end
endmodule
