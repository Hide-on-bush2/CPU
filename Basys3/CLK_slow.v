module CLK_slow(
    input CLK_100mhz,//100mhz的原始时钟信号
    
    output reg CLK_slow//输出的分频时钟信号
);

reg [31:0] count = 0;//计数器
reg [31:0] N = 50000;//分频2^19，得到一个周期大约5ms的信号

initial CLK_slow = 0;

always @ (posedge CLK_100mhz) begin
    if(count >= N) begin
        count <= 0;
        CLK_slow <= ~CLK_slow;
    end
    else
        count <= count + 1;

end

endmodule 