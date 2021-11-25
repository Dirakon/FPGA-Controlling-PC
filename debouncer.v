

module button_debouncer
//! Parameters
#(
    parameter		COUNTER_WIDTH = 16
)

(
    input clk,
	 input reset,
    input raw_button_input,  
 
    output reg button_state,  
    output reg on_button_down,  
    output reg on_button_up   
);
 
//! Synchronizing input to our clk domain
reg	 [1:0] sw_r;
always @ (posedge reset or posedge clk)
if (reset)
		sw_r   	<= 2'b00;
else
		sw_r    <= {sw_r[0], ~raw_button_input};
 
reg [COUNTER_WIDTH-1:0] counter;
 
 
wire sw_change_f = (button_state != sw_r[1]);

wire is_counter_full = &counter;	
 
always @(posedge reset or posedge clk)
if (reset)
begin
	counter <= 0;
	button_state <= 0;
end 
else if(sw_change_f)	
   	begin
		counter <= counter + 'd1;  
		if(is_counter_full) button_state <= ~button_state;  
	end
	else  counter <= 0;  
 
always @(posedge clk)
begin
	on_button_down <= sw_change_f & is_counter_full & ~button_state;
	on_button_up <= sw_change_f & is_counter_full &  button_state;
end
 
endmodule


