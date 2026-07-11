module tb_matmul3x3_comb;

    logic [35:0]  a;
    logic [35:0]  b;
    logic [107:0] c;
    logic [107:0] expected;

    integer i, j;
    integer errors;

    matmul3x3_comb dut (
        .a(a),
        .b(b),
        .c(c)
    );

    initial begin
        $dumpfile("matmul.vcd");
        $dumpvars(0, tb_matmul3x3_comb);

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

        #1;

        errors = 0;

        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                if (c[12 * (i * 3 + j) +: 12] !== expected[12 * (i * 3 + j) +: 12]) begin
                    $display("FAIL: C[%0d][%0d] = %0d, expected %0d",
                        i, j,
                        c[12 * (i * 3 + j) +: 12],
                        expected[12 * (i * 3 + j) +: 12]
                    );

                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("PASS: all 9 output elements are correct.");
        else
            $display("FAIL: %0d output element(s) are incorrect.", errors);

        $finish;
    end

endmodule
