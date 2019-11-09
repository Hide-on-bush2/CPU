`include "ALU32.v"

module ALU32_sim();

//inputs
reg [2:0] ALUopcode;
reg [31:0] rega;
reg [31:0] regb;

//outputs
wire [31:0] result;
wire zero;

//Instantiate the Unit Under Test(UUT)
ALU32 uut(
    .ALUopcode(ALUopcode),
    .rega(rega),
    .regb(regb),
    .result(result),
    .zero(zero)
);

initial 
    begin
        //record
        $dumpfile("ALU32.vcd");
        $dumpvars(0, ALU32_sim);

        //initial Inputs
            ALUopcode = 0;
            rega = 0;
            regb = 0;
        
        //wait 100ns for global reset to finish
        #100;
            ALUopcode = 0;//rega + regb
            rega = 1;
            regb = 1;

        #100;
            ALUopcode = 1;//rega - regb
            rega = 2;
            regb = 1;

        #100;
            ALUopcode = 1;//rega - regb
            rega = 1;
            regb = 2;

        #100;
            ALUopcode = 2;//rega & regb
            rega = 5;
            regb = 1;

        #100;
            ALUopcode = 3;//rega | regb
            rega = 4;
            regb = 1;

        #100;
            ALUopcode = 4;//rega < regb?不带符号比较
            rega = 4;
            regb = 5;

        #100;
            ALUopcode = 4;//rega < regb?不带符号比较
            rega = 5;
            regb = 4;

        #100;
            ALUopcode = 5;//rega < regb?带符号比较
            rega = 4;
            regb = 5;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = -1;
            regb = -2;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = -2;
            regb = -1;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = -1;
            regb = 0;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = 0;
            regb = -2;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = -1;
            regb = -1;
        
        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = 0;
            regb = 2;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = 1;
            regb = 0;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = 2;
            regb = 2;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = 0;
            regb = 0;

        #100;
            ALUopcode = 5;//reg < regb?带符号比较
            rega = 9;
            regb = 5;

        #100;
            $stop;
    end

endmodule