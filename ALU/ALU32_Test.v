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