`default_nettype none

module audio_echo_processor_tb();

    localparam CLK_TIME = 1000000000 / (44100 * 32) * 1; // 44.1KHz * 32
    localparam audio_width = 16;

    initial begin
        $dumpfile("audio_echo_processor_tb.vcd");
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
    reg [audio_width-1:0] i_left;
    reg [audio_width-1:0] i_right;
    wire o_valid;
    reg o_ready;
    wire [audio_width-1:0] o_left;
    wire [audio_width-1:0] o_right;

    audio_echo_processor #(.audio_width(16), .delay_samples(4)) processor_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_left(i_left),
        .i_right(i_right),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_left(o_left),
        .o_right(o_right)
    );

    always @(posedge clk or reset) begin
        if (reset) begin
        end else begin
            if (o_valid) begin
                $write("l = %08h, r = %08h\n", o_left, o_right);
            end
        end
    end

    task out_data(input [audio_width-1:0] left, input [audio_width-1:0] right);
        begin
            i_valid <= 1'b1;
            i_left <= left;
            i_right <= right;
            wait (i_ready) @(posedge clk);
            i_valid <= 1'b0;
            @(posedge clk);
        end
    endtask

    initial begin
        reset = 1;
        i_valid = 0;
        o_ready = 1;
        i_left = 0;
        i_right = 0;
        repeat (2) @(posedge clk) reset = 1'b1;
        repeat (2) @(posedge clk) reset = 1'b0;

        out_data(16'hC000, 16'h1100);
        out_data(16'h2000, 16'h2100);
        out_data(16'h3000, 16'h3100);
        out_data(16'h4000, 16'h4100);

        out_data(16'hE001, 16'h0101);
        out_data(16'h0002, 16'h0102);
        out_data(16'h0003, 16'h0103);
        out_data(16'h0004, 16'h0104);

        out_data(16'h0005, 16'h0105);
        out_data(16'h0006, 16'h0106);
        out_data(16'h0007, 16'h0107);
        out_data(16'h0008, 16'h0108);

        repeat (16) @(posedge clk);

        $finish;
    end
endmodule
