module RegisterFile(
    input CLK, RegDst, RegWre, DBDataSrc,
    input [5:0] Opcode,
    input [4:0] rs, rt, rd,
    input [10:0] im,
    input [31:0] dataFromALU, dataFromRW,

    output [31:0] Data1, Data2
);

wire [4:0] writeReg;//要写的寄存器端口
wire [31:0] writeData;//要写的数据

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
assign Data1 = (Opcode == 6'b011000) ? im[10:6] : register[rs];
assign Data2 = register[rt];

always @ (negedge CLK or RegDst or RegWre or DBDataSrc or writeReg or writeData) begin
    if(RegWre && writeReg)
        register[writeReg] <= writeData;//防止数据写进0号寄存器
end

endmodule 
