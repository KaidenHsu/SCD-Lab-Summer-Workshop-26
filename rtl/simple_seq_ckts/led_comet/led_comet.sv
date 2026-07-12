module led_comet #(
    parameter int TICK_CYCLES = 25_000_000
) (
    input  logic       clk,
    input  logic       rst,
    output logic [7:0] led
);

    logic [$clog2(TICK_CYCLES)-1:0] tick_count;

    always_ff @(posedge clk) begin
        if (rst) begin
            tick_count <= '0;
            led        <= 8'b0000_0001;
        end
        else if (tick_count == TICK_CYCLES - 1) begin
            tick_count <= '0;
            led        <= {led[6:0], led[7]};
        end
        else begin
            tick_count <= tick_count + 1'b1;
        end
    end

endmodule
