# Lab 3: 3x3 Sequential Matmul Ckt

## Outline

1. Pipelining
2. Compare the combinational matmul ckt with a clocked implementation.
3. Introduce the `start`, `busy`, and `done` control signals.
4. Use a `k` counter to select one dot-product term per clock cycle.
5. Build the controller `always_ff` block.
6. Build the datapath `always_ff` block and its nine accumulators.
7. Simulate the three compute cycles and verify the completed matrix.
