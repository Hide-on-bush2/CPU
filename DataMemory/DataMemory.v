module DataMemory(
    input CLK,
    input wire [31:0] DAddr,  //地址输入
    input wire [31:0] DataIn,//    
    input RD,             //为0，写；为1，无操作
    input WR,              //为0，正常读；为1，输出高组态
    
    output wire [31:0] DataOut
);

reg [7:0] Memory [0:127];//存储器
wire [31:0] address;

//因为一条指令由四个存储单元存储所以要乘以4
assign address = (DAddr << 2);


//读
assign DataOut[7:0] = (RD == 0) ? Memory[address + 3] : 8'bz;//z为高阻态
assign DataOut[15:8] = (RD == 0) ? Memory[address + 2] : 8'bz;
assign DataOut[23:16] = (RD == 0) ? Memory[address + 1] : 8'bz;
assign DataOut[31:24] = (RD == 0) ? Memory[address] : 8'bz;

//写
always @ (negedge CLK) begin
    if(WR == 0) begin
        Memory[address] <= DataIn[31:24];
        Memory[address + 1] <= DataIn[23:16];
        Memory[address + 2] <= DataIn[15:8];
        Memory[address + 3] <= DataIn[7:0];
    end
end
 
endmodule


