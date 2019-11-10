module RegisterFile(
    input wire [4:0] ReadReg1,  //rs寄存器地址输入端口
    input wire [4:0] ReadReg2,  //rt寄存器地址输入端口
    input wire [4:0] WriteReg,  //存储写入数据的寄存器号
    input wire [31:0] WriteData,//写入寄存器组的数据
    input CLK, RegWre, RST,     //CLK为时钟沿信号，Reg为写能信号，RST为重置信号

    output wire [31:0] ReadData1,//从寄存器号为ReadReg1的寄存器读出的数据
    output wire [31:0] ReadData2//从寄存器号为ReadReg2的寄存器读出的数据
);

reg [31:0] RegFile[1:31];//寄存器组
integer i;//临时变量

assign ReadData1 = (ReadReg1 == 0) ? 0 : RegFile[ReadReg1];
assign ReadData2 = (ReadReg2 == 0) ? 0 : RegFile[ReadReg2];

always @ (negedge CLK or negedge RST) begin //只有在CLK和RST的下降沿才能触发
    if(RST == 0) begin  //RST信号为0时，将寄存器的内容清空
        for(i = 1;i <= 31;i = i + 1) 
            RegFile[i] <= 0;
    end
    else if(RegWre == 1 && WriteReg != 0)  //当写能信号为1并且要写入的寄存器号不为零时将数据写入
            RegFile[WriteReg] <= WriteData;         
end

endmodule