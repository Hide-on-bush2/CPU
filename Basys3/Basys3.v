`include"CLK_slow.v"
`include"Display_7Seg.v"
`include"Display_select.v"
`include"Display_transfer.v"
`include"Keyboard.v"
`include"../SingleCycleCPU/SingleCycleCPU.v"

module Basys3(
    input CLKButton,
    input BasysCLK,
    input RST_Button,
    input [1:0] SW_in,

    output [7:0] SegOut,
    output [3:0] Bits
);

//CPU
wire [4:0] RsAddr, RtAddr;
wire [31:0] RsData, RtData;
wire [31:0] ALUResult;
wire [31:0] DBData;
wire [31:0] curPC, nextPC;

wire CPUCLK;

SingleCycleCPU CPU(
    .CLK(CPUCLK),
    .Reset(RST_Button),
    .rs(RsAddr),
    .rt(RtAddr),
    .Out1(RsData),
    .Out2(RtData),
    .curPC(curPC),
    .nextPC(nextPC),
    .Result(ALUResult),
    .DBData(DBData)
);

//CLK_slow

wire Div_CLK;
CLK_slow clk_slow(
    .CLK_100mhz(BasysCLK),
    .CLK_slow(Div_CLK)
);

//Display_7Seg
wire [3:0] SegIn;

Display_7SegLED display_led(
    .display_data(SegIn),
    .dispcode(SegOut)
);

//Display_select

wire [15:0] display_data;
Select select(
    .In1({curPC[7:0], nextPC[7:0]}),
    .In2({3'b000, RsAddr[4:0], RsData[7:0]}),
    .In3({3'b000, RtAddr[4:0], RtData[7:0]}),
    .In4({ALUResult[7:0], DBData[7:0]}),

    .SelectCode(SW_in),
    .DataOut(display_data)
);

//Display_transfer
Transfer tansfer(
    .CLK(Div_CLK),
    .In(display_data),

    .Out(SegIn),
    .Bit(Bits)
);

//keyboard
Keyboard_CLK keyboard(
    .Button(CLKButton),
    .BasysCLK(BasysCLK),
    .CPUCLK(CPUCLK)
);



endmodule