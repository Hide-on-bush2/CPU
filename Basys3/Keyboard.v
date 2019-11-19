module Keyboard_CLK(
    input Button,
    input BasysCLK,

    output CPUCLK
);

reg button_previous_state;
reg button_current_state;

wire button_edge;

always @ (posedge BasysCLK) begin
    button_current_state <= Button;
    button_previous_state <= button_current_state;
end

assign button_edge = button_previous_state & (~button_current_state);

reg [20:0] counter;

always @ (posedge BasysCLK) begin
    if(button_edge)
        counter <= 21'h0;
    else
        counter <= counter + 1;
end

reg delayed_button_previous_state;
reg delayed_button_current_state;

always @ (posedge BasysCLK) begin
    if(counter == 21'h1E8480) 
        delayed_button_current_state <= button_current_state;
    delayed_button_previous_state <= delayed_button_current_state;
end

assign CPUCLK = delayed_button_previous_state & (~delayed_button_current_state);

endmodule

