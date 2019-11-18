`include"../ALU/ALU32.v"
`include"../ControlUnit/CU.v"
`include"../DataMemory/DataMemory.v"
`include"../InstructionMemory/InstructionMemory.v"
`include"../PC/PC.v"
`include"../RegisterFile/RegisterFile.v"
`include"../SignZeroExtend/SignZeroExtend.v"


module SingleCycleCPU(
    input CLK, Reset,
    output wire [5:0] Opcode,
    output wire [31:0] Out1, Out2, curPC, Result
);

wire [2:0] ALUOp;
wire [31:0] Extout, DMOut;
wire [15:0] Immediate;
wire [4:0] rs, rt, rd;
wire [4:0] sa;
wire zero, PCWre, ALUSrcA, ALUSrcB, DBDataSrc, ReWre;
wire InsMemRW, RD, WR, ExtSel, RegDst, PCSrc;

ALU alu(Out1, Out2, Extout, sa, ALUOp, ALUSrcA, ALUSrcB, zero, Result);
PC pc(CLK, Reset, PCWre, PCSrc, Immediate, curPC);
ControlUnit CU(Opcode, zero, PCWre, ALUSrcA, ALUSrcB, DBDataSrc, ReWre, InsMemRW, RD, WR, ExtSel, RegDst, PCSrc, ALUOp);
DataMemory DM(CLK, Result, Out2, RD, WR, DMOut);
InstructionMemory IM(curPC, InsMemRW, Opcode, rs, rt, rd, Immediate, sa);
RegisterFile RF(CLK, RegDst, ReWre, DBDataSrc, rs, rt, rd, Result, DMOut, Out1, Out2);
SignZeroExtend SZE(Immediate, ExtSel, Extout);

endmodule