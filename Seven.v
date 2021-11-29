module Seven_segment_LED_Display_Controller(
    input clock, // 50 Mhz clock
    input reset, // reset
    input [6:0]display_1,
    input [6:0]display_2, 
    output reg [1:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out // cathode patterns of the 7-segment LED display
    );
    reg [26:0] counter; // counter for choosing which display to activate	 


always@(posedge clock)
begin
    counter <= reset ? 'd0 : (counter == 500000000) ? 'd0 : (counter + 1);
    if (counter[14])
    begin
		Anode_Activate <= 'b01;
	   LED_out <= display_1;
    end
    else
    begin
		Anode_Activate <= 'b10;
	   LED_out <= display_2;
    end
end

endmodule