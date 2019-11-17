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
    output PCSrc,
    output [2:0] ALUOp
);

    //根据opcode定义控制信号为1或0
    assign PCWre = (OpCode == 6'b111111) ? 0 : 1;
    assign ALUSrcA = (OpCode == 6'b011000) ? 1 : 0;
    assign ALUSrcB = (OpCode == 6'b000001 || OpCode == 6'b010000 
        || OpCode == 6'b100110 || OpCode == 6'b100111) ? 0 : 1;
    assign DBDataSrc = (OpCode == 6'b100111) ? 1 : 0;
    assign RegWre = (OpCode == 6'b100110 || OpCode == 6'b110000 
        || OpCode == 6'b111111) ? 0 : 1;
    assign InsMemRW = 0;
    assign RD = (OpCode == 6'b010000) ? 0 : 1;
    assign WR = (OpCode == 6'b100110) ? 0 : 1;
    assign ExtSel = (OpCode == 6'b010000) ? 0 : 1;
    assign RegDst = (OpCode == 6'b000001 || OpCode == 6'b010000 
        || OpCode == 6'b100111) ? 0 : 1;
    assign PCSrc = (OpCode == 6'b010000 && zero == 1) ? 1 : 0;
    assign ALUOp[2] = (OpCode == 6'b010000 || OpCode == 6'b010001
        || OpCode == 6'b010000) ? 1 : 0;
    assign ALUOp[1] = 0;

endmodule
    