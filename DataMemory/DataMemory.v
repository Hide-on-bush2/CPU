module DataMemory(
    input CLK,
    input wire [31:0] Address,  //地址输入
    input wire [31:0] WriteData,//    
    input MemWrite,             //为0，写；为1，无操作
    input MemRead,              //为0，正常读；为1，输出高组态
    
    output wire [31:0] DataOut
);

reg [7:0] Memory [0:60];//存储器

//读
assign DataOut[7:0] = (MemRead == 0) ? Memory[Address + 3] : 8'bz;//z为高阻态
assign DataOut[15:8] = (MemRead == 0) ? Memory[Address + 2] : 8'bz;
assign DataOut[23:16] = (MemRead == 0) ? Memory[Address + 1] : 8'bz;
assign DataOut[31:24] = (MemRead == 0) ? Memory[Address] : 8'bz;

//写
always @ (negedge CLK) begin
    if(MemWrite == 0) begin
        Memory[Address] <= WriteData[31:24];
        Memory[Address + 1] <= WriteData[23:16];
        Memory[Address + 2] <= WriteData[15:8];
        Memory[Address + 3] <= WriteData[7:0];
    end
end
 
endmodule


