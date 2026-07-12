# Lecture 2. Verilog Basics and Combinational Circuits

## Outline

1. Electronic Design Automation (EDA)
2. HDL and SystemVerilog
3. Read a module: module name, port list, and `logic` signals.
4. Explain bit widths and unsigned integer values.
5. Build combinational logic with `always_comb` and `for` loops.
6. Homework: Understand a Nested `for` Loop
7. Optional Challenge: Build a 4-Bit Mini ALU

## 1. Electronic Design Automation (EDA)

**Electronic Design Automation (EDA)** is the use of software tools to design,
simulate, verify, and build electronic circuits. These tools let engineers test
a hardware idea long before they manufacture an IC or program an FPGA.

[🎬 How VLSI Revolutionized Semiconductor Design][1]

| Activity | Purpose | Workshop example |
| --- | --- | --- |
| Write hardware code | Describe a digital circuit. | Write a SystemVerilog module. |
| Simulation | Predict how the circuit behaves before hardware exists. | Run the matmul design and testbench in EDA Playground. |
| Waveform viewer | View signals as they change over time. | Debug an unexpected simulation result. |
| Synthesis | Convert a hardware description into a circuit netlist for an FPGA or IC technology. | Use FPGA tools before programming the ZedBoard. |

## 2. HDL and SystemVerilog

### 2.1 HDL

Verilog and SystemVerilog are **Hardware Description Languages (HDLs)**. An
HDL describes what a digital circuit does and how its parts connect. It does
not give a processor a list of software instructions to execute one at a time.

| Idea | HDL (Hardware) | Programming languages (Software) |
| --- | --- | --- |
| Language examples | Verilog, SystemVerilog | C, Python |
| Main purpose | Describe how an electronic circuit is connected and behaves. | Tell an existing computer which steps to perform. |
| Result | A design that can be simulated, implemented on an FPGA, or manufactured as an IC. | A program that runs on a computer, phone, or other device. |
| Operations | Many hardware blocks can operate at the same time in parallel. | Usually execute statements in order. |
| When it operates | The circuit operates continuously when powered. | A program performs its steps when it is run. |

### 2.2 RTL

**Register-Transfer Level (RTL)** is a common way to use an HDL. It describes
the logic that transforms values and the registers that store or transfer those
values on clock cycles. RTL is used to design the digital parts of ICs and FPGAs.

### 2.3 Verilog

Verilog was created in the 1980s as a language for describing and simulating
digital hardware. It became widely used in IC and FPGA design. As chips became
larger and their testing became more complicated, engineers needed a language
with additional design and verification capabilities.

Phil Moorby created Verilog at Gateway Design Automation in the mid-1980s for
digital-circuit simulation. Before HDLs became common, designers often worked
much more directly with gate schematics and low-level circuit details. Verilog
let a designer describe a chip at a higher level, while other specialists and
EDA tools could handle tasks such as verification, physical layout, and
manufacturing preparation. This division of work made it possible for teams to
design much larger and more complex chips.

<p align="center"><img src="images/phil_moorby.jpg" alt="Phil Moorby" width=720 /></p>
▲ Phil Moorby, who created Verilog in the 1980s

### 2.4 SystemVerilog

SystemVerilog was developed in the early 2000s as **an extension of Verilog**. It keeps the core ideas of Verilog while adding features that help engineers describe larger designs and test them more thoroughly.

SystemVerilog includes the core ideas of Verilog, so much simple Verilog code
also works in SystemVerilog. It is widely used for both circuit design and
verification.

> [!NOTE]
> In this workshop, students will use its basic syntax to describe
and simulate real digital circuits; no previous Verilog knowledge is assumed.

## 3. Reading a Module

A **module** is a named hardware building block. It can represent a small
logic gate, an adder, a matrix-multiplication circuit, or an entire chip. A
module has a name and a list of ports that show how it connects to other
hardware.

```systemverilog
module and_gate (
    // ------ start port list ------ 
    input  logic a,
    input  logic b,
    output logic y
    // ------ end port list ------ 
);

    // Circuit behavior will go here.

endmodule
```

> [!TIP]
> In SystemVerilog, comments start with `//`, which are used to explain code and are ignored by compilers and synthesis tools

| Part | Meaning |
| --- | --- |
| `module and_gate` | Starts a module named `and_gate`. |
| Port list | The signals inside the parentheses; these are the module's connections to the outside world. |
| `input` | A signal received by the module. In this example, `a` and `b` are inputs. |
| `output` | A signal produced by the module. In this example, `y` is an output. |
| `logic` | A SystemVerilog signal type used for circuit signals. |
| `endmodule` | Marks the end of the module. |

The module header describes the circuit's interface. Another module can connect
to `a`, `b`, and `y` without needing to know the implementation inside. This
idea lets designers build large systems from smaller, reusable hardware blocks.

## 4. Bit Widths and Unsigned Integer Values

### 4.1 Bit Widths
Digital signals have a fixed number of bits called their **bit width**. A
single signal can hold one bit, while a vector holds several bits.

```systemverilog
module bit_width_example;
    logic        enable;  // One bit: 0 or 1
    logic [3:0]  count;   // Four bits
    logic [7:0]  result;  // Eight bits
endmodule
```

In `logic [3:0] count`, the signal has four bit positions: `3`, `2`, `1`, and
`0`. The left number is the most-significant bit (MSB) and the right number is the
least-significant bit (LSB).

### 4.2 Unsigned Integer Values

An unsigned signal with `n` bits can represent values from `0` through $2^n - 1$.

| Bit width | Smallest value | Largest value |
| --- | --- | --- |
| 1 bit | 0 | 1 |
| 2 bits | 0 | 3 |
| 3 bits | 0 | 7 |
| 4 bits | 0 | 15 |
| 8 bits | 0 | 255 |

SystemVerilog can write a number with its width and base. For example, `4'd9`
means the decimal value 9 stored in four bits, and `4'b1001` means the same
four-bit value written in binary.

## 5. Combinational Logic with `always_comb` and `for` Loops

### 5.1 Behavioral-Level SystemVerilog

There are several ways to describe hardware. At a low level, a designer can
connect individual logic gates. At the **behavioral level**, a designer writes
what a block should compute, and EDA tools determine the gates and wires needed
to implement that behavior.

Behavioral code is still a hardware description, not ordinary software. For a
synthesizable design, the EDA tool converts the description into a circuit that
can be implemented on an FPGA or manufactured as an IC.

### 5.2 Clock and Combinational Circuits

A **clock signal** is a repeating `0`/`1` signal used to synchronize
sequential circuits. Registers update at a clock edge, which lets designers
measure sequential work in clock cycles.

Pure combinational logic has no clock and no memory. It does not take an exact
number of clock cycles to compute; instead, its output settles after a small
physical **propagation delay**. In a synchronous system, designers choose a
clock period long enough for the combinational result to settle before the next
clock edge. The result can then be captured on that next edge, which is often
described as completing within one clock cycle.

Combinational logic depends only on its current inputs. It has no clock and no
memory. When an input changes, the output recalculates after its propagation
delay.

> [!NOTE]
> **Question:** A pure combinational circuit is used in a system with a
> 100 MHz clock. The circuit receives its inputs at the start of one clock
> cycle and completes its calculation by the next clock edge. How long does it take for the  circuit to finish its work?

### 5.3 `always_comb`

SystemVerilog uses `always_comb` to describe combinational logic.

Example:

```systemverilog
module adder_always_comb (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [4:0] sum
);
    always_comb begin
        sum = a + b;
    end
endmodule
```

The same adder can be written with a continuous `assign` statement:

```systemverilog
module adder_assign (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [4:0] sum
);
    assign sum = a + b;
endmodule
```

These two descriptions are equivalent: both describe combinational hardware
that continuously calculates the sum of `a` and `b`.

This block describes an adder. The statement does not mean that an adder runs
only once; it describes an adder circuit that continuously responds to `a` and
`b`.

<p align="center"><img src="images/half_adder.png" alt="half adder" width=720 /></p>
▲ half adder circuit and its truth table (sum = {C, S})

### 5.4 `for` Loops Describe Repeated Hardware

A `for` loop is useful when the same operation is repeated a fixed number of
times. In a synthesizable combinational block, the loop does not create a
processor that repeatedly executes instructions. Instead, the EDA tool expands
the fixed loop into the required hardware connections.

Example:

```systemverilog
module add_three_elements (
    input  logic [3:0] data [0:2],
    output logic [5:0] total
);
    always_comb begin
        total = 0;

        for (int i = 0; i < 3; i = i + 1) begin
            total = total + data[i];
        end
    end
endmodule
```

This code describes the addition of three values. The loop limit, `3`, is fixed
so the tool knows how much hardware to create. The same pattern will let
students describe the repeated multiplications and additions in the 3x3
combinational matrix-multiplication circuit.

> [!NOTE]
> Question: What hardware does this piece of HDL describe?

> [!NOTE]
> Question: Can you describe the same hardware without a loop? (Hint: use `assign`)

### 5.5 `if ... else` Describes a Selector

In a combinational block, an `if ... else` statement describes a circuit that
chooses one input based on a control signal (`select`). This circuit is called a
**multiplexer**, or **mux**. It is like a digital switch: the selected input is
connected to the output (`y`).

```systemverilog
module mux2 (
    input  logic select,
    input  logic a,
    input  logic b,
    output logic y
);
    always_comb begin
        if (select) begin
            y = a;
        end
        else begin
            y = b;
        end
    end
endmodule
```

When `select` is `1`, `y` receives `a`; when `select` is `0`, `y` receives `b`.

<p align="center"><img src="images/mux2.jpg" alt="mux2" width=720 /></p>
▲ 2-to-1 multiplexer circuit and its truth table

## 6. Homework: Understand a Nested `for` Loop

Read the following module and determine what circuit it describes.

```systemverilog
module and_grid_2x2 (
    input  logic [1:0] row_bits,
    input  logic [1:0] column_bits,
    output logic [3:0] grid
);
    integer i, j;

    always_comb begin
        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                grid[i * 2 + j] = row_bits[i] & column_bits[j];
            end
        end
    end
endmodule
```

> [!TIP]
> `&` means bitwise AND. It produces `1` only when both input bits are `1`.

### Questions to Consider

1. How many output bits does `grid` have?
2. How many times does the assignment to `grid[...]` appear after the loops are
   expanded?
3. When `i = 0` and `j = 0`, which `grid` bit is assigned, and which two input
   bits are used?
4. When `i = 1` and `j = 0`, which `grid` bit is assigned, and which two input
   bits are used?
5. Draw the four output bits as a 2x2 grid. What does each row and each column
   correspond to?

## 7. Optional Challenge: Build a 4-Bit Mini ALU

**Spec:**

| Signal name | Port direction | Bit width | Description |
| --- | --- | --- | --- |
| `a` | Input | 4 bits | First unsigned input value. |
| `b` | Input | 4 bits | Second unsigned input value. |
| `op` | Input | 2 bits | Selects the operation based on the rule in the next table. |
| `y` | Output | 5 bits | Result of the selected operation. |


| `op` | Required operation |
| --- | --- |
| `2'b00` | `y = a + b` |
| `2'b01` | `y = a AND b` (bitwise and) |
| `2'b10` | `y = a OR b` (bitwise or) |
| `2'b11` | `y = 0` |

> [!TIP]
> `2'b01` is a SystemVerilog number literal. The `2` means the value uses two
> bits, `b` means the value is written in binary, and `01` is the binary value.
> Therefore, `2'b01` is the two-bit representation of decimal 1.

> [!TIP]
> Bitwise AND (`&`) and bitwise OR (`|`) compare matching bit positions in two
> values. For example, `4'b0101 & 4'b0011` is `4'b0001`, while
> `4'b0101 | 4'b0011` is `4'b0111`.

Example inputs:

| `a` | `b` | `op` | Expected `y` |
| --- | --- | --- | --- |
| 5 | 3 | `2'b00` | 8 |
| 5 | 3 | `2'b01` | 1 |
| 5 | 3 | `2'b10` | 7 |
| 5 | 3 | `2'b11` | 0 |

**Hint:**

```systemverilog
module mini_alu (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic [1:0] op,
    output logic [4:0] y
);

    // Write one always_comb block here.

endmodule
```

- Use one `always_comb` block with `if` / `else if` / `else`.
- Assign `y` on every path through the conditional.
- What's the bit width required by `a + b`?
- Use `a & b` for bitwise AND and `a | b` for bitwise OR.

[1]: https://www.youtube.com/watch?v=XgbxFVyKMMo]
