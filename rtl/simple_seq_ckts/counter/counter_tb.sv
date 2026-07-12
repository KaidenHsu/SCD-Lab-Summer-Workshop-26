module tb_counter;

    logic        clk;
    logic        rst;
    logic [3:0] count;

    counter dut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        repeat (2) @(posedge clk);
        #1;
        rst = 1'b0;

        for (int cycle = 0; cycle < 18; cycle = cycle + 1) begin
            @(posedge clk);
            #1;
            $display("Cycle %0d: count = %0d", cycle, count);
        end

        $finish;
    end

endmodule
