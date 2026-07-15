module pwm_dimmer (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] brightness,
    output logic       led
);

    logic [7:0] pwm_count;

    always_ff @(posedge clk) begin
        if (rst) pwm_count <= '0;
        else pwm_count <= pwm_count + 1'b1;
    end

    assign led = (pwm_count < brightness);

endmodule
