`include"RegisterFile.v"

//测试文件

module RegFile_sim();
    //inputs
    reg CLK, RegDst, RegWre, DBDataSrc;
    reg [5:0] Opcode;
    reg [4:0] rs, rt, rd;
    reg [10:0] im;
    reg [31:0] dataFromALU, dataFromRW;

    //ouputs
    wire [31:0] Data1;
    wire [31:0] Data2;

    RegisterFile uut(
        .CLK(CLK),
        .RegDst(RegDst),
        .RegWre(RegWre),
        .DBDataSrc(DBDataSrc),
        .Opcode(Opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .im(im),
        .dataFromALU(dataFromALU),
        .dataFromRW(dataFromRW),

        .Data1(Data1),
        .Data2(Data2)
    );

    always #15 CLK = !CLK;

    initial begin
        //record
        $dumpfile("RegisterFile.vcd");
        $dumpvars(0, RegFile_sim);

        //初始化
        CLK = 0;

        //Test1
        #10;
        CLK = 0;
        RegDst = 1;//处理R型指令
        RegWre = 1;//允许写寄存器
        DBDataSrc = 0;//使用来自ALU的输出
        Opcode = 6'b000000;//没用...
        rs = 5'b00000;
        rt = 5'b00001;
        rd = 5'b00010;
        im = 11'b0;
        dataFromALU = 32'd1;//来自ALU的输出
        dataFromRW = 32'd2;//来自RW的输出

        //Test2
        #100;
        RegDst = 0;//处理R型指令
        RegWre = 0;//允许写寄存器
        DBDataSrc = 1;//使用来自ALU的输出
        Opcode = 6'b000000;//没用...
        rs = 5'b00011;
        rt = 5'b00100;
        rd = 5'b00101;
        im = 11'd10;
        dataFromALU = 32'd3;//来自ALU的输出
        dataFromRW = 32'd4;//来自RW的输出

        //stop，需要的测试在debug阶段再写吧
        $stop;
    end


    
endmodule