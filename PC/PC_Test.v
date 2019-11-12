`include"PC.v"

module PC_sim();

    //inputs
    reg CLK;
    reg Reset;
    reg PCWre;
    reg PCSrc;
    reg [15:0] Immediate;

    //outputs
    wire [31:0] Address;

    PC uut(
        .CLK(CLK),
        .Reset(Reset),
        .PCWre(PCWre),
        .PCSrc(PCSrc),
        .Immediate(Immediate),
        .Address(Address)
    );

    always #15 CLK = !CLK;

    initial begin
        //record
        $dumpfile("PC.vcd");
        $dumpvars(0, PC_sim);

        //初始化
        CLK = 0;
        Reset = 0;
        PCWre = 0;
        PCSrc = 0;
        Immediate = 0;

        //不跳转，顺序执行下一条地址
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 0;
        Immediate = 4;

        //不跳转，顺序执行下一条地址
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 0;
        Immediate = 4;

        //不跳转，顺序执行下一条地址
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 0;
        Immediate = 4;

        //不跳转，顺序执行下一条地址
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 0;
        Immediate = 4;

        //跳转，执行跳转之后的指令
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 1;
        Immediate = 4;

        //跳转，执行跳转之后的指令
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 1;
        Immediate = 4;

        //跳转，执行跳转之后的指令
        #100;
        Reset = 1;
        PCWre = 1;
        PCSrc = 1;
        Immediate = 4;

        //结束
        #100;
        $stop;
    end

endmodule





