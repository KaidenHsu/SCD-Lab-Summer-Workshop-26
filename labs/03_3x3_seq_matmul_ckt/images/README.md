# Lab 3: Sequential 3x3 Matrix Multiplication Circuit（循序 3x3 矩陣乘法電路）

## Outline（大綱）

1. Review: Datapath and Controller（複習：資料路徑與控制器）
2. Tradeoffs: Combinational and Sequential Matrix Multiplication（取捨：組合邏輯與循序矩陣乘法）
3. Plan the Three-Cycle Matrix-Multiplication Schedule（規劃三週期矩陣乘法時程）
4. Build the Controller（建立控制器）
5. Build the Datapath（建立資料路徑）
6. Integrate the Controller and Datapath（整合控制器與資料路徑）
7. Read and Run the Provided Testbench（閱讀並執行提供的測試平台）
8. Trace Results Across Clock Cycles（追蹤跨時脈週期的結果）
9. Compare Software and Hardware Runtime（比較軟體與硬體執行時間）
10. How Far You Have Come（你已走了多遠）

## 1. Review: Datapath and Controller（複習：資料路徑與控制器）

This lab separates the sequential matrix-multiplication circuit（循序矩陣乘法
電路） into a **controller（控制器）** and a **datapath（資料路徑）**. The
controller decides *when* work happens; the datapath performs the arithmetic
（算術運算） and stores the result（結果）.

| Part | Responsibility in this lab |
| --- | --- |
| Controller（控制器） | Accept `start`, track the dot-product index（內積索引） `k`, set `busy`, and pulse `done`. |
| Datapath（資料路徑） | Clear the result matrix, multiply matching matrix entries（矩陣元素）, and accumulate（累加） the nine output values. |

The controller（控制器） does not calculate matrix values（矩陣值）. The datapath
（資料路徑） does not decide when the calculation（計算） is finished. Keeping these
jobs separate makes a larger hardware design（硬體設計） easier to understand and
debug（除錯）.

## 2. Tradeoffs: Combinational and Sequential Matrix Multiplication（取捨：組合邏輯與循序矩陣乘法）

Lab 1 calculated all three terms of every dot product（內積） at once. This lab
reuses the arithmetic（算術運算） across three clock cycles（時脈週期）: one cycle
for each value of `k`.

| Design | Arithmetic used at one time | Result latency（結果延遲） | Main tradeoff |
| --- | --- | --- | --- |
| Combinational 3x3 matrix multiplication（組合邏輯 3x3 矩陣乘法） | 27 multiplications（乘法） and their additions（加法） | One clock cycle（時脈週期） | Fast result, but more hardware（硬體） and a longer combinational path（組合邏輯路徑）. |
| Sequential 3x3 matrix multiplication（循序 3x3 矩陣乘法） | 9 multiplications per compute cycle（計算週期） | Three compute cycles | Uses less arithmetic hardware（算術硬體）, but takes more clock cycles. |

Both designs（設計） calculate the same matrix（矩陣） `C = A × B`. The difference
is how they use hardware（硬體） and time（時間）.

## 3. Plan the Three-Cycle Matrix-Multiplication Schedule（規劃三週期矩陣乘法時程）

Before writing RTL（暫存器傳輸層級）, trace the schedule（時程）. The controller
（控制器） uses `k` to select one term（項） from every dot product（內積）. The
datapath（資料路徑） updates all nine entries（元素） of `C` on each compute cycle
（計算週期）.

| Clock edge（時脈邊緣） | `busy` after the edge | `k` used by the datapath（資料路徑） | Datapath action（資料路徑行為） | `done` after the edge |
| --- | --- | --- | --- | --- |
| Reset | `0` | `0` | Clear `C`. | `0` |
| Accept `start` | `1` | `0` | Clear `C` for a new matrix product（矩陣乘積）. | `0` |
| First compute | `1` | `0` | Write `A[i][0] × B[0][j]` into each `C[i][j]`. | `0` |
| Second compute | `1` | `1` | Add `A[i][1] × B[1][j]` to each `C[i][j]`. | `0` |
| Third compute | `0` | `2` | Add `A[i][2] × B[2][j]` to each `C[i][j]`. | `1` |
| Next clock edge | `0` | `2` | Hold the completed result. | `0` |

> [!NOTE]
> The start-acceptance edge（接受 start 的時脈邊緣） clears the old result. 
> The three following compute cycles（計算週期） perform the matrix
> multiplication（矩陣乘法）.

### Module Skeleton（模組骨架）

```systemverilog
module matmul3x3_sequential (
    input  logic         clk,
    input  logic         rst,
    input  logic         start,
    input  logic [35:0]  a,
    input  logic [35:0]  b,
    output logic [107:0] c,
    output logic         busy,
    output logic         done
);

    logic [1:0] k;
    integer i, j;

    // controller here

    // datapath here

endmodule
```

## 4. Build the Controller（建立控制器）

Start with the controller（控制器） because it creates the schedule that the
datapath（資料路徑） will follow. The provided module（模組） already declares `k`,
`busy`, and `done`. Complete the controller `always_ff` blocks（區塊） in
[seq_design.sv](../../rtl/seq_matmul/seq_design.sv).

The controller（控制器） must meet these rules:

1. On reset（重設）, set `k` to `0` and set `busy` and `done` to `0`.
2. Set `done` to `0` by default on every non-reset clock edge（時脈邊緣）.
3. When `start` is `1` and `busy` is `0`, begin a calculation: set `k` to `0`
   and set `busy` to `1`.
4. While busy, advance `k` from `0` to `1` to `2`.
5. After the `k = 2` compute cycle（計算週期）, set `busy` to `0` and pulse
   `done` high for one cycle.

### Starter Code

```systemverilog
// Controller: k counts the three dot-product terms.
always_ff @(posedge clk) begin
    if (rst) begin
        // TODO
    end else if (start && !busy) begin
        // TODO
    end else if (busy && k != 2'd2) begin
        // TODO
    end
end

// Controller: busy records whether a matrix product is in progress.
always_ff @(posedge clk) begin
    if (rst) begin
        busy <= 1'b0;
    end else if (start && !busy) begin
        busy <= 1'b1;
    end else if (busy && k == 2'd2) begin
        busy <= 1'b0;
    end
end

// Controller: done is high for one clock cycle after the final compute cycle.
always_ff @(posedge clk) begin
    if (rst) begin
        // TODO
    end else if (busy && k == 2'd2) begin
        // TODO
    end else begin
        // TODO
    end
end
```

> [!TIP]
> Use nonblocking assignments（非阻塞指定，`<=`） in the controller（控制器）. The
> datapath（資料路徑） sees the old value of `k` during a clock edge（時脈邊緣）,
> then the controller updates `k` for the next edge.

## 5. Build the Datapath（建立資料路徑）

The datapath（資料路徑） stores the flattened result matrix（扁平化結果矩陣） in
`c`. It has three jobs:

1. Clear `c` on reset（重設）.
2. Clear `c` when a new `start` request（開始請求） is accepted.
3. While `busy` is high, update all nine output entries（輸出元素） using the
   current value of `k`.

Reuse the nested `for` loops（巢狀 `for` 迴圈） and flattened matrix layout
（扁平化矩陣配置） from Lab 1. The datapath structure（資料路徑結構） is:

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

Use the same indexed part selects（索引部分選取） as Lab 1:

```systemverilog
a[4 * (i * 3 + k) +: 4]
b[4 * (k * 3 + j) +: 4]
c[12 * (i * 3 + j) +: 12]
```

### Starter Code

```systemverilog
// Datapath: clears or updates the nine result accumulators.
always_ff @(posedge clk) begin
    if (rst) begin
        c <= '0;
    end else if (start && !busy) begin
        // Clear all accumulators before beginning a new matrix product.
        c <= '0;
    end else if (busy) begin
        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                if (k == 2'd0) begin
                    // First multiply: start a fresh accumulator.
                    // TODO
                end else begin
                    // Second and third multiplies: add to the sum.
                    // TODO
                end
            end
        end
    end
end
```

> [!TIP]
> `A[i][k]` and `B[k][j]` are 4-bit values（4 位元值）, while each result entry
> （結果元素） is 12 bits. Extend each input value（輸入值） to 12 bits before
> multiplying so the arithmetic（算術運算） has enough width（位寬）.

## 6. Integrate the Controller and Datapath（整合控制器與資料路徑）

The supplied design uses one `always_ff` block（區塊） for each
controller signal（控制器訊號） and one `always_ff` block for the datapath
（資料路徑）. All blocks use the same `clk`, `rst`, `start`, and `busy` signals
（訊號）.

Check these connections（連線） before simulation（模擬）:

| Signal（訊號） | Controller role（控制器角色） | Datapath role（資料路徑角色） |
| --- | --- | --- |
| `rst` | Returns control signals（控制訊號） to their initial values（初始值）. | Clears the result matrix（結果矩陣）. |
| `start` | Begins work only when not busy. | Clears the previous result for the new work. |
| `busy` | Records whether work is in progress. | Enables the three compute cycles（計算週期）. |
| `k` | Selects the next dot-product term（內積項）. | Selects the matrix entries（矩陣元素） to multiply. |
| `done` | Indicates that the final cycle has completed. | The completed result is available in `c`. |

> [!NOTE]
> Why must both blocks（區塊） use nonblocking assignments（非阻塞指定）? What
> could go wrong if one block immediately saw another block's newly assigned
> value on the same clock edge（時脈邊緣）?

## 7. Read and Run the Provided Testbench（閱讀並執行提供的測試平台）

The testbench（測試平台） is already provided in
[seq_tb.sv](../../rtl/seq_matmul/seq_tb.sv). It is simulation code（模擬程式碼）,
not hardware that will be placed on an FPGA（現場可程式化邏輯閘陣列）.

It performs these checks:

1. Applies reset for two clock edges（時脈邊緣）.
2. Loads the two input matrices（輸入矩陣） and pulses `start` for one cycle.
3. Checks that `busy` becomes high after `start`.
4. Waits for the three compute cycles.
5. Checks that `done` is high, `busy` is low, and all nine values in `c` are
   correct.
6. Checks that `done` returns to `0` on the next cycle.

The instructor will use this testbench（測試平台） to check the completed design
（完成的設計） before it is run on the ZedBoard.

## 8. Trace Results Across Clock Cycles（追蹤跨時脈週期的結果）

For the input matrices（輸入矩陣） used by the testbench（測試平台）, trace one
output value（輸出值） by hand:

```text
C[0][0] = 1 × 9 + 2 × 6 + 3 × 3
```

| Compute cycle（計算週期） | `k` | Value stored in `C[0][0]`（儲存在 `C[0][0]` 的值） |
| --- | --- | --- |
| First | 0 | `1 × 9 = 9` |
| Second | 1 | `9 + 2 × 6 = 21` |
| Third | 2 | `21 + 3 × 3 = 30` |

If the testbench（測試平台） reports an incorrect result, first
determine whether the error occurs in the controller schedule（控制器時程） or in
the datapath calculation（資料路徑計算）. Then check `k`, `busy`, `done`, and one
result entry（結果元素） cycle by cycle.

## 9. Compare Software and Hardware Runtime（比較軟體與硬體執行時間）

### Software Baseline（軟體基準）

First, measure a simple C++ baseline（C++ 基準）. A single 3x3 multiplication
（3x3 矩陣乘法） is too short for an ordinary stopwatch, so repeat it many times
and divide the total time by the number of repetitions（重複次數）. The baseline
（基準） is provided in
[matmul_baseline.cpp](../../src/matmul_baseline.cpp).

Compile（編譯） and run it with optimization（最佳化） enabled:

```bash
$ g++ -O2 -std=c++17 src/matmul_baseline.cpp -o matmul_baseline && ./matmul_baseline
Average runtime: 11.2981 ns # runtime on my Intel Core Ultra7 258V CPU
```

### Hardware Accelerator（硬體加速器）

**Assume the FPGA circuit（FPGA 電路） runs at 400 MHz**, which is a reasonable frequency for a modern FPGA.
One clock cycle（時脈 週期） is then 2.5 ns. This sequential circuit（循序電路） uses three compute
cycles（計算週期）, so its calculation latency（計算延遲） is:

```text
3 cycles × 2.5 ns/cycle = 7.5 ns
```

### Speedup（提速）

Calculate hardware speedup given the FPGA clock frequency（FPGA
時脈頻率） assumption:

```text
speedup（提速） = C++ runtime（C++ 執行時間） ÷ hardware runtime
（硬體執行時間） = 11.2981 ns ÷ 7.5 ns = 1.51×
```

In this particular example, the FPGA circuit（FPGA 電路） is about 1.5 times
faster than the optimized C++ code on a fast desktop CPU（中央處理器） under the FPGA
frequency assumption. This is a modest speedup because the workload（工作負載） is very small.
Hardware acceleration（硬體加速） is not automatic; the workload and accelerator
（加速器） must be designed to match each other.

> [!NOTE]
> Hardware-acceleration speedup（硬體加速比） can vary. A small or poorly matched
> workload（工作負載） can have less than `1×` speedup, meaning software（軟體） is
> faster. A well-designed FPGA accelerator（FPGA 加速器） often provides a few
> times to a few tens of times speedup for its target workload. Highly
> specialized, massively parallel accelerators（大規模平行加速器） such as GPUs
> （圖形處理器） and AI ASICs（AI 特殊應用積體電路） can provide tens to hundreds
> of times speedup for suitable workloads. The result depends on the algorithm
> （演算法）, hardware parallelism（硬體平行度）, clock frequency（時脈頻率）, memory
> movement（記憶體資料傳輸）, and software baseline（軟體基準）.

## 10. How Far You Have Come（你已走了多遠）

Congratulations! You have completed a miniature digital IC design journey
（數位 IC 設計旅程）: from bits（位元）, binary values（二進位值）, and logic gates
（邏輯閘）, to SystemVerilog and simulation（模擬）, to combinational（組合邏輯）
and sequential circuits（循序電路）. You have designed and verified a 3x3
matrix-multiplication circuit（3x3 矩陣乘法電路）—the core computation
behind many AI workloads（AI 工作負載）.

The circuit is small, but the workflow is real: describe hardware
（硬體）, simulate（模擬） it, check its results, reason about clock cycles
（時脈週期）, and compare design tradeoffs. These are the foundations
of digital IC design and hardware acceleration.
