`default_nettype none

module stereo_audio_serializer #(parameter audio_width = 32)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire [audio_width-1:0] i_left,
    input wire [audio_width-1:0] i_right,
    output wire o_valid,
    input wire o_ready,
    output reg o_is_left,
    output wire [audio_width-1:0] o_audio);

    reg [audio_width-1:0] right;
    reg [audio_width-1:0] left;
    
    assign o_audio = o_is_left ? left : right;
    assign o_valid = !i_ready;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i_ready <= 1'b1;
            o_is_left <= 1'b1;
            right <= 0;
            left <= 0;
        end else begin
            if (i_ready) begin
                i_ready <= !i_valid;
                right <= i_right;
                left <= i_left;
            end else if (o_ready) begin
                o_is_left <= !o_is_left;
                i_ready <= !o_is_left;
            end
        end
    end
endmodule
