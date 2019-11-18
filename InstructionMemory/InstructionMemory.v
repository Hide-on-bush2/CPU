module InstructionMemory(
    input [31:0] IAddr,
    input RW,//0 write, 1 read

    output [5:0] op,
    output [4:0] rs, rt, rd,
    output [15:0] Immediate,
    output [4:0] Sa
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
