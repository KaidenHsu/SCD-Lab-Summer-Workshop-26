# Lecture 1. Introduction to Digital IC Design

## Outline

1. AI Compute Power: From Models to Chips
2. From Chip Idea to Real Hardware
3. Bits and Binary Values
4. Inputs, Outputs, and Truth Tables
5. Logic Gates and Small Digital Circuits

## 1. AI Compute Power: From Models to Chips

### Why AI Needs Compute

AI is used for many tasks, not only large language models (LLMs).

| AI application category | Examples |
| --- | --- |
| Large language models | ChatGPT and Claude answer questions, summarize information, and help write code |
| Generative media | Create images, video, music, or other media from prompts |
| Recommendation systems | Predict what a person may want to watch, hear, read, or buy |
| Computer vision | Recognize objects, find patterns, or detect problems in medical images and manufactured products |
| Robotics and driver assistance | Tesla self-driving systems and robots use AI to understand surroundings and choose actions |

Behind these applications are AI models that process a great deal of data.
Training a model means repeatedly adjusting it using many examples; inference
means using the trained model to answer a new question or make a prediction.
Both tasks require a huge number of arithmetic operations, especially matrix
multiplication. That is why AI depends on powerful computer chips.

<p align="left"><img src="images/compute_demand_grows_twice_as_fast_as_chip_efficiency.jpg" alt="AI compute demand growing faster than chip efficiency" width="720" /></p>
▲ AI model compute power demand grows faster than chip efficiency

### GPUs and AI ASICs

Two important kinds of AI compute hardware are GPUs and ASICs.

| Hardware | Main idea | Examples |
| --- | --- | --- |
| GPU | A programmable processor with many parallel compute units | NVIDIA and AMD GPUs |
| ASIC | A chip designed for a specific class of tasks, often to improve speed or energy efficiency | Google TPU; Amazon Trainium and Inferentia |

<p align="left"><img src="images/MPU_spectrum.jpg" alt="MPU spectrum" width="720" /></p>
▲ CPU vs GPU vs FPGA vs ASIC

## 2. From Chip Idea to Real Hardware

### A Chip Lifecycle

Making a chip is a long process. Different teams transform an idea into a physical device that can be placed in a computer, phone, or data center.

```text
Application and Workload
        ↓
Chip Specification and Architecture
        ↓
Front-End IC Design: RTL and Functional Verification
        ↓
Back-End IC Design: Synthesis, Physical Design, and Signoff
        ↓
Manufacturing
        ↓
Packaging and Testing
        ↓
System Integration
        ↓
Application
```

<p align="left"><img src="images/silicon_lifecycle.png" alt="silicon lifecycle" width="600" /></p>
▲ Silicon Lifecycle
<br>
<br>

<p align="left"><img src="images/m1_die_shot.jpg" alt="M1 die shot" width="720" /></p>
▲ Apple M1 SoC Die Shot
<br>
<br>

| Stage | What happens | Example companies |
| --- | --- | --- |
| Application and workload | Identify a problem to solve, such as AI inference, networking, or image processing. | OpenAI, Anthropic |
| IC design: specification, front-end, and back-end | Define the architecture, describe and verify the behavior in RTL, then create and check the physical chip layout. | NVIDIA, Google, Broadcom, MediaTek (聯發科) |
| Manufacturing | Fabricate the physical chip in a semiconductor foundry. | TSMC (台積電) |
| Packaging and testing | Package the manufactured chip, connect it to the outside world, and test that it works correctly. | ASE Technology (日月光), SPIL (矽品) |
| System integration | Connect chips to memory, power, cooling, software, and the rest of a computer system. | Foxconn (鴻海), Quanta Computer (廣達) |

### Where IC Design Fits

The slowing of Moore's Law and the end of Dennard scaling make careful IC
design more important than ever: better performance now requires smarter chip
architectures and more efficient hardware, not only smaller transistors.

**IC design** starts after a chip idea becomes a specification and ends when a
finished physical layout is ready for manufacturing. It has three connected
steps.

<p align="left"><img src="images/ic_design_flow.jpg" alt="IC design flow" width="600" /></p>
▲ IC design flow


#### Chip Specification and Architecture

Engineers decide what the chip must do, how fast it should be, how much energy
it may use, and which major blocks it needs. They also decide how data moves
between those blocks.

#### Front-End IC Design

Front-end designers describe the chip's behavior in RTL using languages such
as Verilog. They verify that the design computes the correct result before a
physical chip exists. This workshop focuses on this step.

#### Back-End IC Design

Back-end designers transform verified RTL into a physical chip layout. They
place circuit blocks, route wires, and check that the chip meets its timing,
power, and area goals.

## 3. Bits and Binary Values

### From the Real World to Digital Data

Before a computer can process information, that information must be represented
as digital data: bits with values of `0` and `1`. Sensors and input devices
turn real-world signals into numbers, while agreed-upon encodings let computers
store and exchange those numbers consistently.

| Information | How it is digitized | Binary representation |
| --- | --- | --- |
| Text | Each character is assigned a code by an encoding such as Unicode. | Character codes stored as groups of bits, often bytes. |
| Sound | A microphone measures air-pressure changes many times per second. | Each measurement is stored as a binary number called a sample. |
| Image | A camera divides a scene into pixels and measures the color of each pixel. | Each pixel’s red, green, and blue values are stored as binary numbers. |
| Video | A video is a sequence of images together with sound samples. | Binary pixel values for frames plus binary audio samples. |
| Numbers and sensor readings | A program or sensor produces a numerical value. | Integers or decimal values encoded in binary formats. |

<p align="left"><img src="images/digitized_multimedia.png" alt="multimedia" width="720" /></p>
▲ From Multimedia to Digitized Signals

### A Bit

A **bit** is a binary digit. It has one of two values: `0` or `1`. In a real digital circuit, those values are represented by ranges of electrical voltage.

### Number Representation

Multiple bits can represent a number using **binary representation**. Each bit
position has a value that is a power of two. For example, the three-bit binary
number `101` means:

```text
1 × 4 + 0 × 2 + 1 × 1 = 5
```

| Decimal | 3-bit binary |
| --- | --- |
| 0 | `000` |
| 1 | `001` |
| 2 | `010` |
| 3 | `011` |
| 4 | `100` |
| 5 | `101` |
| 6 | `110` |
| 7 | `111` |

Unsigned binary is useful when a value cannot be negative, such as the number
of pixels in an image. Computers also need a way to represent negative values,
such as a temperature below zero or a subtraction result.

#### Two's Complement

The most common binary representation for signed integers is **two's
complement**. With four bits, it represents values from `-8` through `+7`.
Positive values use their usual binary form. To find a negative value, invert
every bit of the positive value and add `1`.

For a positive example, `+5` is represented directly as `0101`.

For a negative example, to represent `-5` with four bits:

```text
+5 = 0101
invert the bits: 1010
add 1:           1011  = -5
```

The same pattern of bits can mean different values depending on the number
representation being used.

| 4-bit pattern | Unsigned binary value | Two's-complement value |
| --- | --- | --- |
| `0000` | 0 | 0 |
| `0101` | 5 | +5 |
| `0111` | 7 | +7 |
| `1000` | 8 | -8 |
| `1011` | 11 | -5 |
| `1111` | 15 | -1 |

## 4. Inputs, Outputs, and Truth Tables

### A Circuit's Rule

A digital circuit has inputs, outputs, and a rule that connects them. A truth table lists the output for every possible input combination.

### Example: Two Switches and an LED

Consider a circuit that turns on an LED only when both switches are on. Its output is the logical AND of two input bits.

| Switch A | Switch B | LED output |
| --- | --- | --- |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

### From a Table to a Circuit

Truth tables are a useful bridge between an idea stated in words and the logic circuit that implements it. Students should be able to read this table, predict an output, and complete a similar table for another rule.

## 5. Logic Gates and Small Digital Circuits

### Common Logic Gates

Logic gates are the smallest common building blocks of digital circuits.

| Gate | Output rule |
| --- | --- |
| AND | `1` only when both inputs are `1` |
| OR | `1` when either input is `1` |
| NOT | reverses one input: `0` becomes `1`, and `1` becomes `0` |
| XOR | `1` when two inputs are different |

| Input A | Input B | AND output |
| --- | --- | --- |
| `0` | `0` | `0` |
| `0` | `1` | `0` |
| `1` | `0` | `0` |
| `1` | `1` | `1` |

| Input A | Input B | OR output |
| --- | --- | --- |
| `0` | `0` | `0` |
| `0` | `1` | `1` |
| `1` | `0` | `1` |
| `1` | `1` | `1` |

| NOT input | NOT output |
| --- | --- |
| `0` | `1` |
| `1` | `0` |

### Combining Gates

Larger digital circuits are made by connecting logic gates. The output of one
gate can become the input of another gate. For example, the Boolean expression

```text
Y = (A AND B) OR (NOT C)
```

can be built in three steps:

```text
Gate 1: X1 = A AND B
Gate 2: X2 = NOT C
Gate 3: Y  = X1 OR X2
```

Gate 1 and Gate 2 can operate in parallel because they use different inputs.
Gate 3 uses their outputs to produce the final value. This same idea—combining
small blocks into larger blocks—is how designers build adders, arithmetic
units, and eventually a matrix-multiplication circuit.

> [!NOTE]
> The important idea is that many gates can operate at the same time. This parallel behavior is one reason hardware can accelerate computation.
