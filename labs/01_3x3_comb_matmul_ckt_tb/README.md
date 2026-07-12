# Lab 1: 3x3 Combinational Matmul Ckt and Testbench

## Outline

1. Refresh 3x3 matrix multiplication and calculate one output dot product by hand.
2. Welcome to EDA Playground.
3. Introduction to testbenches
4. `for` Loops and Nested `for` Loops
5. Data Layout: Flattened Matrix Vectors
6. Build a Combinational 3x3 Matrix-Multiplication Circuit
7. Read the testbench inputs, expected outputs, and pass/fail checks.

## 1. 3x3 Matrix Multiplication Refresher

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

## 2. Welcome to EDA Playground

EDA Playground is a browser-based environment for writing, compiling, and
simulating HDL code. If you have not already done so, sign up for a free
EDA Playground account before continuing.

https://www.edaplayground.com/loginpage

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
> - `initial` means the testbench block runs once when simulation starts.
> - `#1` delay gives the combinational circuit time to respond before the result is checked.
> - `$display` prints text in the simulator log, and `$finish` ends the simulation.

In this lab, the testbench will apply two 3x3 matrices to the matmul circuit
and automatically check all nine entries of the result matrix.

<p align="center"><img src="images/eda_playground.png" alt="EDA Playground" /></p>
▲ EDA Playground Guideline

## 4. `for` Loops and Nested `for` Loops

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

## 5. Data Layout: Flattened Matrix Vectors

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

## 6. Build a Combinational 3x3 Matrix-Multiplication Circuit

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

4. Use the matrix data layout described in Section 5. `A[i][k]` and
   `B[k][j]` are 4-bit values, while `C[i][j]` is a 12-bit value.

5. Output bit width: the largest 4-bit input value is 15, so one
   product can be as large as `15 × 15 = 225`; the sum of three products
   can be as large as 675. A 12-bit output entry is wide enough.

6. Test one output mentally before running the whole design. For the matrices
   in Section 1, `C[0][0]` must be 30.

## 7. Read the testbench inputs, expected outputs, and pass/fail checks.

TBD

> [!NOTE]
> **Question:** What is the circuit's runtime?
