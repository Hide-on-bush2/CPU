`include"Basys3.v"

module basys_sim(

    );
    reg CLK, RST;
    reg CLKButton;
    reg [1:0] SW;
    
    Basys3 test(
        .BasysCLK(CLK),
        .CLKButton(CLKButton),
        .SW_in(SW),
        .RST_Button(RST),
        
        
        .SegOut(),
        .Bits()
    );
    integer i;

    initial begin
        //recode 
        $dumpfile("Basys3.vcd");
        $dumpvars(0, basys_sim);

        CLK = 0;
        RST = 0;
        CLKButton = 0;
        SW = 2'b00;

        #50;
        RST = 1;
        for (i = 0; i < 1000000; i = i + 1) begin
            #100;
            CLK = ~CLK;
//            #10;
            if (i % 15 == 0) CLKButton = ~CLKButton;
        end

       
    end
endmodule