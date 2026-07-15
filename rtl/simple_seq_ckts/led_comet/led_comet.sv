module led_comet  (
    input  logic       clk,
    input  logic       rst,
    output logic [7:0] led
);

parameter int TICK_CYCLES = 25_000_000;

logic [$clog2(TICK_CYCLES)-1:0] tick_count;

    // Clock-divider counter.
    always_ff @(posedge clk) begin
        if (rst) begin
            tick_count <= 0;
        end else if (tick_count == TICK_CYCLES - 1) begin
            tick_count <= 0;
        end else begin
            tick_count <= tick_count + 1'b1;
        end
    end

    // LED pattern register.
    always_ff @(posedge clk) begin
        if (rst) begin
            led <= 8'b0000_0001;
        end else if (tick_count == TICK_CYCLES - 1) begin
            led <= {led[6:0], led[7]};
        end
    end

endmodule
