`include"SignZeroExtend.v"

module SignZeroExtend_sim();

//inputs
reg signed [15:0] Immediate;
reg ExtSel;

//outputs
wire [31:0] Out;

SignZeroExtend uut(
    .Immediate(Immediate),
    .ExtSel(ExtSel),
    .Out(Out)
);

initial begin
    //record
    $dumpfile("SignZeroExtend.vcd");
    $dumpvars(0, SignZeroExtend_sim);

    //初始化(好像不用）
    #50;
    ExtSel = 0;
    Immediate[15:0] = 15'd7;

    //Test1
    #50;
    ExtSel = 1;
    Immediate[15:0] = 15'd10;

    //Test2
    #50;
    ExtSel = 1;
    Immediate[15:0] = 15'd7;
    Immediate[15] = 1;

    //stop
    #50;
    $stop;
end

endmodule