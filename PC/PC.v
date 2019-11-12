module PC(
    input CLK, Reset, PCWre, PCSrc,
    input wire [15:0] Immediate,   //从指令中取出符号拓展而来

    output reg [31:0] Address
);

//当clock下降沿到来或Reset下降沿到来时，对地址进行改变或者置零
always @(negedge CLK or negedge Reset) begin
    if(Reset == 0)
        Address = 0;
    else if(PCWre) begin//PCWre为1时才允许更改地址
        if(PCSrc)
            Address = Address + 4 + Immediate << 2;//跳转
        else
            Address = Address + 4;//顺序执行下一条指令
    end
end

endmodule
