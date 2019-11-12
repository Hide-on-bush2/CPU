

module SignZeroExtend(
    //根据数据通路定义输入和输出
    input wire [15:0] Immediate,
    input ExtSel,
    output wire [31:0] Out
);

//后16位存储立即数
assign Out[15:0] = Immediate[15:0];
//前16位根据立即数进行补1或补0的操作
assign Out[31:16] = ExtSel == 1 ? {16{Immediate[15]}} : 16'b0;
    
endmodule