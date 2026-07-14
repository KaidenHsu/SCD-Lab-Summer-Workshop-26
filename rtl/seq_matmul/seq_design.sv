// Sequential 3x3 matrix multiplier.
//
// A[0][0] = a[3:0],   A[0][1] = a[7:4], ..., A[2][2] = a[35:32]
// B uses the same layout.
// C[0][0] = c[11:0], C[0][1] = c[23:12], ..., C[2][2] = c[107:96]
//
// Pulse start for one clock cycle when busy is low.  The design performs
// k = 0, k = 1, and k = 2 on the next three clocks.  done is high for one
// clock cycle when c contains the completed matrix.

module matmul3x3_sequential (
    input  logic         clk,
    input  logic         rst,
    input  logic         start,
    input  logic [35:0]  a,
    input  logic [35:0]  b,
    output logic [107:0] c,
    output logic         busy,
    output logic         done
);

    logic [1:0] k;
    integer i, j;

    // Controller: k counts the three dot-product terms.
    always_ff @(posedge clk) begin
        if (rst) begin
            k <= 2'd0;
        end else if (start && !busy) begin
            k <= 2'd0;
        end else if (busy && k != 2'd2) begin
            k <= k + 2'd1;
        end
    end

    // Controller: busy records whether a matrix product is in progress.
    always_ff @(posedge clk) begin
        if (rst) begin
            busy <= 1'b0;
        end else if (start && !busy) begin
            busy <= 1'b1;
        end else if (busy && k == 2'd2) begin
            busy <= 1'b0;
        end
    end

    // Controller: done is high for one clock cycle after the final compute cycle.
    always_ff @(posedge clk) begin
        if (rst) begin
            done <= 1'b0;
        end else if (busy && k == 2'd2) begin
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end

    // Datapath: clears or updates the nine result accumulators.
    always_ff @(posedge clk) begin
        if (rst) begin
            c <= '0;
        end else if (start && !busy) begin
            // Clear all accumulators before beginning a new matrix product.
            c <= '0;
        end else if (busy) begin
            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    if (k == 2'd0) begin
                        // First multiply: start a fresh accumulator.
                        c[12 * (i * 3 + j) +: 12] <= a[4 * (i * 3 + k) +: 4] * b[4 * (k * 3 + j) +: 4];
                    end else begin
                        // Second and third multiplies: add to the sum.
                        c[12 * (i * 3 + j) +: 12] <= c[12 * (i * 3 + j) +: 12] + a[4 * (i * 3 + k) +: 4] *  b[4 * (k * 3 + j) +: 4];
                    end
                end
            end
        end
    end

endmodule
