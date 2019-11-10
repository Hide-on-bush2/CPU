`include"RegisterFile.v"

//测试文件

module RegFile_sim();

    //inputs
    reg CLK;
    reg RST;
    reg RegWre;
    reg [4:0] ReadReg1;
    reg [4:0] ReadReg2;
    reg [4:0] WriteReg;
    reg [31:0] WriteData;

    // Outputs
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    // Instantiate the Unit Under Test (UUT) 
    RegisterFile uut (
        .CLK(CLK),
        .RST(RST), 
        .RegWre(RegWre), 
        .ReadReg1(ReadReg1), 
        .ReadReg2(ReadReg2), 
        .WriteReg(WriteReg), 
        .WriteData(WriteData), 
        .ReadData1(ReadData1), 
        .ReadData2(ReadData2)
    );

    always #50 CLK = !CLK; 
    initial begin
        //record
        $dumpfile("RegisterFile.vcd");
        $dumpvars(0, RegFile_sim);

        // Initialize Inputs
        CLK = 0;
        RST = 0; // 复位
        RegWre = 0; // 读
        ReadReg1 = 0; 
        ReadReg2 = 0; 
        WriteReg = 0; 
        WriteData = 0;

        // Wait 100 ns for global RST to finish 
        #100; // 写
        RST = 1;
        RegWre = 1;
        ReadReg1  = 0;
        ReadReg2  = 0;
        WriteReg = 1;
        WriteData = 1;

        #100;   //写
        RST = 1;
        RegWre = 1;
        ReadReg1 = 0;
        ReadReg2 = 0;
        WriteReg = 2;
        WriteData = 2;

        #100;   //写
        RST = 1;
        RegWre = 1;
        ReadReg1 = 0;
        ReadReg2 = 0;
        WriteReg = 3;
        WriteData = 3;

        #100;   //读
        RST = 1;
        RegWre = 0;
        ReadReg1 = 1;
        ReadReg2 = 0;
        WriteReg = 0;
        WriteData = 0;

        #100;   //读
        RST = 1;
        RegWre = 0;
        ReadReg1 = 0;
        ReadReg2 = 2;
        WriteReg = 0;
        WriteData = 0;
    
        #100;   //读
        RST = 1;
        RegWre = 0;
        ReadReg1 = 1;
        ReadReg2 = 2;
        WriteReg = 0;
        WriteData = 0;

        #200;   //延迟

        #100;   //复位
        RST = 0;
        RegWre = 0;
        ReadReg1 = 0;
        ReadReg2 = 0;
        WriteReg = 3;
        WriteData = 3;
    end
endmodule