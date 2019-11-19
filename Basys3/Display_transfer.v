module Transfer(
    input CLK,
    input [15:0] In,

    output reg [3:0] Out,
    output reg [3:0] Bit
);


integer i;
initial begin 
    i = 0;
end

always @ (negedge CLK) begin
    case(i)
        0 : begin
            Out = In[15:12];
            Bit = 4'b1110;
        end
        1 : begin
            Out = In[11:8];
            Bit = 4'b1101;
        end
        2 : begin
            Out = In[7:4];
            Bit = 4'b1011;
        end
        3 : begin
            Out = In[3:0];
            Bit = 4'b0111;
        end
    endcase
    i = (i == 3) ? 0 : i + 1;
end

endmodule