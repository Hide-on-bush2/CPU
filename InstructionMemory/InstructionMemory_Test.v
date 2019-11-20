`include"InstructionMemory.v"
`timescale 1ns / 1ps

module IM_sim;

//inputs
reg [31:0] IAddr;
reg RW;

//output
wire [5:0] op;
wire [4:0] rs, rt, rd;
wire [15:0] Immediate;
wire [4:0] Sa;

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

