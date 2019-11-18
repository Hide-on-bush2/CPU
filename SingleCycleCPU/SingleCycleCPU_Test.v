`include"SingleCycleCPU.v"

module SingleCycleCPU_sim();

    //inputs
    reg CLK;
    reg Reset;

    //Outputs
    wire [31:0] Out1;
    wire [31:0] Out2;
    wire [31:0] curPC;
    wire [31:0] Result;
    wire [5:0] Opcode;

    //instantiate the Unit Under Test
    SingleCycleCPU uut(
        .CLK(CLK),
        .Reset(Reset),
        .Opcode(Opcode),
        .Out1(Out1),
        .Out2(Out2),
        .curPC(curPC),
        .Result(Result)
    );

    initial begin 
        //record 
        $dumpfile("SCCPU.vcd");
        $dumpvars(0, SingleCycleCPU_sim);

        //innitial inputs
        CLK = 0;
        Reset = 0;//刚开始设置PC为0

        #50;
        CLK = 1;

        #50;
        Reset = 1;

        //产生时钟信号
        forever #50 begin
            CLK = !CLK;
        end

    

    end

endmodule