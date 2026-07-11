# Lab 2: 3x3 Sequential Matmul Ckt

## Outline

1. Compare the combinational matmul ckt with a clocked implementation.
2. Introduce the `start`, `busy`, and `done` control signals.
3. Use a `k` counter to select one dot-product term per clock cycle.
4. Build the controller `always_ff` block.
5. Build the datapath `always_ff` block and its nine accumulators.
6. Simulate the three compute cycles and verify the completed matrix.
