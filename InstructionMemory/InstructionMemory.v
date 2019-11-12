module InstructionMemory(
    input wire [31:0] IAddr,
    input RW,

    output wire [5:0] op,
    output wire [5:0] rs, rt, rd,
    output wire [15:0] Immediate,
    output wire [5:0] sa
);

//因为实验要求指令存储器和数据存储器单元宽度一律使用8位，
//因此将一个32位的指令拆成4个8位的存储器单元存储

//从文件中取出后将他们合并为32的指令
reg [7:0] Mem[0:127];
reg [31:0] Instruction;

initial begin
    $readmemb("Instructions.txt", Mem);//从文件中读取指令集
    Instruction = 0;//指令初始化
end

always @(IAddr) begin
    if(RW) 
        Instruction = Mem[IAddr];
    else begin
        
    end
end
