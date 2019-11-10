`include"DataMemory.v"

module DataMemory_sim;

    // input
    reg CLK;
    reg [31:0] Address;
    reg [31:0] WriteData;
    reg MemRead;
    reg MemWrite;

    //otput
    wire [31:0] DataOut;

    DataMemory uut(
        .CLK(CLK),
        .Address(Address),
        .WriteData(WriteData),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .DataOut(DataOut)
    );

    always #15 CLK = !CLK;

    initial begin
        //record
        $dumpfile("DataMemory.vcd");
        $dumpvars(0, DataMemory_sim);

        //初始化
        CLK = 0;
        Address = 0;
        WriteData = 0;
        MemRead = 1;    //为0，正常读；为1，输出高阻态（相当于开路）
        MemWrite = 1;   //为0，写；为1，无操作

        #30;//30ns后，CLK下降沿写
            Address = 8;
            WriteData = 8;
            MemRead = 1;
            MemWrite = 0;

        #30;//60ns后，CLK下降沿写
            Address = 12;
            WriteData = 12;
            MemRead = 1;
            MemWrite = 0;

        #30;//90ns后开始读
            Address = 8;
            MemRead = 0;
            MemWrite = 1;

        #30;//120ns后开始读
            Address = 12;
            MemRead = 0;
            MemWrite = 1;

        #30;
            $stop;//150ns后停

    end

endmodule
