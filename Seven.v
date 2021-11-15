module Seven_segment_LED_Display_Controller(
    input clock, // 100 Mhz clock source on Basys 3 FPGA
    input reset, // reset
    input [6:0]display_1, // counting number to be displayed
    input [6:0]display_2, // counting number to be displayed
    output reg [1:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out// cathode patterns of the 7-segment LED display
    );
    reg [26:0] one_second_counter; // counter for generating 1 second clock enable



always@(posedge clock)
begin
    one_second_counter = reset ? 'd0 : (one_second_counter == 500000000) ? 'd0 : (one_second_counter + 1);
    if (one_second_counter[8])
    begin
		Anode_Activate = 'b01;
	   LED_out = display_1;
    end
    else
    begin
		Anode_Activate = 'b10;
	   LED_out = display_2;
    end
end

endmodule