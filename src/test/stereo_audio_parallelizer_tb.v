`default_nettype none

module stereo_audio_parallelizer_tb();

    localparam CLK_TIME = 1000000000 / (44100 * 32) * 2; // 44.1KHz * 32 * 2

    initial begin
        $dumpfile("stereo_audio_parallelizer_tb.vcd");
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
    reg i_is_left;
    reg [31:0] i_audio;

    wire o_valid;
    reg o_ready;
    wire [31:0] o_left;
    wire [31:0] o_right;

    integer intake_count = 0;
    integer outlet_count = 0;

    stereo_audio_parallelizer parallelizer_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_is_left(i_is_left),
        .i_audio(i_audio),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_left(o_left),
        .o_right(o_right)
    );

    task intake(input is_left, input reg [31:0] value);
        begin
            i_valid <= 1'b1;
            i_is_left <= is_left;
            i_audio <= value;
            @(posedge clk);
            if (!i_ready)
                wait (i_ready) @(posedge clk);
            intake_count++;
        end
    endtask
    
    initial begin

        o_ready <= 1'b0;
        i_valid <= 1'b0;
        reset = 1'b1;
        repeat(2) @(posedge clk);

        reset = 1'b0;
        repeat(2) @(posedge clk);

        
        intake(1'b1, 32'h00010000);
        intake(1'b0, 32'h1fed1fed);

        intake(1'b1, 32'h2eef2eef);
        intake(1'b0, 32'h33333333);

        intake(1'b1, 32'h12345678);
        intake(1'b0, 32'h1fed1fed);

        intake(1'b1, 32'h99911223);
        intake(1'b0, 32'hABCDEF01);

        intake(1'b1, 32'h55555555);
        intake(1'b0, 32'h44444444);

        wait (intake_count != outlet_count) @(posedge clk);

        $finish();

    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_ready <= 1'b1;
        end else if (o_valid && o_ready) begin
            o_ready <= 1'b0;
            $write("l = %08h / r = %08h\n",  o_left, o_right);
            repeat (1) @(posedge clk);
            o_ready <= 1'b1;
            outlet_count += 2;
        end
    end

endmodule
