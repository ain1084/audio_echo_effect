`default_nettype none

module sample_processor #(parameter audio_width = 16, delay_samples = 1024)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire [audio_width-1:0] i_left,
    input wire [audio_width-1:0] i_right,
    output wire o_valid,
    input wire o_ready,
    output wire [audio_width-1:0] o_left,
    output wire [audio_width-1:0] o_right);

    wire i_valid_processor;
    reg i_ready_processor;
    reg o_valid_processor;
    wire o_ready_processor;
    wire [audio_width-1:0] i_current_left;
    wire [audio_width-1:0] i_current_right;
    wire [audio_width-1:0] i_buffer_left;
    wire [audio_width-1:0] i_buffer_right;
    reg [audio_width-1:0] o_current_left;
    reg [audio_width-1:0] o_current_right;
    reg [audio_width-1:0] o_feedback_left;
    reg [audio_width-1:0] o_feedback_right;

    sample_delay_buffer #(.sample_width(audio_width * 2), .buffer_depth(delay_samples)) buffer_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_audio({ i_left, i_right }),
        .o_valid_processor(i_valid_processor),
        .o_ready_processor(i_ready_processor),
        .o_current({ i_current_left, i_current_right }),
        .o_buffer({ i_buffer_left, i_buffer_right }),
        .i_valid_processor(o_valid_processor),
        .i_ready_processor(o_ready_processor),
        .i_current({ o_current_left, o_current_right }),
        .i_feedback({ o_feedback_left, o_feedback_right }),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_audio({ o_left, o_right })
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i_ready_processor <= 1'b1;
            o_valid_processor <= 1'b0;
            o_current_left <= 0;
            o_current_right <= 0;
            o_feedback_left <= 0;
            o_feedback_right <= 0;
        end else begin
            if (i_valid_processor) begin
                o_current_left <=  ($signed(i_current_left) >>> 1) + ($signed(i_current_left) >>> 2) + ($signed(i_buffer_right) >>> 2);
                o_feedback_left <= ($signed(i_current_left) >>> 1) + ($signed(i_current_left) >>> 2) + ($signed(i_buffer_left) >>> 2);
                o_current_right <= ($signed(i_current_right) >>> 1) + ($signed(i_current_right) >>> 2) + ($signed(i_buffer_left) >>> 2);
                o_feedback_right <= ($signed(i_current_right) >>> 1) + ($signed(i_current_right) >>> 2) + ($signed(i_buffer_right) >>> 2);
                o_valid_processor <= 1'b1;
                i_ready_processor <= 1'b0;
            end else if (o_valid_processor && o_ready_processor) begin
                i_ready_processor <= 1'b1;
                o_valid_processor <= 1'b0;
            end
        end
    end
endmodule
