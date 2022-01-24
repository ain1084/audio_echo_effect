`default_nettype none

module stereo_audio_serializer_tb();

    localparam SCLK_TIME = 1000000000 / (44100 * 32) * 1; // 44.1KHz * 32

    localparam lrclk_polarity = 1'b1;
    localparam is_i2s = 1'b0;
    localparam audio_width = 32;

    initial begin
        $dumpfile("stereo_audio_serializer_tb.vcd");
        $dumpvars;
    end

    reg sclk;
    initial begin
        sclk = 1'b0;
        forever begin
            #(SCLK_TIME / 2) sclk = ~sclk;
        end
    end

    reg reset;
    reg aligned_i_valid;
    wire aligned_i_ready;
    reg [audio_width-1:0] aligned_i_left;
    reg [audio_width-1:0] aligned_i_right;
    wire aligned_o_valid;
    reg aligned_o_ready;
    wire aligned_o_is_left;
    wire [audio_width-1:0] aligned_o_audio;
    stereo_audio_serializer #(.audio_width(audio_width)) stereo_serializer_(
        .reset(reset),
        .clk(sclk),
        .i_valid(aligned_i_valid),
        .i_ready(aligned_i_ready),
        .i_left(aligned_i_left),
        .i_right(aligned_i_right),
        .o_valid(aligned_o_valid),
        .o_ready(aligned_o_ready),
        .o_is_left(aligned_o_is_left),
        .o_audio(aligned_o_audio)
    );

    reg [31:0] encoder_audio;
    reg encoder_is_left;
    always @(posedge sclk or posedge reset) begin
        if (reset) begin
            aligned_o_ready <= 1'b1;
            encoder_audio <= 0;
            encoder_is_left <= 1'b0;
        end else begin
            if (aligned_o_valid && aligned_o_ready) begin
                encoder_audio <= aligned_o_audio;
                encoder_is_left <= aligned_o_is_left;
                $write("deodoer: is_left = %d / audio = %08h\n", aligned_o_is_left, aligned_o_audio);
                repeat (1) @(posedge sclk);
            end 
        end
    end


    task out_data(input [audio_width-1:0] left, input [audio_width-1:0] right);
        begin
            aligned_i_left <= left;
            aligned_i_right <= right;
            aligned_i_valid <= 1'b1;
            wait (aligned_i_ready) @(posedge sclk);
            aligned_i_valid <= 1'b0;
            @(posedge sclk);
        end
    endtask

    initial begin

        aligned_i_valid = 1'b0;

        aligned_i_left = 16'hcccc;
        aligned_i_right = 16'hdddd;

        repeat (2) @(posedge sclk) reset = 1'b1;
        repeat (20) @(posedge sclk) reset = 1'b0;

        out_data(16'hABCD, 16'h0123);
        out_data(16'h5555, 16'haaaa);
        out_data(16'h3456, 16'h9321);
        out_data(16'h6666, 16'h1111);

        repeat (32) @(posedge sclk);

        $finish();

    end

endmodule
