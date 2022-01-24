`default_nettype none

module sample_delay_buffer_tb();

    localparam CLK_TIME = 1000000000 / (44100 * 32) * 1; // 44.1KHz * 32
    localparam audio_width = 16;

    initial begin
        $dumpfile("sample_delay_buffer_tb.vcd");
        $dumpvars;
    end

    reg clk;
    initial begin
        clk = 1'b0;
        forever begin
            #(CLK_TIME / 2) clk = ~clk;
        end
    end

    reg reset;
    reg i_valid;
    wire i_ready;
    reg [audio_width-1:0] i_audio;
    wire o_valid_operator;
    wire o_ready_operator;
    wire [audio_width-1:0] o_current;
    wire [audio_width-1:0] o_buffer;
    wire i_valid_result;
    wire i_ready_result;
    wire [audio_width-1:0] i_result;
    wire [audio_width-1:0] i_buffer;
    wire o_valid;
    reg o_ready;
    wire [audio_width-1:0] o_audio;

    sample_delay_buffer #(.sample_width(audio_width), .buffer_depth(4)) delay_buffer_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_audio(i_audio),
        .o_valid_operator(o_valid_operator),
        .o_ready_operator(o_ready_operator),
        .o_current(o_current),
        .o_buffer(o_buffer),
        .i_valid_result(i_valid_result),
        .i_ready_result(i_ready_result),
        .i_result(i_result),
        .i_buffer(i_buffer),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_audio(o_audio)
    );

    process #(.audio_width(audio_width)) process_(
        .reset(reset),
        .clk(clk),
        .i_valid(o_valid_operator),
        .i_ready(o_ready_operator),
        .i_current(o_current),
        .i_buffer(o_buffer),
        .o_valid(i_valid_result),
        .o_ready(i_ready_result),
        .o_result(i_result),
        .o_buffer(i_buffer)
    );

    always @(posedge clk or reset) begin
        if (reset) begin
        end else begin
            if (o_valid) begin
                $write("%08h\n", o_audio);
            end
        end
    end

    task out_data(input [audio_width-1:0] audio);
        begin
            i_valid <= 1'b1;
            i_audio <= audio;
            wait (i_ready) @(posedge clk);
            i_valid <= 1'b0;
            @(posedge clk);
        end
    endtask

    initial begin
        reset = 1;
        i_valid = 0;
        o_ready = 1;
        i_audio = 0;
        repeat (2) @(posedge clk) reset = 1'b1;
        repeat (2) @(posedge clk) reset = 1'b0;

        out_data(16'h1000);
        out_data(16'h2000);
        out_data(16'h3000);
        out_data(16'h4000);

        out_data(16'h0001);
        out_data(16'h0002);
        out_data(16'h0003);
        out_data(16'h0004);

        out_data(16'h0005);
        out_data(16'h0006);
        out_data(16'h0007);
        out_data(16'h0008);

        repeat (16) @(posedge clk);

        $finish;
    end
endmodule

module process #(parameter audio_width = 16)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire [audio_width-1:0] i_current,
    input wire [audio_width-1:0] i_buffer,
    output reg o_valid,
    input wire o_ready,
    output reg [audio_width-1:0] o_result,
    output reg [audio_width-1:0] o_buffer);

    always @(posedge clk or reset) begin
        if (reset) begin
            i_ready <= 1'b1;
            o_valid <= 1'b0;
        end else begin
            if (i_valid) begin
                i_ready <= 1'b0;
                o_result <= i_current + i_buffer;
                o_buffer <= i_buffer;
                repeat (2) @(posedge clk);
                o_valid <= 1'b1;
            end
            if (o_valid && o_ready) begin
                o_valid <= 1'b0;
                i_ready <= 1'b1;
            end
        end
    end
endmodule
