![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94zsu1demj30nq0zygp3.jpg)

## <font size=4>一.实验目的</font>

* 设计一个单周期CPU，该CPU至少能实现算术运算指令、逻辑运算指令、移位指令、比较指令、存储器读/写指令、分支指令、跳转指令和停机指令。
* 将完成的CPU烧写到Basys3开发板上，要求通过4个数码显示器来查看CPU执行指令的情况。

## <font size=4>二.实验内容</font>

### ***<font size=3>设计一个单周期CPU，该CPU至少能实现一下指令操作</font>***

* 算术运算指令![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94lpk1y9uj315k0dsjx8.jpg)
* 逻辑运算指令![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94lrmkje7j311w0hyagj.jpg)
* 移位指令![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94lsxe3ocj316y05m76c.jpg)
* 比较指令![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94ltko4yzj314y0700vb.jpg)
* 存储器读/写指令![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94lu2ofruj312w07iwia.jpg)
* 分支指令![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94lv4cvirj311c0lm7fx.jpg)
* 跳转指令![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94lvjoo4bj310g092dkg.jpg)
* 停机指令![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94lvw2b2pj3106050abd.jpg)

实验补充要求：

```
1.指令存储器和数据寄存器存储单元都使用8位，即一个字节
的存储单位
2.PC和寄存器组写状态时使用时钟边缘触发
3.控制器部分要学会用控制信号真值表方法分析问题并写出
逻辑表达式；或者用case语句方法逐个产生各指令控制信号
4.必须按统一测试用的汇编程序段进行测试所设计的CPU。
5.在实验报告中必须有指令执行的波形（截图）且图上必须
包含关键信号，同时还要对关键信号以文字说明，这样才能
说明该指令的正确性。

```

### ***<font size=3>将设计好的CPU烧写到开发板上，满足以下用户需求</font>***

* 开关SW_in(SW15, SW14)控制七段数码管的显示内容，当SW_in = 
  
    * 00时，显示当前PC值：下条指令的PC值
    * 01时，显示RS寄存器地址：RS寄存器数据
    * 10时，显示RT寄存器地址：RT寄存器数据
    * 11时，显示ALU结果输出：DB总线数据
* 指令执行采用单步（按键控制）执行方式，由开关（SW15，SW14）控制选择查看数码管上的相关信息，地址和数据。地址或数据的输出经一下模块代码转换到数码管上。


```
module Display_7SegLED(
    input [3:0] display_data,
    output reg [7:0] dispcode
);

always @ (display_data) begin
    case(display_data)
        4'b0000 : dispcode = 8'b1100_0000; //0;'0'-亮灯，'1'-熄灯 
        4'b0001 : dispcode = 8'b1111_1001; //1
        4'b0010 : dispcode = 8'b1010_0100; //2
        4'b0011 : dispcode = 8'b1011_0000; //3
        4'b0100 : dispcode = 8'b1001_1001; //4 
        4'b0101 : dispcode = 8'b1001_0010; //5 
        4'b0110 : dispcode = 8'b1000_0010; //6 
        4'b0111 : dispcode = 8'b1101_1000; //7 
        4'b1000 : dispcode = 8'b1000_0000; //8 
        4'b1001 : dispcode = 8'b1001_0000; //9 
        4'b1010 : dispcode = 8'b1000_1000; //A 
        4'b1011 : dispcode = 8'b1000_0011; //b 
        4'b1100 : dispcode = 8'b1100_0110; //C 
        4'b1101 : dispcode = 8'b1010_0001; //d 
        4'b1110 : dispcode = 8'b1000_0110; //E 
        4'b1111 : dispcode = 8'b1000_1110; //F 
        default : dispcode = 8'b0000_0000; //不亮
    endcase
end

endmodule

``` 

* 复位信号（reset）接开关SW0，按键（单脉冲）接按键BTNR。

## <font size=4>三.实验原理</font>

单周期CPU指的是一条MIPS指令的执行在一个时钟周期内完成，然后开始下一条指令的执行，即一条指令在一个时钟周期中完成。在考虑CPU的设计时，必须决定机器的逻辑实现和机器时钟。逻辑实现即逻辑单元，跟举功能的不同可分为组合单元（处理数据的单元）和状态单元（存储数据的单元）。该实验实现CPU采用的机器时钟的时钟方法为“边沿触发的时钟”，即在时序逻辑单元中存储的所有值都只允许在时钟跳变的边沿改变（以防止数据被误写或误读）。除此之外还需要数据通路部件来将各种组合单元和状态单元通过控制信号“连接”起来。我们要做的工作便是实现各个组合单元和状态单元，然后建立起数据通路和正确决定何时发送何种控制信号，便能实现一个能读取并执行MIPS指令的CPU。

首先需要了解CPU在处理指令时，要经过哪些步骤。

* 取指令(IF)：根据程序计数器PC中的指令地址，从存储器中取出一条指令，同时，PC根据指令字长度自动递增产生下一条指令所需要的指令地址，但遇到“地址转移”指令时，则控制器把“转移地址”送入PC，当然得到的“地址”需要做些变换才送入PC。 
* 指令译码(ID)：对取指令操作中得到的指令进行分析并译码，确定这条指令需要完成的操作，从而产生相应的操作控制信号，用于驱动执行状态中的各种操作。 
* 指令执行(EXE)：根据指令译码得到的操作控制信号，具体地执行指令动作，然后转移到结果写回状态。
* 存储器访问(MEM)：所有需要访问存储器的操作都将在这个步骤中执行，该步骤给出存储器的数据地址，把数据写入到存储器中数据地址所指定的存储单元或者从存储器中得到数据地址单元中的数据。
* 结果写回(WB)：指令执行的结果或者访问存储器中得到的数据写回相应的目的寄存器中。 
单周期CPU，是在一个时钟周期内完成这五个阶段的处理。

以下是CPU的数据通路、控制信号和逻辑单元的简图：
![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94s8pnai7j31520u0gwu.jpg)

上图中，由ControlUnit来发送控制信号，它接受三个输入，指令Opcode、ALU输出的符号标记位sign和零标记位zero，根据其决定控制信号的输出，以控制各个部分执行的操作。其他的逻辑部件的功能是：

* PC决定读取指令的地址；
* 指令存储器从文件中读取指令并解码输出；
* 寄存器组接受信号并执行读寄存器和写寄存器等操作
* ALU（算术逻辑单元）接受输入并进行计算，输出结果
* 数据存储器负责存储数据和从内存中读取数据
* 符号拓展单元将16位的立即数按符号拓展为32位的数据
  
其中表中各控制信号的含义是：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94sksx13aj30z10u04a9.jpg)

相关部件和引脚说明：

* InstructMemory : 指令存储器
* Iaddr : 指令存储器地址输入端口
* IDataIn : 指令存储器数据输入端口（指令代码输入端口）
* IDataOut : 指令存储器数据输出端口（指令代码输出端口）
* RW : 指令存储器读写控制信号，为1写，为0读
* DataMemory : 数据存储器
* Daddr : 数据存储器地址输入端口
* DataIn : 数据存储器数据输入端口
* DataOut : 数据存储器数据输出端口
* RD : 数据存储器读控制信号，为1读
* WR : 数据存储器写控制信号，为1写
* RegisterFile : 寄存器组
* ReadReg1 : rs寄存器地址输入端口
* ReadReg2 : rt寄存器地址输入端口
* WriteReg : 将数据写入的寄存器端口，其地址来源rt或rd字段
* WriteData : 写入寄存器的数据输出端口
* ReadData1 : rs寄存器数据输出端口
* ReadData2 : rt寄存器数据输出端口
* WE : 写使能信号，为1时，在时钟上升沿（下降沿）写入
* ALU : 算术逻辑单元
* Result : ALU运算结果
* zero : 运算结构标志，结果为0输出1，结果为1输出0
  
其中ALU的运算功能由对应的ALUOpcode决定，下图是ALU所执行的操作与ALUOpcode对应的关系：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94sycty51j30sk0fg41n.jpg)

## <font size=4>四.实验器材</font>

* 电脑一台
* Xilinx Vivado软件一套
* Basys3开发板一块
  
## <font size=4>五.实验过程与结果

在设计CPU的时候，因为各种数据通路和控制信号错综复杂，如果想要一开始便去定义各种控制信号和数据通路，逻辑比较复杂，难度比较高。但是通过学习课本我清楚各个部分所负责的工作和具备的功能，所以我从独立性比较高的模块开始设计，最后再设计控制单元（ControlUnit）将各个模块通过数据通路和控制信号连接起来，实现整个CPU的功能。下面是我设计单周期CPU的详细过程。

该实验我在macOS系统上进行仿真，在Windows上用vivado进行烧写开发板。在macOS系统上进行仿真时，用iverilog来编译模块文件和仿真文件，用Scansion来观察输出的波形。

### <font size=3>**设计ALU**

ALU是CPU中的负责逻辑运算的模块。该模块接受5个输入：

* ReadData1 : 从rs寄存器读取的数据
* ReadData2 : 从rt寄存器读取的数据
* Ext : 从符号拓展单元读取的数据
* Sa : 直接从指令中解码得到的Shame字段
* ALUop : 从控制单元读取的ALU控制信号，根据这个决定ALU的运算功能
* ALUSrcA : 决定进行计算的数据是ReadData1还是Sa
* ALUSrcB : 决定进行计算的数据是ReadData2还是Ext

该模块输出两个信号：

* zero : 输出为0时为1，否则为0
* Result : 进行运算后的结果
  
代码如下：

```
module ALU(
        //根据数据通路定义输入和输出
        input [31:0] ReadData1,
        input [31:0] ReadData2,
        input [31:0] Ext,
        input [4:0] Sa,
        input [2:0] ALUop,
        input ALUSrcA, ALUSrcB,

        output  zero, 
        output reg [31:0] Result
    );

    //两个输入端口
    wire [31:0] InA;
    wire [31:0] InB;

    assign InA = ALUSrcA ? {{27{1'b0}}, Sa} : ReadData1;
    assign InB = ALUSrcB ? Ext : ReadData2;

    assign zero = (Result == 0) ? 1 : 0;

    //只要输入的值发生变化，就执行计算
    always @(*) begin
        case(ALUop) //根据ALUop实现相应的运算功能
            3'b000 : 
                Result = InA + InB;
            3'b001:
                Result = InA - InB;
            3'b010:
                Result = InB << InA;
            3'b011:
                Result = InA | InB;
            3'b100:
                Result = InA & InB;
            3'b101:
                Result = (InA < InB) ? 1 : 0;
            3'b110: 
                Result = (((InA < InB) && (InA[31] == InB[31])) || 
                    ((InA[31] == 1) && (InB[31] == 0))) ? 1 : 0;
            3'b111:
                Result = InA ^~ InB;
            default:
                Result = 32'h0000;
        endcase
    end

endmodule
```

下面是该模块的测试代码：

```
`include "ALU32.v"

module ALU_sim();

    //input
    reg [31:0] ReadData1;
    reg [31:0] ReadData2;
    reg [31:0] Ext;
    reg [31:0] Sa;
    reg [2:0] ALUop;
    reg ALUSrcA, ALUSrcB;

    //output
    wire zero;
    wire [31:0] Result;

    ALU uut(
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .Ext(Ext),
        .Sa(Sa),
        .ALUop(ALUop),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .zero(zero),
        .Result(Result)
    );

    initial begin
        //record
        $dumpfile("ALU32.vcd");
        $dumpvars(0, ALU_sim);

        //add1
        ReadData1 = 0;
        ReadData2 = 0;
        Ext = 1;
        Sa = 1;
        ALUop = 3'b000;
        ALUSrcA = 0;
        ALUSrcB = 0;

        //add2
        #50;
        ReadData1 = 0;
        ReadData2 = 0;
        Ext = 1;
        Sa = 1;
        ALUop = 3'b000;
        ALUSrcA = 1;
        ALUSrcB = 0;

        //add3
        #50;
        ReadData1 = 0;
        ReadData2 = 0;
        Ext = 1;
        Sa = 1;
        ALUop = 3'b000;
        ALUSrcA = 0;
        ALUSrcB = 1;

        //add4
        #50;
        ReadData1 = 0;
        ReadData2 = 0;
        Ext = 1;
        Sa = 1;
        ALUop = 3'b000;
        ALUSrcA = 1;
        ALUSrcB = 1;

        //sub1
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 3;
        Sa = 4;
        ALUop = 3'b001;
        ALUSrcA = 0;
        ALUSrcB = 0;

        //sub2
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 3;
        Sa = 4;
        ALUop = 3'b001;
        ALUSrcA = 1;
        ALUSrcB = 0;

        //sub3
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 3;
        Sa = 4;
        ALUop = 3'b001;
        ALUSrcA = 0;
        ALUSrcB = 1;

        //sub4
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 3;
        Sa = 4;
        ALUop = 3'b001;
        ALUSrcA = 1;
        ALUSrcB = 1;

        //left_shift1
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b010;
        ALUSrcA = 0;
        ALUSrcB = 0;

        //left_shift2
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b010;
        ALUSrcA = 1;
        ALUSrcB = 0;

        //left_shift3
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b010;
        ALUSrcA = 0;
        ALUSrcB = 1;

        //left_shift4
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b010;
        ALUSrcA = 1;
        ALUSrcB = 1;

        //or1
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b011;
        ALUSrcA = 0;
        ALUSrcB = 0;

        //or2
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b011;
        ALUSrcA = 1;
        ALUSrcB = 0;

        //or3
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b011;
        ALUSrcA = 0;
        ALUSrcB = 1;

        //or4
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b011;
        ALUSrcA = 1;
        ALUSrcB = 1;

        //and1
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b100;
        ALUSrcA = 0;
        ALUSrcB = 0;

        //and2
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b100;
        ALUSrcA = 1;
        ALUSrcB = 0;

        //and3
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b100;
        ALUSrcA = 0;
        ALUSrcB = 1;

        //and4
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 4;
        ALUop = 3'b100;
        ALUSrcA = 1;
        ALUSrcB = 1;

        //不带符号比较1
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b101;
        ALUSrcA = 0;
        ALUSrcB = 0;

        //不带符号比较2
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b101;
        ALUSrcA = 1;
        ALUSrcB = 0;

        //不带符号比较3
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b101;
        ALUSrcA = 0;
        ALUSrcB = 1;

        //不带符号比较4
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b101;
        ALUSrcA = 1;
        ALUSrcB = 1;

        //带符号比较1
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b110;
        ALUSrcA = 0;
        ALUSrcB = 0;

        //带符号比较2
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b110;
        ALUSrcA = 1;
        ALUSrcB = 0;

        //带符号比较3
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b110;
        ALUSrcA = 0;
        ALUSrcB = 1;

        //带符号比较4
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b110;
        ALUSrcA = 1;
        ALUSrcB = 1;

        //nor1
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b111;
        ALUSrcA = 0;
        ALUSrcB = 0;

        //nor2
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b111;
        ALUSrcA = 1;
        ALUSrcB = 0;

        //nor3
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b111;
        ALUSrcA = 0;
        ALUSrcB = 1;

        //nor4
        #50;
        ReadData1 = 1;
        ReadData2 = 2;
        Ext = 2;
        Sa = 1;
        ALUop = 3'b111;
        ALUSrcA = 1;
        ALUSrcB = 1;

        //stop
        #50;
        $stop;
    end

endmodule
```

下图是测试的波形：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94tu9e3idj31s40dgwot.jpg)

### <font size=3>**设计DataMemory**

DataMemory用于将数据存储到内存中和从内存中读取数据，该模块接受4个输入：

* CLK : 时钟信号，只允许在时钟下降沿进行写操作
* DAddr : 读取或写数据的地址
* DataIn : 要进行写操作的数据
* RD : 为0进行写操作，为1无操作
* WR : 为0进行读操作，为1输出高阻态
  
该模块输出数据32位DataOut，允许读时输出从内存读出的数据，不允许读时输出高阻态。

模块代码为：

```
module DataMemory(
    input CLK,
    input wire [31:0] DAddr,  //地址输入
    input wire [31:0] DataIn,//    
    input RD,             //为0，写；为1，无操作
    input WR,              //为0，正常读；为1，输出高组态
    
    output wire [31:0] DataOut
);

reg [7:0] Memory [0:127];//存储器
wire [31:0] address;

//因为一条指令由四个存储单元存储所以要乘以4
assign address = (DAddr << 2);


//读
assign DataOut[7:0] = (RD == 0) ? Memory[address + 3] : 8'bz;//z为高阻态
assign DataOut[15:8] = (RD == 0) ? Memory[address + 2] : 8'bz;
assign DataOut[23:16] = (RD == 0) ? Memory[address + 1] : 8'bz;
assign DataOut[31:24] = (RD == 0) ? Memory[address] : 8'bz;

//写
always @ (negedge CLK) begin
    if(WR == 0) begin
        Memory[address] <= DataIn[31:24];
        Memory[address + 1] <= DataIn[23:16];
        Memory[address + 2] <= DataIn[15:8];
        Memory[address + 3] <= DataIn[7:0];
    end
end
 
endmodule
```

补充说明：因为实验要求数据存储器的存储单元限制为8位，所以要用4个存储单元来存储一个32位的数据。

测试代码为：

```
`include"DataMemory.v"

module DataMemory_sim;

    // input
    reg CLK;
    reg [31:0] DAddr;
    reg [31:0] DataIn;
    reg RD;
    reg WR;

    //otput
    wire [31:0] DataOut;

    DataMemory uut(
        .CLK(CLK),
        .DAddr(DAddr),
        .DataIn(DataIn),
        .RD(RD),
        .WR(WR),
        .DataOut(DataOut)
    );

    always #15 CLK = !CLK;

    initial begin
        //record
        $dumpfile("DataMemory.vcd");
        $dumpvars(0, DataMemory_sim);

        //初始化
        CLK = 0;
        DAddr = 0;
        DataIn = 0;
        RD = 1;    //为0，正常读；为1，输出高阻态（相当于开路）
        WR = 1;   //为0，写；为1，无操作

        #30;//30ns后，CLK下降沿写
            DAddr = 8;
            DataIn = 8;
            RD = 1;
            WR = 0;

        #30;//60ns后，CLK下降沿写
            DAddr = 12;
            DataIn = 12;
            RD = 1;
            WR = 0;

        #30;//90ns后开始读
            DAddr = 8;
            RD = 0;
            WR = 1;

        #30;//120ns后开始读
            DAddr = 12;
            RD = 0;
            WR = 1;

        #30;
            $stop;//150ns后停

    end

endmodule

```

测试波形为：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94ud4x9xij31re0b0n5z.jpg)

### <font size=3>**设计InstructionMemory**

指令存储器模块接受来自PC的地址并从存储器中取出指令并进行解码，然后输出解码后的字段。该模块接受3个输入：

* PC4 : 当前PC的前4位，用于补全跳转指令PC的前四位
* IAddr : 指令的地址
* RW : 为0时写，为1时读指令（在该实验中不需要写指令，所以RW恒为1）
  
输出为：

* op : 输出到控制单元决定控制信号的输出
* rs : rs寄存器地址
* rt : rt寄存器地址
* rd : rd寄存器地址
* Immediate : 立即数
* Sa : Shamt位移字段
* JumpPC : 跳转PC的地址

模块代码为：

```
module InstructionMemory(
    input [3:0] PC4,
    input [31:0] IAddr,
    input RW,//0 write, 1 read

    output [5:0] op,
    output [4:0] rs, rt, rd,
    output [15:0] Immediate,
    output [4:0] Sa,
    output [31:0] JumpPC
);

//因为实验要求指令存储器和数据存储器单元宽度一律使用8位，
//因此将一个32位的指令拆成4个8位的存储器单元存储

//从文件中取出后将他们合并为32的指令
reg [7:0] Mem[0:127];
reg [31:0] IDataOut;

assign op = IDataOut[31:26];
assign rs = IDataOut[25:21];
assign rt = IDataOut[20:16];
assign rd = IDataOut[15:11];
assign Immediate = IDataOut[15:0];
assign Sa = IDataOut[10:6];
assign JumpPC = {{PC4}, {IDataOut[27:2]}, {2'b00}};

initial begin
    $readmemb("Instructions.txt", Mem);//从文件中读取指令集
    IDataOut = 0;//指令初始化
end

always @(IAddr or RW) begin
    if(RW == 1) begin
        IDataOut[7:0] = Mem[IAddr + 3];
        IDataOut[15:8] = Mem[IAddr + 2];
        IDataOut[23:16] = Mem[IAddr + 1];
        IDataOut[31:24] = Mem[IAddr];
    end
end

endmodule
```

补充说明：因为实验要求指令存储器存储单元一律使用8位，因此将一个32
位的指令拆成4个8位的存储单元存储

测试代码为：

```
`include"InstructionMemory.v"
`timescale 1ns / 1ps

module IM_sim;

//inputs
reg [31:0] IAddr;
reg RW;

//output
wire [5:0] op;
wire [5:0] rs, rt, rd;
wire [15:0] Immediate;
wire [5:0] Sa;

InstructionMemory uut(
    .IAddr(IAddr),
    .RW(RW),
    .op(op),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .Immediate(Immediate),
    .Sa(Sa)
);

initial begin
    //record
    $dumpfile("IM.vcd");
    $dumpvars(0, IM_sim);

    //initial 
    #10;
    RW = 0;
    IAddr[31:0] = 32'd0;

    //read instruction
    #50;
    RW = 1;
    IAddr[31:0] = 32'd0;

    //read instruction
    #50;
    RW = 1;
    IAddr[31:0] = 32'd4;

    //read instruction
    #50;
    RW = 1;
    IAddr[31:0] = 32'd8;

    //finish
    #10;
    $stop;

end

endmodule
```

下图为测试波形：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94uyexdhoj31rm0bqagf.jpg)

### <font size=3>**设计PC**

PC模块接受一个控制信号，决定将PC+4还是PC+4+Immedate还是PC + 4 + JumpPC送入到指令存储器进行指令读取。该模块有6个输入：

* CLK : 时钟信号，只允许在时钟的下降沿输出PC
* Reset : PC置零信号
* PCWre : 为1时才允许改变地址
* PCSrc : 决定输出的是何种PC
* Immediate : 跳转指令位移
* JumpPC : 无条件跳转指令地址

有3个输出：

* Address : 输出指令的地址到指令存储器取出指令
* nextPC : 下一条指令的地址，为7段数码管显示用
* PC4 : 无条件跳转指令高4位填补用

模块代码为：

```
module PC(
    input CLK, Reset, PCWre,
    input [1:0] PCSrc, 
    input signed [15:0] Immediate,   //从指令中取出符号拓展而来
    input [31:0] JumpPC,//跳转地址

    output reg signed [31:0] Address,
    output [31:0] nextPC,
    output [3:0] PC4
);

assign nextPC = (PCSrc[0]) ? Address + 4 + (Immediate << 2) : ((PCSrc[1]) ?  JumpPC : Address + 4);

assign PC4 = Address[31:28];
//当clock下降沿到来或Reset下降沿到来时，对地址进行改变或者置零
always @(negedge CLK or negedge Reset) begin
    if(Reset == 0)
        Address = 0;
    else if(PCWre) begin//PCWre为1时才允许更改地址
        if(PCSrc[0])
            Address = Address + 4 + (Immediate << 2);//跳转
        else if(PCSrc[1])
            Address = JumpPC;
        else
            Address = Address + 4;//顺序执行下一条指令
    end
end

endmodule
```

测试代码为：

```
`include"PC.v"

module PC_sim();

    //inputs
    reg CLK;
    reg Reset;
    reg PCWre;
    reg PCSrc;
    reg [15:0] Immediate;

    //outputs
    wire [31:0] Address;

    PC uut(
        .CLK(CLK),
        .Reset(Reset),
        .PCWre(PCWre),
        .PCSrc(PCSrc),
        .Immediate(Immediate),
        .Address(Address)
    );

    always #15 CLK = !CLK;

    initial begin
        //record
        $dumpfile("PC.vcd");
        $dumpvars(0, PC_sim);

        //初始化
        CLK = 0;
        Reset = 0;
        PCWre = 0;
        PCSrc = 0;
        Immediate = 0;

        //不跳转，顺序执行下一条地址
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 0;
        Immediate = 4;

        //不跳转，顺序执行下一条地址
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 0;
        Immediate = 4;

        //不跳转，顺序执行下一条地址
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 0;
        Immediate = 4;

        //不跳转，顺序执行下一条地址
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 0;
        Immediate = 4;

        //跳转，执行跳转之后的指令
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 1;
        Immediate = 4;

        //跳转，执行跳转之后的指令
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 1;
        Immediate = 4;

        //跳转，执行跳转之后的指令
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 1;
        Immediate = 4;

        //结束
        #100;
        $stop;
    end

endmodule

```

波形为：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94va2wjefj31s00b4gv4.jpg)

### <font size=3>**设计RegisterFile**

寄存器组负责从寄存器的读写操作，该模块接受9个输入：

* CLK : 时钟信号，当时钟下降沿时才能进行写操作
* RegDst : RegDst为真时，处理R型指令，rd为目标操作数寄存器，为假时处理I型指令， rt为目标操作数寄存器
* RegWre : 为1时才允许进行写操作
* DBDataSrc : 选择写的数据是来自ALU还是数据存储器
* rs : rs寄存器地址
* rt : rt寄存器地址
* rd : rd寄存器地址
* dataFromALU : 来自ALU输出的数据
* dataFromRW : 来自数据存储器的数据

该模块输出为：

* Data1 : 输出的第一个数
* Data2 : 输出的第二个数
* writeData : 要进行写的数据，放在输出端口为了在7段数码管上显示

模块代码为：

```
module RegisterFile(
    input CLK, RegDst, RegWre, DBDataSrc,
    // input [5:0] Opcode,
    input [4:0] rs, rt, rd,
    // input [10:0] im,
    input [31:0] dataFromALU, dataFromRW,

    output [31:0] Data1, Data2,
    output [31:0] writeData
);

wire [4:0] writeReg;//要写的寄存器端口

//RegDst为真时，处理R型指令，rd为目标操作数寄存器，为假时处理I型指令
//详见控制信号作用表
assign writeReg = RegDst ? rd : rt;

//ALUM2Reg为0时，使用来自ALU的输出，为1时，使用来自数据存储器（DM）
//的输出，详见控制信号作用表
assign writeData = DBDataSrc ? dataFromRW : dataFromALU;

//初始化寄存器
reg [31:0] register[0:31];
integer i;
initial begin
    for(i = 0;i < 32;i++) 
        register[i] <= 0;
end

//output:随register的变化而变化
//Data1为ALU运算时的A，当指令为sll时，A的值从立即数的16位获得
//Data2为ALU运算中的B，其值始终为rt
// assign Data1 = (Opcode == 6'b011000) ? im[10:6] : register[rs];
assign Data1 = register[rs];
assign Data2 = register[rt];

always @ (negedge CLK) begin
    if(RegWre && writeReg)
        register[writeReg] <= writeData;//防止数据写进0号寄存器
end

endmodule 

```

测试代码为：

```
`include"RegisterFile.v"

//测试文件

module RegFile_sim();
    //inputs
    reg CLK, RegDst, RegWre, DBDataSrc;
    reg [5:0] Opcode;
    reg [4:0] rs, rt, rd;
    reg [10:0] im;
    reg [31:0] dataFromALU, dataFromRW;

    //ouputs
    wire [31:0] Data1;
    wire [31:0] Data2;

    RegisterFile uut(
        .CLK(CLK),
        .RegDst(RegDst),
        .RegWre(RegWre),
        .DBDataSrc(DBDataSrc),
        .Opcode(Opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .im(im),
        .dataFromALU(dataFromALU),
        .dataFromRW(dataFromRW),

        .Data1(Data1),
        .Data2(Data2)
    );

    always #15 CLK = !CLK;

    initial begin
        //record
        $dumpfile("RegisterFile.vcd");
        $dumpvars(0, RegFile_sim);

        //初始化
        CLK = 0;

        //Test1
        #10;
        CLK = 0;
        RegDst = 1;//处理R型指令
        RegWre = 1;//允许写寄存器
        DBDataSrc = 0;//使用来自ALU的输出
        Opcode = 6'b000000;//没用...
        rs = 5'b00000;
        rt = 5'b00001;
        rd = 5'b00010;
        im = 11'b0;
        dataFromALU = 32'd1;//来自ALU的输出
        dataFromRW = 32'd2;//来自RW的输出

        //Test2
        #100;
        RegDst = 0;//处理R型指令
        RegWre = 0;//允许写寄存器
        DBDataSrc = 1;//使用来自ALU的输出
        Opcode = 6'b000000;//没用...
        rs = 5'b00011;
        rt = 5'b00100;
        rd = 5'b00101;
        im = 11'd10;
        dataFromALU = 32'd3;//来自ALU的输出
        dataFromRW = 32'd4;//来自RW的输出

        //stop，需要的测试在debug阶段再写吧
        $stop;
    end


    
endmodule

```

输出波形为：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94vn4vyzvj31s00hu17h.jpg)

### <font size=3>**设计SignZeroExtend**

符号拓展单元对16位立即数按符号拓展为32位的数据，用于跳转指令和I型指令。该模块有两个输入：

* Immediate : 所要拓展的16位立即数
* ExtSel : 为1高位补符号位，为0高位补0

输出32位数据Out。

模块代码为：

```


module SignZeroExtend(
    //根据数据通路定义输入和输出
    input wire [15:0] Immediate,
    input ExtSel,
    output wire [31:0] Out
);

//后16位存储立即数
assign Out[15:0] = Immediate[15:0];
//前16位根据立即数进行补1或补0的操作
assign Out[31:16] = ExtSel == 1 ? {16{Immediate[15]}} : 16'b0;
    
endmodule

```

测试代码为：

```
`include"SignZeroExtend.v"

module SignZeroExtend_sim();

//inputs
reg signed [15:0] Immediate;
reg ExtSel;

//outputs
wire [31:0] Out;

SignZeroExtend uut(
    .Immediate(Immediate),
    .ExtSel(ExtSel),
    .Out(Out)
);

initial begin
    //record
    $dumpfile("SignZeroExtend.vcd");
    $dumpvars(0, SignZeroExtend_sim);

    //初始化(好像不用）
    #50;
    ExtSel = 0;
    Immediate[15:0] = 15'd7;

    //Test1
    #50;
    ExtSel = 1;
    Immediate[15:0] = 15'd10;

    //Test2
    #50;
    ExtSel = 1;
    Immediate[15:0] = 15'd7;
    Immediate[15] = 1;

    //stop
    #50;
    $stop;
end

endmodule

```

测试波形为：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94vtt9hz3j31ri07wjwp.jpg)

### <font size=3>**设计ControlUnit**

设计完各个模块之后，接下来的工作便是将设计控制单元，对控制信号进行准确的输出，以控制其他模块进行正确的操作。控制单元接受两个输出：

* Opcode : 根据Opcode决定控制信号的输出
* zero : 有些信号还需要根据zero的值来确定输出

设计控制单元必须列出控制信号和指令的关系：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94vymw7enj30fk04ct9t.jpg)

然后根据该表assign对应的值:

```
module ControlUnit(
    //根据数据通路图定义输入和输出
    input [5:0] OpCode,
    input zero,

    output PCWre,
    output ALUSrcA, 
    output ALUSrcB,
    output DBDataSrc,
    output RegWre,
    output InsMemRW,
    output RD,
    output WR,
    output ExtSel,
    output RegDst,
    output [1:0] PCSrc,
    output [2:0] ALUOp
);



    //根据opcode定义控制信号为1或0
    assign PCWre = (OpCode == 6'b111111) ? 0 : 1;
    assign ALUSrcA = (OpCode == 6'b011000) ? 1 : 0;
    assign ALUSrcB = (OpCode == 6'b000010 || OpCode == 6'b010000 || OpCode == 6'b010010
        || OpCode == 6'b100110 || OpCode == 6'b100111 || OpCode == 6'b011100) ? 1 : 0;
    assign DBDataSrc = (OpCode == 6'b100111) ? 1 : 0;
    assign RegWre = (OpCode == 6'b100110 || OpCode == 6'b110001 || OpCode == 6'b110010) ? 0 : 1;
    assign InsMemRW = 1;
    assign RD = (OpCode == 6'b100111) ? 0 : 1;
    assign WR = (OpCode == 6'b100110) ? 0 : 1;
    assign ExtSel = (OpCode == 6'b010000 || OpCode == 6'b010010) ? 0 : 1;
    assign RegDst = (OpCode == 6'b000010 || OpCode == 6'b010000 || OpCode == 6'b010010
        || OpCode == 6'b011100 || OpCode == 6'b100111) ? 0 : 1;
    assign PCSrc[0] = ((OpCode == 6'b110000 && zero == 1) || (OpCode == 6'b110010 && zero == 0)) ? 1 : 0;
    assign PCSrc[1] = (OpCode == 6'b111000) ? 1 : 0;
    assign ALUOp[2] = (OpCode == 6'b010000 || OpCode == 6'b010001 || OpCode == 6'b011100 || OpCode == 6'b110010) ? 1 : 0;
    assign ALUOp[1] = (OpCode == 6'b010010 || OpCode == 6'b010011 || OpCode == 6'b011000 || OpCode == 6'b110010) ? 1 : 0;
    assign ALUOp[0] = (OpCode == 6'b000001 || OpCode == 6'b010010 
        || OpCode == 6'b011100 || OpCode == 6'b010011 || OpCode == 6'b110000) ? 1 : 0;
endmodule
```

### <font size=3>**设计SingleCycleCPU**

设计完各个模块之后，接下来的工作是将各个模块的接口连接起来，组合成一个完整的SigleCycleCPU模块。模块代码为：

```
`include"../ALU/ALU32.v"
`include"../ControlUnit/CU.v"
`include"../DataMemory/DataMemory.v"
`include"../InstructionMemory/InstructionMemory.v"
`include"../PC/PC.v"
`include"../RegisterFile/RegisterFile.v"
`include"../SignZeroExtend/SignZeroExtend.v"


module SingleCycleCPU(
    input CLK, Reset,
    output [4:0] rs, rt,
    output wire [5:0] Opcode,
    output wire [31:0] Out1, Out2, curPC, nextPC, Result, DBData
);

wire [2:0] ALUOp;
wire [31:0] Extout, DMOut;
wire [15:0] Immediate;
wire [4:0] rd;
wire [4:0] sa;
wire [31:0] JumpPC;
wire zero, PCWre, ALUSrcA, ALUSrcB, DBDataSrc, ReWre;
wire InsMemRW, RD, WR, ExtSel, RegDst;
wire [1:0] PCSrc;
wire [3:0] PC4;

ALU alu(Out1, Out2, Extout, sa, ALUOp, ALUSrcA, ALUSrcB, zero, Result);
PC pc(CLK, Reset, PCWre, PCSrc, Immediate, JumpPC, curPC, nextPC, PC4);
ControlUnit CU(Opcode, zero, PCWre, ALUSrcA, ALUSrcB, DBDataSrc, ReWre, InsMemRW, RD, WR, ExtSel, RegDst, PCSrc, ALUOp);
DataMemory DM(CLK, Result, Out2, RD, WR, DMOut);
InstructionMemory IM(PC4, curPC, InsMemRW, Opcode, rs, rt, rd, Immediate, sa, JumpPC);
RegisterFile RF(CLK, RegDst, ReWre, DBDataSrc, rs, rt, rd, Result, DMOut, Out1, Out2, DBData);
SignZeroExtend SZE(Immediate, ExtSel, Extout);

endmodule

```

接下来对整个CPU进行测试：

```
`include"SingleCycleCPU.v"

module SingleCycleCPU_sim();

    //inputs
    reg CLK;
    reg Reset;

    //Outputs
    wire [31:0] Out1;
    wire [31:0] Out2;
    wire [31:0] curPC;
    wire [31:0] Result;
    wire [5:0] Opcode;

    //instantiate the Unit Under Test
    SingleCycleCPU uut(
        .CLK(CLK),
        .Reset(Reset),
        .Opcode(Opcode),
        .Out1(Out1),
        .Out2(Out2),
        .curPC(curPC),
        .Result(Result)
    );

    initial begin 
        //record 
        $dumpfile("SCCPU.vcd");
        $dumpvars(0, SingleCycleCPU_sim);

        //innitial inputs
        CLK = 0;
        Reset = 0;//刚开始设置PC为0

        #50;
        CLK = 1;

        #50;
        Reset = 1;

        //产生时钟信号
        forever #50 begin
            CLK = !CLK;
        end

    

    end

endmodule

```

输出的波形是：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94wehaqofj31s20can98.jpg)
![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94wey5638j31s00d4dsl.jpg)
![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94wf762kaj31si0fstm2.jpg)

其中要执行的指令存储在Instructions.mem文件中，指令内容和对应的机器码为：

```
addiu $1, $0, 8     000010 00000 00010 0000000000001000
ori $2, $0, 2       010010 00000 00010 0000000000000010
add $3, $2, $1      000000 00010 00001 00011 00000000000
sub $5, $3, $2      000001 00011 00010 00101 00000000000
and $4, $5, $2      010001 00101 00010 00100 00000000000
or $8, $4, $2       010011 00100 00010 01000 00000000000
sll $8, $8, 1       011000 00000 01000 01000 00001 000000
bne $8, $1, -2(!=, 转18)    
                    110001 01000 00001 1111111111111110
slti $6, $2, 4      011100 00010 00110 0000000000000100
slti $7, $6, 0      011100 00110 00111 0000000000000000
addiu $7, $7, 8     000010 00111 00111 0000000000001000
beq $7, $1, -2(=转28)
                    110000 00111 00001 1111111111111110
sw $2, 4($1)        100110 00001 00010 0000000000000100
lw $9, 4($1)        100111 00001 01001 0000000000000100
addiu $10, $0, -2   000010 00000 01010 1111111111111110
addiu $10, $10, 1   000010 01010 01010 0000000000000001
bltz $10, -2(<0,转3c)
                    110010 01010 00000 1111111111111110
andi $11, $2, 2     010000 00010 01011 0000000000000010
j 0x00000050        111000 00000000000000000001010000
or $8, $4, $2       010011 00100 00010 00100 00000000000
halt(stop)          11111100000000000000000000000000

```

#### <font size = 3>***add指令***</font>

`add $3, $0, 2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94wob2d36j30fo0a0dk1.jpg" height = 50% width = 50%/>

#### <font size = 3>***sub指令***</font>

`sub $5, $3, $2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94wpzz34tj30fe0ae78x.jpg" height = 50% width = 50%/>


#### <font size = 3>***addiu指令***</font>

`addiu $1, $0, 8`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94wr82ujvj30hq0asaf9.jpg" height = 50% width = 50%/>

#### <font size = 3>***andi指令***</font>

`andi $11, $2, 2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94wv1emuvj30fm0bcjwn.jpg" height = 50% width = 50%/>

#### <font size = 3>***and指令***</font>

`and $4, $5, $2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94wwzufrbj30fo0beafb.jpg" height = 50% width = 50%/>

#### <font size = 3>***ori指令***</font>

`ori $2, $0, 2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94wyrd2atj30fo0bgwjy.jpg" height = 50% width = 50%/>

#### <font size = 3>***or指令***</font>

`or $8, $4, $2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94x2k3xzdj30fu0baaeq.jpg" height = 50% width = 50%/>

#### <font size = 3>***sll指令***</font>

`sll $8, $8, 1`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94x3der73j30f60asgpu.jpg" height = 50% width = 50%/>

#### <font size = 3>***slti指令***</font>

`slti $6, $2, 4`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94x4ha8y3j30fi0bq434.jpg" height = 50% width = 50%/>

#### <font size = 3>***sw指令***</font>

`sw $2, 4($1)`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94x5qsnixj30fu0bcn1w.jpg" height = 50% width = 50%/>

#### <font size = 3>***beq指令***</font>

`beq $7, $1, -2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94x6z6nhmj30k20buafb.jpg" height = 50% width = 50%/>

#### <font size = 3>***bne指令***</font>

`bne $8, $1, -2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94x89hrudj30jy0audkp.jpg" height = 50% width = 50%/>

#### <font size = 3>***bltz指令***</font>

`bltz $10, -2`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94x93xvcdj30ko0cwjxe.jpg" height = 50% width = 50%/>

#### <font size = 3>***addr指令***</font>

`j 0x00000050`

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94xaevwf1j317c0asagj.jpg" height = 50% width = 50%/>

### <font size = 3>进行Basys烧写开发板</font>

设计思想：

* 实现CPU在板上运行需要两个时钟信号，CPU工作时钟和Basys3板系统时钟。CPU 工作时钟即为按键，是CPU正常工作时钟信号，按键必须进行消抖处理;Basys3板系 统时钟即为板提供的正常工作时钟信号，即为100MHZ。Basys3板系统时钟信号引脚 对应管脚W5。
* 每个按键周期，4个数码管都必须刷新一次。数码管位控信号 AN3-AN0是 1110、1101、1011、0111，为0时点亮该数码管，当然，还应该为数码管各位 “1gfedcba”引脚输出信号，最高位为“1”。比如，“当前PC值”低8位中的高4位和低4 位，必须经下页转换后送给数码管各引脚。

综上，显示模块大概分为4个部分：

* 对Basys3板系统时钟信号进行分频，分频的目的用于计数器
* 生成计数器，计数器用于产生4个数。这4数用于控制4个数码管
* 根据计数器产生的数生成数码管相应的位控信号(输出)和接收CPU来的相应数据
* 将从CPU 接收到的相应数据转换为数码管显示信号，再送往数码管显示(输出)

#### <font size = 2>分频模块</font>


时钟分频的原理是定义一个计数器cnt，每当原始时钟（开发板的时钟BasysCLK）到来时加一。当计数器满2^N - 1后，再将分频时钟CLK_SLow翻转一次，这样就将CLK进行了2^N分频

```
module CLK_slow(
    input CLK_100mhz,//100mhz的原始时钟信号
    
    output reg CLK_slow//输出的分频时钟信号
);

reg [31:0] count = 0;//计数器
reg [31:0] N = 50000;//分频2^19，得到一个周期大约5ms的信号

initial CLK_slow = 0;

always @ (posedge CLK_100mhz) begin
    if(count >= N) begin
        count <= 0;
        CLK_slow <= ~CLK_slow;
    end
    else
        count <= count + 1;

end

endmodule 

```

#### <font size = 2>消抖模块</font>
为什么要消抖？见下图：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94xpymnsqj309b04naa6.jpg)

我们可以看到，但按键按下的那一刻，存在一段时间的抖动，同时在释放按键的一段时间里也是存在抖动的，这就可能导致状态在识别的时候可能检测为多次的按键，因为运行过程中普通的检测一次状态key为1就执行一次按键操作。所以我们在使用按键时往往需要消抖。

输入消抖模块同样使用了N位一个计数器cnt，当时钟信号到来时，如果按键处于按下状态就将计数器+1，而如果现按键未按下，则清空计数器。将模块输出的防抖按键信号连接到cnt第N位，这样就保证持续按下2^N个时钟周期的时间才会输出按键信号，从而屏蔽了短暂的抖动信号。

```
module Keyboard_CLK(
    input Button,
    input BasysCLK,

    output  CPUCLK
);


// parameter DURATION = 5; //test
// reg [10:0] cnt;

// initial CPUCLK = 0;
// initial cnt = 0;

// always @ (posedge BasysCLK) begin
//     if(Button == 1) begin
//         if(cnt == DURATION) 
//             cnt <= cnt;
//         else
//             cnt <= cnt + 1'b1;
//     end
//     else 
//         cnt <= 11'b0;
// end

// always @ (cnt) begin
//     if(cnt == DURATION) 
//         CPUCLK = !CPUCLK;
// end

// endmodule

reg button_previous_state;
reg button_current_state;

wire button_edge;

always @ (posedge BasysCLK) begin
    button_current_state <= Button;
    button_previous_state <= button_current_state;
end

assign button_edge = button_previous_state & (~button_current_state);

reg [20:0] counter;

always @ (posedge BasysCLK) begin
    if(button_edge)
        counter <= 21'h0;
    else
        counter <= counter + 1;
end

reg delayed_button_previous_state;
reg delayed_button_current_state;

//21'h1E8480
always @ (posedge BasysCLK) begin
    if(counter == 21'h1E8480) 
        delayed_button_current_state <= button_current_state;
    delayed_button_previous_state <= delayed_button_current_state;
end

assign CPUCLK = delayed_button_previous_state & (~delayed_button_current_state);

endmodule

```

#### <font size = 2>显示模块</font>

原理是，当输入一个4位的控制信号display_data时，输出一个8位的信号，将这个信号输入给7段数码管的引脚，就可以让数码管输出对应的数字。

```
module Display_7SegLED(
    input [3:0] display_data,
    output reg [7:0] dispcode
);

always @ (display_data) begin
    case(display_data)
        4'b0000 : dispcode = 8'b1100_0000; //0;'0'-亮灯，'1'-熄灯 
        4'b0001 : dispcode = 8'b1111_1001; //1
        4'b0010 : dispcode = 8'b1010_0100; //2
        4'b0011 : dispcode = 8'b1011_0000; //3
        4'b0100 : dispcode = 8'b1001_1001; //4 
        4'b0101 : dispcode = 8'b1001_0010; //5 
        4'b0110 : dispcode = 8'b1000_0010; //6 
        4'b0111 : dispcode = 8'b1101_1000; //7 
        4'b1000 : dispcode = 8'b1000_0000; //8 
        4'b1001 : dispcode = 8'b1001_0000; //9 
        4'b1010 : dispcode = 8'b1000_1000; //A 
        4'b1011 : dispcode = 8'b1000_0011; //b 
        4'b1100 : dispcode = 8'b1100_0110; //C 
        4'b1101 : dispcode = 8'b1010_0001; //d 
        4'b1110 : dispcode = 8'b1000_0110; //E 
        4'b1111 : dispcode = 8'b1000_1110; //F 
        default : dispcode = 8'b0000_0000; //不亮
    endcase
end

endmodule


```

#### <font size = 2>选择模块</font>

接受4个要显示的数据和一个决定显示哪个数据的控制信号SelectCode，然后输出对应的display_data给显示模块

```
module Select(
    input [15:0] In1, In2, In3, In4,
    input [1:0] SelectCode,

    output reg [15:0] DataOut
);

always @ (*) begin
    case (SelectCode)
        2'b00 : DataOut = In1;
        2'b01 : DataOut = In2;
        2'b10 : DataOut = In3;
        2'b11 : DataOut = In4;
    endcase
end

endmodule

```

#### <font size = 2>转换模块</font>

对输入的时钟信号和数据进行转换并输出

```
module Transfer(
    input CLK,
    input [15:0] In,

    output reg [3:0] Out,
    output reg [3:0] Bit
);


integer i;
initial begin 
    i = 0;
end

always @ (negedge CLK) begin
    case(i)
        0 : begin
            Out = In[15:12];
            Bit = 4'b1110;
        end
        1 : begin
            Out = In[11:8];
            Bit = 4'b1101;
        end
        2 : begin
            Out = In[7:4];
            Bit = 4'b1011;
        end
        3 : begin
            Out = In[3:0];
            Bit = 4'b0111;
        end
    endcase
    i = (i == 3) ? 0 : i + 1;
end

endmodule

```

#### <font size = 2>Basys3模块：连接所有模块</font>

Basys3模块连接以上5个与显示有关模块和CPU模块，最终烧写进开发板里面。

```
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

```

同时进行了测试，测试中认为产生按键时钟，测试代码为：

```
`include"Basys3.v"

module basys_sim(

    );
    reg CLK, RST;
    reg CLKButton;
    reg [1:0] SW;
    
    Basys3 test(
        .BasysCLK(CLK),
        .CLKButton(CLKButton),
        .SW_in(SW),
        .RST_Button(RST),
        
        
        .SegOut(),
        .Bits()
    );
    integer i;

    initial begin
        //recode 
        $dumpfile("Basys3.vcd");
        $dumpvars(0, basys_sim);

        CLK = 0;
        RST = 0;
        CLKButton = 0;
        SW = 2'b00;

        #50;
        RST = 1;
        for (i = 0; i < 1000000; i = i + 1) begin
            #100;
            CLK = ~CLK;
//            #10;
            if (i % 15 == 0) CLKButton = ~CLKButton;
        end

       
    end
endmodule

```

产生的波形为：![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94y7jfhnuj324q0dqwrv.jpg)

可以看出产生了正确的ButtonCLK

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g94y8tm39oj31t30u0e81.jpg)

CPU也正确处理了指令

#### <font size = 2>正式开始烧写开发板</font>

PS : 所有检验均只列举前4条指令

* 验证PC :  nextPC 正确性（最后一张为Reset操作）

  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94ycp2ihqj31400u0jvn.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94ycl6auej31400u0q71.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94ycn8fmaj31400u0q77.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94ycp2ihqj31400u0jvn.jpg" height = 50% width = 50%/>
  </br>

* 验证rs寄存器地址 : rs数据 正确性

  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yfa6tnxj31400u0tcb.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yfa6tnxj31400u0tcb.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yfc5el9j31400u0jvl.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yfduqj3j31400u00ws.jpg" height = 50% width = 50%/>
   </br>

* 验证rt寄存器地址 : rt数据 正确性

  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yh6v8rij31400u0q72.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yh8voijj31400u0wif.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yhaec9jj31400u078g.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yhci1rlj31400u0q6v.jpg" height = 50% width = 50%/>
 

* 验证ALUResult : DBData 正确性

  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yin2lnpj31400u0dk3.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yiojwx5j31400u042q.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yiq0nbyj31400u0q72.jpg" height = 50% width = 50%/>
  <img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g94yirfy25j31400u0q71.jpg" height = 50% width = 50%/>
  </br>


## <font size = 4>实验心得</font>

在这次设计单周期CPU的实验中，我学到了许多许多，遇到了很多问题，但也尝到了很多解决问题后的快感。以下是我在这次实验中遇到的一些重要问题，以及解决方法：

* 第一个问题：如果在macOS上设计模块并进行仿真？因为我主要用的电脑是MacBookPro，并且觉得vivado的使用并不方便，因此上google和bing查找了相关资料，掌握了在macOS上编译并查看仿真波形的方法：
  * 下载iverilog和Scansion，可以在命令行上执行命令`iverilog -o xxx.out xxx.v`来进行编译，然后执行命令`open -a Scansion xxx.vcd`来查看波形（需要在仿真文件里面添加`$dumpfiles("xxx.vcd")；`和`$dumpvars(0, xxx_sim)；`）
  * 在vscode中下载插件Verilog和VerilogHDL，可以在vscode中编译.v文件，生成一个.out文件，执行这个.out文件也可以得到一个.vcd文件，执行命令`open -a Scansion xxx.vcd`也可以查看波形。

* 第二个问题：如何判断设计的模块是否正确？如果只是用肉眼去看代码，去寻找逻辑错误是非常愚蠢的行为。为了解决这个问题，我采用的方法是编写测试代码进行仿真，从得到的输出波形中可以很容易debug。波形中含有各种信号的值，不需要打短点，也不需要打日志，是一种非常有效的debug方法。因此我在设计每一个模块中都编写了测试文件。编写测试文件的另外一个好处在于，如果连接模块中出现问题，可以如果输入的信号不正确，可以从输入的模块中检查输出信号正确与否。编写测试代码是一种很有效的debug方式。
* 第三个问题：有一些模块的逻辑很复杂，如何去设计这些模块？比如controlUnit，需要控制的信号非常多，一开始并不知道如何入手，逻辑难以理清楚。这种情况下，我采用参考博客+理解课本的方式来解决。通过参考晚上的博客，可以大致了解需要设计哪些部件；理解课本可以让debug更加方便。如果只是囫囵吞枣，将博客的代码套过来用的话，debug会让你怀疑人生。我结合了博客和课本的知识，写出了属于自己的代码。
* 第四个问题：烧写开发板不正确的话如何解决？我在第一次烧写开发板的时候，按下nextPC按钮之后，PC却没有跳转。我因此很怀疑是不是板子坏了，但借了别人板子结果还是一样，于是确定了是代码问题。因此我编写了测试代码，自动生成按键时钟，通过输出波形终于发现了问题。改了代码之后再去烧，PC还是不跳，于是我返回去看代码，终于明白了原因：Reset没有调回1，这个问题解决后就成功烧写开发板了，自此我懂得，找寻问题的根源是解决问题的根本方法，盲目肉眼看代码和重复调试只是无谓之举
