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
    assign PCSrc[0] = ((OpCode == 6'b110000 && zero == 1) || (OpCode == 6'b110010 && zero == 0) || (OpCode == 6'b110001 && zero == 0)) ? 1 : 0;
    assign PCSrc[1] = (OpCode == 6'b111000) ? 1 : 0;
    assign ALUOp[2] = (OpCode == 6'b010000 || OpCode == 6'b010001 || OpCode == 6'b011100 || OpCode == 6'b110010) ? 1 : 0;
    assign ALUOp[1] = (OpCode == 6'b010010 || OpCode == 6'b010011 || OpCode == 6'b011000 || OpCode == 6'b110010) ? 1 : 0;
    assign ALUOp[0] = (OpCode == 6'b000001 || OpCode == 6'b010010 
        || OpCode == 6'b011100 || OpCode == 6'b010011 || OpCode == 6'b110000 || OpCode == 6'b110001) ? 1 : 0;
endmodule
    
// 110010
// 110

