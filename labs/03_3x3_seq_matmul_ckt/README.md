# Lab 3: Sequential 3x3 Matrix Multiplication Circuit

## Outline

1. Review: Datapath and Controller
2. Tradeoffs: Combinational and Sequential Matrix Multiplication
3. Plan the Three-Cycle Matrix-Multiplication Schedule
4. Build the Controller
5. Build the Datapath
6. Integrate the Controller and Datapath
7. Read and Run the Provided Testbench
8. Trace Results Across Clock Cycles
9. Compare Software and Hardware Runtime
10. How Far You Have Come

## 1. Review: Datapath and Controller

This lab separates the sequential matrix-multiplication circuit into a
**controller** and a **datapath**. The controller decides *when* work happens;
the datapath performs the arithmetic and stores the result.

| Part | Responsibility in this lab |
| --- | --- |
| Controller | Accept `start`, track the dot-product index `k`, set `busy`, and pulse `done`. |
| Datapath | Clear the result matrix, multiply matching matrix entries, and accumulate the nine output values. |

The controller does not calculate matrix values. The datapath does not decide
when the calculation is finished. Keeping these jobs separate makes a larger
hardware design easier to understand and debug.

## 2. Tradeoffs: Combinational and Sequential Matrix Multiplication

Lab 1 calculated all three terms of every dot product at once. This lab reuses
the arithmetic across three clock cycles: one cycle for each value of `k`.

| Design | Arithmetic used at one time | Result latency | Main tradeoff |
| --- | --- | --- | --- |
| Combinational 3x3 matrix multiplication | 27 multiplications and their additions | One clock cycle | Fast result, but more hardware and a longer combinational path. |
| Sequential 3x3 matrix multiplication | 9 multiplications per compute cycle | Three compute cycles | Uses less arithmetic hardware, but takes more clock cycles. |

Both designs calculate the same matrix `C = A × B`. The difference is how they
use hardware and time.

## 3. Plan the Three-Cycle Matrix-Multiplication Schedule

Before writing RTL, trace the schedule. The controller uses `k` to select one
term from every dot product. The datapath updates all nine entries of `C` on
each compute cycle.

| Clock edge | `busy` after the edge | `k` used by the datapath | Datapath action | `done` after the edge |
| --- | --- | --- | --- | --- |
| Reset | `0` | `0` | Clear `C`. | `0` |
| Accept `start` | `1` | `0` | Clear `C` for a new matrix product. | `0` |
| First compute | `1` | `0` | Write `A[i][0] × B[0][j]` into each `C[i][j]`. | `0` |
| Second compute | `1` | `1` | Add `A[i][1] × B[1][j]` to each `C[i][j]`. | `0` |
| Third compute | `0` | `2` | Add `A[i][2] × B[2][j]` to each `C[i][j]`. | `1` |
| Next clock edge | `0` | `2` | Hold the completed result. | `0` |

> [!NOTE]
> The start-acceptance edge clears the old result. The three following compute
> cycles perform the matrix multiplication.

## 4. Build the Controller

Start with the controller because it creates the schedule that the datapath
will follow. The provided module already declares `k`, `busy`, and `done`.
Complete the controller `always_ff` block in
[seq_design.sv](../../rtl/seq_matmul/seq_design.sv).

The controller must meet these rules:

1. On reset, set `k` to `0` and set `busy` and `done` to `0`.
2. Set `done` to `0` by default on every non-reset clock edge.
3. When `start` is `1` and `busy` is `0`, begin a calculation: set `k` to `0`
   and set `busy` to `1`.
4. While busy, advance `k` from `0` to `1` to `2`.
5. After the `k = 2` compute cycle, set `busy` to `0` and pulse `done` high
   for one cycle.

> [!TIP]
> Use nonblocking assignments (`<=`) in the controller. The datapath sees the
> old value of `k` during a clock edge, then the controller updates `k` for the
> next edge.

## 5. Build the Datapath

The datapath stores the flattened result matrix in `c`. It has three jobs:

1. Clear `c` on reset.
2. Clear `c` when a new `start` request is accepted.
3. While `busy` is high, update all nine output entries using the current
   value of `k`.

Reuse the nested `for` loops and flattened matrix layout from Lab 1. The
datapath structure is:

```text
if reset
    clear c
else if start is accepted
    clear c
else if busy
    for every output row i
        for every output column j
            if k is 0
                C[i][j] = A[i][k] × B[k][j]
            else
                C[i][j] = C[i][j] + A[i][k] × B[k][j]
```

Use the same indexed part selects as Lab 1:

```systemverilog
a[4 * (i * 3 + k) +: 4]
b[4 * (k * 3 + j) +: 4]
c[12 * (i * 3 + j) +: 12]
```

> [!TIP]
> `A[i][k]` and `B[k][j]` are 4-bit values, while each result entry is 12
> bits. Extend each input value to 12 bits before multiplying so the arithmetic
> has enough width.

## 6. Integrate the Controller and Datapath

The supplied design uses one `always_ff` block for the controller and one
`always_ff` block for the datapath. Both blocks use the same `clk`, `rst`,
`start`, and `busy` signals.

Check these connections before simulation:

| Signal | Controller role | Datapath role |
| --- | --- | --- |
| `rst` | Returns control signals to their initial values. | Clears the result matrix. |
| `start` | Begins work only when not busy. | Clears the previous result for the new work. |
| `busy` | Records whether work is in progress. | Enables the three compute cycles. |
| `k` | Selects the next dot-product term. | Selects the matrix entries to multiply. |
| `done` | Indicates that the final cycle has completed. | The completed result is available in `c`. |

> [!NOTE]
> Why must both blocks use nonblocking assignments? What could go wrong if one
> block immediately saw another block's newly assigned value on the same clock
> edge?

## 7. Read and Run the Provided Testbench

The testbench is already provided in
[seq_tb.sv](../../rtl/seq_matmul/seq_tb.sv). It is simulation code, not
hardware that will be placed on an FPGA.

It performs these checks:

1. Applies reset for two clock edges.
2. Loads the two input matrices and pulses `start` for one cycle.
3. Checks that `busy` becomes high after `start`.
4. Waits for the three compute cycles.
5. Checks that `done` is high, `busy` is low, and all nine values in `c` are
   correct.
6. Checks that `done` returns to `0` on the next cycle.

The instructor will use this testbench to check the completed design before it
is run on the ZedBoard.

## 8. Trace Results Across Clock Cycles

For the input matrices used by the testbench, trace one output value by hand:

```text
C[0][0] = 1 × 9 + 2 × 6 + 3 × 3
```

| Compute cycle | `k` | Value stored in `C[0][0]` |
| --- | --- | --- |
| First | 0 | `1 × 9 = 9` |
| Second | 1 | `9 + 2 × 6 = 21` |
| Third | 2 | `21 + 3 × 3 = 30` |

If the testbench reports an incorrect result, first determine whether the
error occurs in the controller schedule or in the datapath calculation. Then
check `k`, `busy`, `done`, and one result entry cycle by cycle.

## 9. Compare Software and Hardware Runtime

### Software Baseline

First, measure a simple C++ baseline. A single 3x3 multiplication is too short
for an ordinary stopwatch, so repeat it many times and divide the total time by
the number of repetitions. The baseline is provided in
[matmul_baseline.cpp](../../src/matmul_baseline.cpp).

Compile and run it with optimization enabled:

```bash
$ g++ -O2 -std=c++17 src/matmul_baseline.cpp -o matmul_baseline && ./matmul_baseline
Average runtime: 11.2981 ns # runtime on my Intel Core Ultra7 258V CPU
```

### Hardware Accelerator

**Assume the FPGA circuit runs at 400 MHz**. One clock cycle is then 2.5 ns. This
sequential circuit uses three compute cycles, so its calculation latency is:

```text
3 cycles × 2.5 ns/cycle = 7.5 ns
```

### Speedup

Calculate hardware speedup given the FPGA clock frequency assumption

```text
speedup = C++ average runtime ÷ hardware runtime =  11.2981 ns ÷ 7.5 ns = 1.51×
```

In this particular example, the FPGA circuit is about 1.5 times faster than
the optimized C++ code on a fast desktop CPU. This is a modest speedup because
the workload is very small. Hardware acceleration is not automatic; the
workload and accelerator must be designed to match each other.

> [!NOTE]
> Hardware-acceleration speedup can vary. A small or poorly matched
> workload can have less than `1×` speedup, meaning software is faster. A
> well-designed FPGA accelerator often provides a few times to a few tens of
> times speedup for its target workload. Highly specialized, massively parallel
> accelerators such as GPUs and AI ASICs can provide tens to hundreds of times
> parallelism, clock frequency, memory movement, and software baseline.

## 10. How Far You Have Come

Congratulations! You have completed a miniature digital IC design journey:
from bits, binary values, and logic gates, to SystemVerilog and simulation, to
combinational and sequential circuits. You have designed and verified a 3x3
matrix-multiplication circuit—the core computation behind many AI workloads.

The circuit is small, but the workflow is real: describe hardware, simulate
it, check its results, reason about clock cycles, and compare design tradeoffs.
These are the foundations of digital IC design and hardware acceleration.
