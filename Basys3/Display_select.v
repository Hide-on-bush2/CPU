module Select(
    input [15:0] In1, In2, In3, In4,
    input [1:0] SelectCode,

    output reg [15:0] DataOut
);

always @ (*) begin
    case (SelectCode)
        2'b00 : DataOut = In1;
        2'b01 : DataOut = In2;
        2'b10 : DataOut = In3;
        2'b11 : DataOut = In4;
    endcase
end

endmodule