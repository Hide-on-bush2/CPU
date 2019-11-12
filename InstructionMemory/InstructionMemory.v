module InstructionMemory(
    input wire [31:0] PC,
    output wire [5:0] op,
    output wire [5:0] rs, rt, rd,
    output wire [15:0] Immediate,
    output wire [5:0] sa
);

//因为实验要求指令存储器和数据存储器单元宽度一律使用8位，
//因此将一个32位的指令拆成4个8位的存储器单元存储

//从文件中取出后将他们合并为32的指令