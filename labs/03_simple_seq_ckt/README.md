# Lab 3. Bring Your Circuits to Life on the ZedBoard FPGA （電路上板）

## Outline（大綱）

1. Warmup: 4-Bit Counter Circuit（4 位元計數器電路）
2. ZedBoard FPGA
3. Lab 3-1: LED Comet Circuit（LED 彗星電路）
4. Lab 3-2: PWM LED Dimmer Circuit（PWM LED 調光電路）

## 1. Warmup: 4-Bit Up Counter Circuit（4 位元遞增計數器電路）

### Task（任務）

Build a 4-bit up counter（4 位元遞增計數器） that increments once per rising
clock edge（上升時脈邊緣）. First, run the counter testbench（計數器測試平台） and
observe its value on every clock cycle（時脈週期）. Please inspect the timing
diagram（時脈圖） to observe the counter behavior.

### Specs（規格）

| Signal（訊號） | Direction（方向） | Width（寬度） | Description |
| --- | --- | --- | --- |
| `clk` | Input（輸入） | 1 bit | ZedBoard clock signal（時脈訊號）. |
| `rst` | Input（輸入） | 1 bit | Synchronous reset（同步重設）. |
| `count` | Output（輸出） | 4 bits | Current counter value（目前計數器值）. |

### Module Skeleton（模組骨架）

```systemverilog
module counter (
    input  logic        clk,
    input  logic        rst,
    output logic [3:0]  count
);

    // Implement the counter here.

endmodule
```

**Testbench（測試平台）:** [counter_tb.sv](../../rtl/simple_seq_ckts/counter/counter_tb.sv)

> [!NOTE]
> `$display` prints text to the console only during simulation（模擬）. This function is non-synthesizable（不可综合）.

<p align="left"><img src="images/four_bit_up_counter.png" alt="4-bit up counter" width=720 /></p>
▲ 4-bit up counter（4 位元遞增計數器）

<br>
<br>

> [!NOTE]
> **Question:** Can a 4-bit counter count up without bounds (一個 4 位元計數器可以無限地向上數嗎)? If
> not, what happens when it reaches its largest value?

### Update: Warmup Solution

```systemverilog
module counter (
    input  logic             clk,
    input  logic             rst,
    output logic [3:0]       count
);

    always_ff @(posedge clk) begin
        if (rst) count <= 0;
        else count <= count + 1;
    end

endmodule
```

## 2. ZedBoard FPGA

[🎬 What is an FPGA (Field Programmable Gate Array)? | FPGA Concepts（FPGA 介紹）][1]

### ZedBoard Peripherals（ZedBoard 周邊設備）

The ZedBoard provides physical inputs（實體輸入） and outputs（實體輸出） that let
users observe a digital circuit（數位電路） outside the simulator（模擬器）.

| Peripheral（周邊設備） | Direction（方向） | Use in this lab |
| --- | --- | --- |
| User LEDs（使用者 LED） | Output（輸出） | Display the LED Comet pattern（LED 彗星圖樣） and PWM brightness（PWM 亮度）. |
| DIP switches（撥碼開關） | Input（輸入） | Select the PWM brightness value（PWM 亮度值）. |
| Pushbuttons（按鈕） | Input（輸入） | Reset a design（設計） to its starting state（起始狀態）. |

<p align="left"><img src="images/zedboard_IO.jpg" alt="zedboard peripherals" width=720 /></p>
▲ ZedBoard peripherals（ZedBoard 周邊設備）

<br>
<br>
    
An **XDC constraint file（XDC 約束檔）** connects SystemVerilog port names
（連接埠名稱） to physical ZedBoard pins（實體 ZedBoard 腳位）, which
makes the design work on the FPGA.

> [!NOTE]
> We will primarily use the user LEDs in this lab. Switches（開關） and
> the center pushbutton（中央按鈕） support the PWM dimmer（PWM 調光器） and reset
> （重設） behavior.

### ZedBoard FPGA and Vivado（ZedBoard FPGA 與 Vivado）

The ZedBoard includes a **FPGA**. In this workshop, the FPGA runs the circuits（電路） described in
SystemVerilog. **Vivado** is the **electronic design automation (EDA，電子設計
自動化)** tool developed by AMD that we use for the FPGA workflow（FPGA 流程）.

### From SystemVerilog to FPGA Deployment（從 SystemVerilog 到 FPGA 部署）

The path from a SystemVerilog design to running hardware has several steps:

<p align="left"><img src="../01_3x3_comb_matmul_ckt/images/xilinx_flow.png" alt="Xilinx FPGA design flow" width=360 /></p>
▲ Xilinx FPGA Design Flow（Xilinx FPGA 設計流程）
<br>

- **Synthesis（綜合）** converts the RTL（暫存器傳輸層級） description into a
  netlist（電路網表） built from FPGA resources such as lookup tables（查找表）,
  flip-flops（正反器）, memories（記憶體）, and arithmetic blocks（算術區塊）.
- **Implementation（實作）** maps that netlist（電路網表） to the specific FPGA,
  places logic（邏輯） in physical locations, routes connections（連線） between
  it, and checks timing（時序）.
- **Bitstream generation（產生位元串流）** creates configuration data（設定資料）
  that downloads to the FPGA's programmable logic（可程式化邏輯） to become the
  designed circuit.

### FPGA as an IC Front-End Prototyping Platform（FPGA 作為 IC 前端原型驗證平台）

In the **IC front-end design flow（IC 前端設計流程）**, simulation（模擬） is the
first way to check whether an RTL design behaves correctly.
An FPGA prototype（FPGA 原型） provides a second, more physical validation step
（實體驗證步驟） without manufacturing（製造） a custom chip（晶片）. Computer
architects（計算機架構工程師） can use it to test architectural ideas, while RTL
designers can use it to validate that their hardware descriptions（硬體描述） work
together in a real system.

An FPGA prototype（FPGA 原型） does not exactly match a future ASIC's
speed, area（面積）, or power use（功耗）. It is still valuable because
it can reveal functional（功能）, interface（介面）, and system-level（系統層級）
problems early—before committing a design to manufacturing（製造）.

In Labs 2 and 3, Vivado will turn your sequential circuits（循序電路） into
hardware that runs on the ZedBoard FPGA.

<p align="left"><img src="../01_3x3_comb_matmul_ckt/images/fpga_prototyping.jpg" alt="FPGA prototype" width=720 /></p>
▲ FPGA Prototyping（FPGA 原型驗證）

> [!NOTE]
> These days, FPGA is rarely used in the final product. But FPGAs are still highly valuable for prototyping and development to enginnering.

## 3. Lab 3-1: LED Comet Circuit（LED 彗星電路）

### Task (任務)

Build a circuit that moves one illuminated（發亮的） LED across the
eight ZedBoard user LEDs, then wraps（回繞） it back to the first LED.
Use a clock-divider counter（除頻計數器） so the movement is slow
enough to see.

.xdc constraint file（.xdc 約束檔）:  [led_comet.xdc](../../rtl/simple_seq_ckts/led_comet/led_comet.xdc) (The FPGA board's frequency is set to 100 MHz.)

### Specs（規格）

| Signal | Direction | Width | Description |
| --- | --- | --- | --- |
| `clk` | Input | 1 bit | 100 MHz ZedBoard clock signal（時脈訊號）. |
| `rst` | Input | 1 bit | Synchronous reset（同步重設）. |
| `led` | Output | 8 bits | ZedBoard user LEDs. Exactly one bit（位元） should be `1`, and the illuminated LED rotates every 0.25 seconds. |

### Module Skeleton (模組骨架)

```systemverilog
module led_comet  (
    input  logic       clk,
    input  logic       rst,
    output logic [7:0] led
);

// please calculate the number of clock cycles per tick required here
parameter int TICK_CYCLES;

logic [$clog2(TICK_CYCLES)-1:0] tick_count;

    // clock-divider counter
    always_ff @(posedge clk) begin
        if (rst) begin
            tick_count <= 0;
        end else if (tick_count == TICK_CYCLES - 1) begin
            // TODO
        end else begin
            // TODO
        end
    end

    // LED pattern register
    always_ff @(posedge clk) begin
        // TODO
    end

endmodule
```

### Hint 1（提示 1）：Concatenation Operator（串接運算子）

Curly braces, `{}`, are the **concatenation operator（串接運算子）**. They join
bit groups（位元群組） into one wider vector（更寬的向量） by placing the group on
the left first and the group on the right second.

```systemverilog
{2'b10, 2'b01}  // Creates 4'b1001
{3'b101, 1'b0}  // Creates 4'b1010
```

Here is an example that rearranges the bits of a vector（向量）. The leftmost
bit moves to the rightmost position:

```systemverilog
logic [3:0] vector;
logic [3:0] result;

assign result = {vector[2:0], vector[3]};
// If vector is 4'bwxyz, result is 4'bxyzw.
```

### Hint 2（提示 2）：Parameter and `$clog2(x)`

A **parameter（參數）** is a named constant（具名常數） that makes a design easier
to adjust. In the LED Comet circuit（LED 彗星電路）, `TICK_CYCLES` sets how many
clock cycles（時脈週期） pass before the illuminated LED moves.

```systemverilog
parameter int TICK_CYCLES = 25_000_000;
```

`$clog2(x)` gives the minimum bit width（最小位元寬度） needed for a counter with
`x` possible values: `0` through `x - 1`. For example, `$clog2(8)` is `3`
because three bits can represent the eight values from `0` through `7`.

```systemverilog
logic [$clog2(TICK_CYCLES)-1:0] tick_count;
```

This declaration gives `tick_count` just enough bits（位元） to count from `0`
through `TICK_CYCLES - 1`.

### Hint 3（提示 3）：Calculate the number of clock cycles for a rotation

The FPGA clock（FPGA 時脈） is 100 MHz. How many clock cycles（時脈週期） are
needed for the LED to move once every 0.25 seconds?

<p align="left"><img src="images/ring_counter.png" alt="ring counter" width=720 /></p>
▲ ring counter (環形計數器)

### Lab Discussion Questions

1. In your design,what is combinational logic? What is sequential logic?
2. How many registers do you have in your design?
3. Draw this design's circuit diagram.

### Update: Lab 3-1 Solution

```systemverilog
module led_comet  (
    input  logic       clk,
    input  logic       rst,
    output logic [7:0] led
);

parameter int TICK_CYCLES = 25_000_000;

logic [$clog2(TICK_CYCLES)-1:0] tick_count;

    // Clock-divider counter.
    always_ff @(posedge clk) begin
        if (rst) begin
            tick_count <= 0;
        end else if (tick_count == TICK_CYCLES - 1) begin
            tick_count <= 0;
        end else begin
            tick_count <= tick_count + 1'b1;
        end
    end

    // LED pattern register.
    always_ff @(posedge clk) begin
        if (rst) begin
            led <= 8'b0000_0001;
        end else if (tick_count == TICK_CYCLES - 1) begin
            led <= {led[6:0], led[7]};
        end
    end

endmodule
```

### Challenge: LED-pattern variations（LED 圖樣挑戰）

Modify the LED Comet circuit（LED 彗星電路）
>  to create one of these patterns（圖樣）:
>
> - alternating LEDs, such as `10101010` and `01010101`;
> - LEDs that fill one at a time and then clear;
> - an original pattern of your own design.

## 4. Lab 3-2: PWM LED Dimmer Circuit（PWM LED 調光電路）

### Pulse-width modulation (PWM，脈衝寬度調變)

- controls the average power（平均功率） sent to a device（裝置） by switching its
  signal（訊號） rapidly between `0` and `1`.
- For an LED, keeping the signal at `1` for more of each repeating interval
  （重複區間） makes it appear brighter, and vice versa.

[🎬 PWM (Pulse Width Modulation) as Fast As Possible (PWM 介紹)][2]

[🎬 STM32 Guide #3: PWM + Timers (PWM 運作原理)][3]

<br>
    
<p align="left"><img src="images/iphone_pwm.jpg" alt="iPhone PWM" width=600 /></p>
▲ iPhone controls screen brightness using PWM（iPhone 使用 PWM 控制螢幕亮度）

<p align="left"><img src="images/signal_types.png" alt="signal types" width=600 /></p>
▲ digital signal vs analog signal (數位訊號 vs 類比訊號)

<p align="left"><img src="images/duty_cycle.jpg" alt="duty cycle" width=600 /></p>
▲ duty cycle of a signal (訊號的 duty cycle)

### Task (任務)

Build a PWM circuit（PWM 電路） that controls the brightness of LED0. 
The circuit reads the eight ZedBoard switches（ZedBoard 開關） as an
8-bit brightness value（8 位元亮度值）.

.xdc constraint file（.xdc 約束檔）: [pwm_dimmer.xdc](../../rtl/simple_seq_ckts/pwm_dimmer/pwm_dimmer.xdc)

### Specs（規格）

| Signal（訊號） | Direction（方向） | Width（寬度） | Description |
| --- | --- | --- | ---|
| `clk` | Input（輸入） | 1 bit | 100 MHz ZedBoard clock signal（時脈訊號）. |
| `rst` | Input（輸入） | 1 bit | Synchronous reset（同步重設）. |
| `brightness` | Input（輸入） | 8 bits | Brightness value（亮度值） from the eight user switches（開關）. |
| `led` | Output（輸出） | 1 bit | PWM output（PWM 輸出） connected to LED 0. |

### Module Skeleton (模組骨架)

```systemverilog
module pwm_dimmer (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] brightness,
    output logic       led
);
    // put your code here
endmodule
```

### Hints（提示）

- Use a running up counter（遞增計數器）.
- Use a comparator（比較器） to decide whether `led` is currently on: the LED should be
  on while the counter value（計數器值） is smaller than the brightness value（亮度值）.

> [!TIP]
> In SystemVerilog, `<` creates a comparator（比較器） that compares two values.
> ( `a < b` compares `a` and `b` and returns `1` if `a` is smaller than `b`, and `0` otherwise.)

### Update: Lab 3-2 Solution

```systemverilog
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
```

### Lab Discussion Questions

1. Which part of the PWM dimmer circuit（PWM 調光器電路） is sequential, and which part is combinational?
2. Please draw this design's circuit diagram. (The comparatator (比較器) can be drawn as a single block.)

[1]: https://youtu.be/WY-F3knih7c?si=RB0-Ry9jvXej3jyj
[2]: https://youtu.be/ISzRh5eN_Pg?si=5yei901tcLP9Da8B
[3]: https://youtu.be/AjN58ceQaF4?si=TaWgT2_vQfslyOhd
