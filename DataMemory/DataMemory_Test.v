`include"DataMemory.v"

module DataMemory_sim;

    // input
    reg CLK;
    reg [31:0] DAddr;
    reg [31:0] DataIn;
    reg RD;
    reg WR;

    //otput
    wire [31:0] DataOut;

    DataMemory uut(
        .CLK(CLK),
        .DAddr(DAddr),
        .DataIn(DataIn),
        .RD(RD),
        .WR(WR),
        .DataOut(DataOut)
    );

    always #15 CLK = !CLK;

    initial begin
        //record
        $dumpfile("DataMemory.vcd");
        $dumpvars(0, DataMemory_sim);

        //初始化
        CLK = 0;
        DAddr = 0;
        DataIn = 0;
        RD = 1;    //为0，正常读；为1，输出高阻态（相当于开路）
        WR = 1;   //为0，写；为1，无操作

        #30;//30ns后，CLK下降沿写
            DAddr = 8;
            DataIn = 8;
            RD = 1;
            WR = 0;

        #30;//60ns后，CLK下降沿写
            DAddr = 12;
            DataIn = 12;
            RD = 1;
            WR = 0;

        #30;//90ns后开始读
            DAddr = 8;
            RD = 0;
            WR = 1;

        #30;//120ns后开始读
            DAddr = 12;
            RD = 0;
            WR = 1;

        #30;
            $stop;//150ns后停

    end

endmodule
