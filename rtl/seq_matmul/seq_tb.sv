module tb_matmul3x3_sequential;

    logic         clk;
    logic         rst;
    logic         start;
    logic [35:0]  a;
    logic [35:0]  b;
    logic [107:0] c;
    logic         busy;
    logic         done;

    logic [107:0] expected;
    integer i, j;
    integer errors;

    matmul3x3_sequential dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .c(c),
        .busy(busy),
        .done(done)
    );

    // A 100 MHz clock: each period is 10 ns.
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sequential_matmul.vcd");
        $dumpvars(0, tb_matmul3x3_sequential);

        clk   = 1'b0;
        rst   = 1'b1;
        start = 1'b0;

        // A = [1 2 3
        //      4 5 6
        //      7 8 9]
        a[ 3: 0] = 1;  a[ 7: 4] = 2;  a[11: 8] = 3;
        a[15:12] = 4;  a[19:16] = 5;  a[23:20] = 6;
        a[27:24] = 7;  a[31:28] = 8;  a[35:32] = 9;

        // B = [9 8 7
        //      6 5 4
        //      3 2 1]
        b[ 3: 0] = 9;  b[ 7: 4] = 8;  b[11: 8] = 7;
        b[15:12] = 6;  b[19:16] = 5;  b[23:20] = 4;
        b[27:24] = 3;  b[31:28] = 2;  b[35:32] = 1;

        // Expected C = [30  24  18
        //               84  69  54
        //              138 114  90]
        expected[ 11:  0] = 30;
        expected[ 23: 12] = 24;
        expected[ 35: 24] = 18;
        expected[ 47: 36] = 84;
        expected[ 59: 48] = 69;
        expected[ 71: 60] = 54;
        expected[ 83: 72] = 138;
        expected[ 95: 84] = 114;
        expected[107: 96] = 90;

        // Keep reset high for two rising clock edges.
        repeat (2) @(posedge clk);
        rst = 1'b0;

        // Pulse start for one clock cycle.
        @(negedge clk);
        start = 1'b1;
        @(posedge clk);
        #1 start = 1'b0;

        if (!busy) begin
            $display("FAIL: busy should be high after start.");
            $finish;
        end

        // Wait for the three k = 0, 1, 2 compute cycles.
        repeat (3) @(posedge clk);
        #1;

        errors = 0;

        if (!done) begin
            $display("FAIL: done should be high after three compute cycles.");
            errors = errors + 1;
        end

        if (busy) begin
            $display("FAIL: busy should be low when done is high.");
            errors = errors + 1;
        end

        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                if (c[12 * (i * 3 + j) +: 12]
                    !== expected[12 * (i * 3 + j) +: 12]) begin
                    $display("FAIL: C[%0d][%0d] = %0d, expected %0d",
                        i, j,
                        c[12 * (i * 3 + j) +: 12],
                        expected[12 * (i * 3 + j) +: 12]
                    );
                    errors = errors + 1;
                end
            end
        end

        @(posedge clk);
        #1;

        if (done) begin
            $display("FAIL: done should only be high for one clock cycle.");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: sequential matrix multiplication is correct.");
        else
            $display("FAIL: %0d check(s) failed.", errors);

        $finish;
    end

endmodule
