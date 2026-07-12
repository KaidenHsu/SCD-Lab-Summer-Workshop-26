# Lab 1: 3x3 Combinational Matmul Circuit

## Outline

1. Why Matrix Multiplication?
2. 3x3 Matrix Multiplication Refresher
3. Introduction to Testbenches
4. Introduction to the ZedBoard FPGA
5. `for` Loops and Nested `for` Loops
6. Data Layout: Flattened Matrix Vectors
7. Understand the 3x3 Matrix Multiplication Testbench
8. Build a Combinational 3x3 Matrix-Multiplication Circuit

## 1. Why Matrix Multiplication?

Matrix multiplication is one of the central computational workloads in modern
science and artificial intelligence. It combines many numbers using the same
repeated multiply-and-add pattern, making it both mathematically important and
well suited to acceleration with specialized hardware.

| Field | How matrix multiplication is used |
| --- | --- |
| Science and engineering | Simulate physical systems, analyze measurements, and solve systems of equations. |
| Computer graphics | Transform and combine positions, images, and other visual data. |
| Artificial intelligence | Compute the layers of neural networks during training and inference. |

Modern AI models perform enormous numbers of matrix multiplications. This is
why GPUs, AI accelerators, and specialized ASICs devote so much hardware to
multiply-and-add operations and moving matrix data efficiently.

<p align="center"><img src="images/DNN_matmul.png" alt="DNN and matrix multipication" /></p>
▲ AI and Matrix Multiplication

A 3x3 matrix multiplier is small enough to understand completely, yet it
contains the same core ideas as much larger workloads: data layout, repeated
arithmetic, parallel hardware, verification, and the tradeoff between
combinational and sequential designs. It is therefore a useful capstone
workload for this workshop.

## 2. 3x3 Matrix Multiplication Refresher

Matrix multiplication combines two matrices, `A` and `B`, to create a new
matrix, `C`:

```text
C = A × B
```

For this lab, all three matrices are 3x3. Each output element `C[i][j]` is
created by taking row `i` from `A`, column `j` from `B`, multiplying matching
elements, and adding the products. This operation is called a **dot product**.

```text
C[i][j] = A[i][0] × B[0][j] + A[i][1] × B[1][j] + A[i][2] × B[2][j]
```

> [!TIP]
> The first index selects a row, and the second index selects a column.
> Each output multiplies a row from `A` and a column from `B`.

<p align="center"><img src="images/3x3_matmul.png" alt="3x3 matmul" /></p>
▲ 3x3 Matrix Multiplication

### Work Out Matrix C by Hand

Consider these two input matrices:

```text
            [ 1  2  3 ]           [ 9  8  7 ]
        A = [ 4  5  6 ]       B = [ 6  5  4 ]
            [ 7  8  9 ]           [ 3  2  1 ]
```

To calculate `C[0][0]`, use row 0 of `A` and column 0 of `B`:

```text
C[0][0] = A[0][0] × B[0][0] + A[0][1] × B[1][0] +  A[0][2] × B[2][0]
        = 1 × 9 + 2 × 6 + 3 × 3 = 9 + 12 + 9 = 30
```

> [!NOTE]
> Please work out matrix C by hand for each student.

## 3. Introduction to Testbenches

A **testbench** is SystemVerilog code used to test a hardware module in a
simulator. It is not part of the circuit that will be synthesized onto an FPGA
or manufactured as an IC. Instead, it acts like an automated experiment:
provide inputs, observe outputs, and compare them with expected results.

<p align="center"><img src="images/tb.png" alt="testbench components" /></p>
▲ testbench components

| Testbench part | Purpose |
| --- | --- |
| Device under test (DUT) | The circuit module being tested. |
| Test signals | Variables that provide input values to the DUT. |
| Expected result | The value the testbench predicts the DUT should produce. |
| Check | Code that reports `PASS` or `FAIL`. |

| Block | Role |
| --- | --- |
| `initial` | Runs once in the simulator; it is used for testbench actions. |
| `always_comb` | Describes combinational hardware. |
| `always_ff` | Describes clocked sequential hardware. |

**Example:** A 4-bit adder testbench that connects input signals to the adder module, applies 5 and 3, and checks that the sum is 8.

```systemverilog
module tb_adder;
    // stimuli
    logic [3:0] a;
    logic [3:0] b;
    logic [4:0] sum;

    // design under test (dut)
    adder_assign dut (
        // connect interface signals
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        // apply test stimuli
        a = 4'd5;
        b = 4'd3;

        // wait for result
        #1;

        // check result
        if (sum == 5'd8)
            $display("PASS: 5 + 3 = 8");
        else
            $display("FAIL: expected 8, got %0d", sum);

        $finish;
    end
endmodule
```

> [!TIP]
> - `#1` delay gives the combinational circuit time to respond before the result is checked.
> - `$display` prints text in the simulator log, and `$finish` ends the simulation.

In this lab, the testbench will apply two 3x3 matrices to the matmul circuit
and automatically check all nine entries of the result matrix.

<p align="center"><img src="images/eda_playground.png" alt="EDA Playground" /></p>
▲ EDA Playground Guideline

## 4. Introduction to the ZedBoard FPGA

In this workshop, we use the **ZedBoard** as the FPGA for our 3x3 matrix multiplication prototype circuit deployment.

### From SystemVerilog to FPGA Deployment

The path from SystemVerilog to running hardware has several steps:

<p align="center"><img src="images/xilinx_flow.png" alt="Xilinx FPGA design flow" width=480 /></p>
▲  Xilinx FPGA Design Flow

- **Synthesis** converts the RTL description into a netlist built from FPGA
  resources such as lookup tables, flip-flops, memories, and arithmetic blocks.
- **Implementation** maps that netlist to the specific FPGA, places logic in
  physical locations, routes connections between it, and checks timing.
- **Bitstream generation** creates the configuration data that downloads to the
  FPGA's programmable logic to become the designed circuit.

### FPGA as an IC Front-End Prototyping Platform

In the IC front-end design flow, simulation is the first way to check whether
an RTL design behaves correctly. An FPGA prototype provides a second, more
physical validation step without manufacturing a custom chip. Computer
architects can use it to test architectural ideas, while RTL designers can use
it to validate that their hardware descriptions work together in a real system.

An FPGA prototype does not exactly match a future ASIC's speed, area, or power
use. It is still valuable because it can reveal functional, interface, and
system-level problems early—before committing a design to manufacturing.

For this lab, students focus on writing and simulating the combinational
matmul circuit. Later in the workshop, they will configure the ZedBoard PL to
run a sequential matmul circuit and observe its behavior through physical
inputs and outputs.

<p align="center"><img src="images/fpga_prototyping.jpg" alt="FPGA prototype" /></p>
▲ FPGA Prototyping

## 5. `for` Loops and Nested `for` Loops

A `for` loop repeats the same hardware-description pattern a fixed number of
times. It does not make the circuit wait through several clock cycles. The EDA
tool expands a fixed loop into the required repeated logic.

### One `for` Loop

This module inverts each bit of a 4-bit input. The loop describes four NOT
operations, one for each bit position.

```systemverilog
module invert_four_bits (
    input  logic [3:0] a,
    output logic [3:0] y
);
    integer i;

    always_comb begin
        for (i = 0; i < 4; i = i + 1) begin
            y[i] = ~a[i];
        end
    end
endmodule
```

### Nested `for` Loops

Nested loops are useful when a circuit has two dimensions, such as rows and
columns. This example creates a 3x3 grid of AND operations. Each output bit is
the AND of one row input and one column input.

```systemverilog
module and_grid_3x3 (
    input  logic [2:0] row_bits,
    input  logic [2:0] column_bits,
    output logic [8:0] grid
);
    integer i, j;

    always_comb begin
        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                grid[i * 3 + j] = row_bits[i] & column_bits[j];
            end
        end
    end
endmodule
```

For `i = 1` and `j = 2`, the code assigns `grid[5]` from
`row_bits[1] & column_bits[2]`. The 3x3 matmul circuit uses the same nested
loop structure: one loop for an output row, one for an output column, and a
third loop for the dot-product terms.

## 6. Data Layout: Flattened Matrix Vectors

The matmul module receives each 3x3 input matrix as one flat vector rather
than nine separate ports. Every input entry is a 4-bit unsigned value, so nine
entries require `9 × 4 = 36` bits.

```systemverilog
input  logic [35:0]  a;
input  logic [35:0]  b;
output logic [107:0] c;
```

The data layout of `a` and `b` use **row-major order**: row 0 from left to right, then row 1, then row 2. The first entry occupies the lowest four bits.

| Matrix entry | Entry index | Bit positions in `a` or `b` |
| --- | --- | --- |
| `[0][0]` | 0 | `[3:0]` |
| `[0][1]` | 1 | `[7:4]` |
| `[0][2]` | 2 | `[11:8]` |
| `[1][0]` | 3 | `[15:12]` |
| `[1][1]` | 4 | `[19:16]` |
| `[1][2]` | 5 | `[23:20]` |
| `[2][0]` | 6 | `[27:24]` |
| `[2][1]` | 7 | `[31:28]` |
| `[2][2]` | 8 | `[35:32]` |

For example, `a[3:0]` holds `A[0][0]`, and `b[27:24]` holds `B[2][0]`.

### Result Vector

The module uses 12 bits for each entry of the output matrix `C`, so all nine
results require `9 × 12 = 108` bits. The output vector uses the same row-major
order:

| Result entry | Bit positions in `c` |
| --- | --- |
| `C[0][0]` | `[11:0]` |
| `C[0][1]` | `[23:12]` |
| `C[0][2]` | `[35:24]` |
| `C[1][0]` | `[47:36]` |
| `C[1][1]` | `[59:48]` |
| `C[1][2]` | `[71:60]` |
| `C[2][0]` | `[83:72]` |
| `C[2][1]` | `[95:84]` |
| `C[2][2]` | `[107:96]` |

### Indexed Part Selects

The matmul circuit uses an **indexed part select** to choose one entry while
the loop indices change. The expression below starts at a calculated bit
position and selects the next four bits:

```systemverilog
a[4 * (i * 3 + k) +: 4]
```

For example, when `i` is `1` and `k` is `2`, the start position is
`4 × (1 × 3 + 2) = 20`, so the expression selects `a[23:20]`, which is
`A[1][2]`. The output uses the same idea with a 12-bit part select:

```systemverilog
c[12 * (i * 3 + j) +: 12]
```

## 7. Understand the 3x3 Matrix Multiplication Testbench

The complete testbench is available [here][1]. Read it from top to
bottom as a small simulation program.

> [!NOTE]
> A testbench, as opposed to a design, is non-synthesizable: it is simulation-only software.

### Signals, DUT, and Stimuli

The testbench declares signals, places the design under test (DUT) inside the
testbench, and then applies input values to the DUT.

```systemverilog
logic [35:0]  a;
logic [35:0]  b;
logic [107:0] c;
logic [107:0] expected;

matmul3x3_comb dut (
    .a(a),
    .b(b),
    .c(c)
);

initial begin
    a[3:0] = 1;
    a[7:4] = 2;
    // Continue assigning the remaining entries of A and B.
end
```

- `a` and `b` are **stimuli**: the testbench assigns values to them.
- `c` is produced by the DUT, so the testbench does not assign values to it.
- `expected` stores the known-correct result for comparison.
- The named connections `.a(a)` connect the DUT port on the left to the
  testbench signal on the right.
- `initial` means the testbench block runs once when simulation starts.

### Expected Values and Output Checks

The testbench loads expected output values, waits briefly for the combinational
circuit to respond, then checks every entry of `C`.

```systemverilog
expected[11:0] = 30;
// Continue assigning the remaining expected entries.

#1;
errors = 0;

for (i = 0; i < 3; i = i + 1) begin
    for (j = 0; j < 3; j = j + 1) begin
        if (c[12 * (i * 3 + j) +: 12]
            !== expected[12 * (i * 3 + j) +: 12]) begin
            errors = errors + 1;
        end
    end
end
```

- `#1` is a simulation delay that lets the combinational output settle before
  the comparison.
- `errors` starts at zero and counts incorrect output entries.
- `!==` checks whether two values differ
- The indexed part select uses the Section 6 data layout to compare one 12-bit
  result entry at a time.
- `$finish` ends the simulation after the results have been reported.

> [!NOTE]
> **Question:** The nested `for` loops above run in the testbench.
> Do they create hardware on the FPGA? How are these simulation loops different
> from the nested loops in the synthesizable matmul design?

### PASS, FAIL, Waveforms, and Simulation End

At the end of the testbench, `$display` prints either a PASS message or a FAIL
message. `$dumpfile` and `$dumpvars` create a waveform file that can help
students debug a failure.

## 8. Build a Combinational 3x3 Matrix-Multiplication Circuit

**Specs:** Complete a combinational SystemVerilog module that calculates `C = A × B` for two 3x3 input matrices `A` and `B`.

| Signal | Direction | Width | Meaning |
| --- | --- | --- | --- |
| `a` | Input | 36 bits | Flattened 3x3 input matrix `A`; each entry is 4 bits. |
| `b` | Input | 36 bits | Flattened 3x3 input matrix `B`; each entry is 4 bits. |
| `c` | Output | 108 bits | Flattened 3x3 result matrix `C`; each entry is 12 bits. |

Please start with this module skeleton:

```systemverilog
module matmul3x3_comb (
    input  logic [35:0]  a,
    input  logic [35:0]  b,
    output logic [107:0] c
);
    integer i, j, k;

    always_comb begin
        // Write your matrix-multiplication logic here.
    end

endmodule
```

**Hints:**

1. Use three nested `for` loops. Let `i` select a row of `A`, `j` select a
   column of `B`, and `k` select the matching elements used in the dot product.

2. Before adding products for one output entry, set that entry of `C` to zero.
   This initialization belongs inside the `i`/`j` loops but before the `k` loop.

3. Your loop structure should match this algorithm:

   ```text
   for every output row i
       for every output column j
           C[i][j] = 0
           for k = 0, 1, 2
               C[i][j] = C[i][j] + A[i][k] × B[k][j]
   ```

4. Use the matrix data layout described in Section 6. `A[i][k]` and
   `B[k][j]` are 4-bit values, while `C[i][j]` is a 12-bit value.

5. Output bit width: the largest 4-bit input value is 15, so one
   product can be as large as `15 × 15 = 225`; the sum of three products
   can be as large as 675. A 12-bit output entry is wide enough.

6. Test one output mentally before running the whole design. For the matrices
   in Section 2, `C[0][0]` must be 30.

### Lab Discussion Questions

1. Why do you think this lab stores each matrix in one flattened vector instead
   of using nine separate 4-bit input ports? What is one benefit and one
   challenge of this choice?
2. When the nested-loop indices are `i = 2`, `j = 1`, and `k = 0`, which
   entries of `A` and `B` are multiplied, and which entry of `C` is updated?
3. The testbench uses one pair of input matrices. Why does one PASS result not
   prove that every possible matrix multiplication works? Propose a second pair
   of input matrices that would test the design in a different way.

[1]: ../../rtl/combinational/comb_tb.sv
