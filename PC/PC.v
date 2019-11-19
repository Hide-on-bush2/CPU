module PC(
    input CLK, Reset, PCWre,
    input [1:0] PCSrc, 
    input signed [15:0] Immediate,   //从指令中取出符号拓展而来
    input [31:0] JumpPC,//跳转地址

    output reg signed [31:0] Address,
    output [31:0] nextPC,
    output [3:0] PC4
);

assign nextPC = (PCSrc[0]) ? Address + 4 + (Immediate << 2) : ((PCSrc[1]) ?  JumpPC : Address + 4);

assign PC4 = Address[31:28];
//当clock下降沿到来或Reset下降沿到来时，对地址进行改变或者置零
always @(negedge CLK or negedge Reset) begin
    if(Reset == 0)
        Address = 0;
    else if(PCWre) begin//PCWre为1时才允许更改地址
        if(PCSrc[0])
            Address = Address + 4 + (Immediate << 2);//跳转
        else if(PCSrc[1])
            Address = JumpPC;
        else
            Address = Address + 4;//顺序执行下一条指令
    end
end

endmodule
