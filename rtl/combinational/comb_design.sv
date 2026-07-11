// A[0][0] = a[3:0],   A[0][1] = a[7:4], ..., A[2][2] = a[35:32]
// B uses the same layout.
// C[0][0] = c[11:0], C[0][1] = c[23:12], ..., C[2][2] = c[107:96]

module matmul3x3_comb (
    input  logic [35:0]  a,
    input  logic [35:0]  b,
    output logic [107:0] c
);

    integer i, j, k;

    always_comb begin
        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                // Start this output element at zero.
                c[12 * (i * 3 + j) +: 12] = 12'd0;

                // C[i][j] = sum of A[i][k] * B[k][j].
                for (k = 0; k < 3; k = k + 1) begin
                    c[12 * (i * 3 + j) +: 12] += ({8'd0, a[4 * (i * 3 + k) +: 4]} *  {8'd0, b[4 * (k * 3 + j) +: 4]});
                end
            end
        end
    end

endmodule
