module PC_controller(
 
	// clock
	input							clk,
	
	// input buttons
	input							send_data,
	input							next_raw,
	input							prev_raw,
	input							increment_raw,
	
	// input switches
	input				[4:0]		value,
	input							invert,
 
	// transmitting data to PC
   input 						RxD,
   output 						TxD,
	
	// display
	output			[6:0]		display_segments,
	output 			[1:0] 	display_selector
);
// 0 - ml
// 1 - mu
// 2 - mr
// 3 - md
// 4 - num
// 5 - letter
// 6 - backspace
// 7 - mouse_pos
 
wire next_debounced;
wire prev_debounced;
wire increment_debounced;
reg[4:0] max_i=0;
reg[4:0] max_j=0;
reg[4:0] last_j_on_last_i=0;

button_debouncer  debouncer 
(	
	.clk_i(clk),
 
	.sw_i(next_raw),
 
	.sw_down_o(next_debounced)
);	
button_debouncer  debouncer2 
(	
	.clk_i(clk),
 
	.sw_i(prev_raw),
 
	.sw_down_o(prev_debounced)
);	
button_debouncer  debouncer3 
(	
	.clk_i(clk),
 
	.sw_i(increment_raw),
 
	.sw_down_o(increment_debounced)
);	
 
wire RxD_data_ready;
reg[3:0] i;
reg [3:0] j;  //4 bit reg for counting
reg[6:0]display_1; // counting number to be displayed
reg[6:0]display_2; // counting number to be displayed
reg [3:0] state;
reg[7:0] data_to_be_sent;
reg [4:0] value_dynamic;
initial begin
i='b0;
j = 'b0;  //4 bit reg for counting
state = 'b0;
data_to_be_sent = 'b11111111;
value_dynamic = 'b00000;
end
async_receiver RX(
	.clk(clk), 
	.RxD(RxD), 
	.RxD_data_ready(RxD_data_ready)
);
async_transmitter TX(.clk(clk), 
	.TxD(TxD), 
	.TxD_start(RxD_data_ready), 
	.TxD_data(data_to_be_sent), 
	.assert_pressed(send_data)
);
always@(posedge clk)
begin
case (state)
	4,5: begin // num, letters
		value_dynamic = i*10+j;
		data_to_be_sent = {(state==4?'b110:'b101),value_dynamic};
		case (i)
			0:
				display_1 = 7'b1000000;	// zero
			1:
				display_1 = 7'b1111001;	// one
			2:
				display_1 = 7'b0100100;	// two
			3:
				display_1 = 7'b0110000;	// three
			4:
				display_1 = 7'b0011001;	// four
			5:
				display_1 = 7'b0010010;	// five
			6:
				display_1 = 7'b0000010;	// six
			7:
				display_1 = 7'b1111000;	// seven
			8:
				display_1 = 7'b0000000;	// eight
			9:
				display_1 = 7'b0010000;	// nine
			default:
				display_1 = 7'b1000000;	// zero in any other cases
        endcase
		  case (j)
			0:
				display_2 = 7'b1000000;	// zero
			1:
				display_2 = 7'b1111001;	// one
			2:
				display_2 = 7'b0100100;	// two
			3:
				display_2 = 7'b0110000;	// three
			4:
				display_2 = 7'b0011001;	// four
			5:
				display_2 = 7'b0010010;	// five
			6:
				display_2 = 7'b0000010;	// six
			7:
				display_2 = 7'b1111000;	// seven
			8:
				display_2 = 7'b0000000;	// eight
			9:
				display_2 = 7'b0010000;	// nine
			default:
				display_2 = 7'b1000000;	// zero in any other cases
        endcase
		  end
		  0:begin // mouse_left
		value_dynamic = ~value;
				display_1 = 7'b0000110;	// <-
				display_2 = 7'b0111111;	
			data_to_be_sent = {3'b001,value_dynamic};
		  end
		  1:begin // mouse_up
		value_dynamic = ~value;
				display_1 = 7'b1011000;	// ^
				display_2 = 7'b1001100;	// |
			data_to_be_sent = {3'b010,value_dynamic};
		  end
		  2:begin // mouse_right
		value_dynamic = ~value;
				display_1 = 7'b0111111;	// ->
				display_2 = 7'b0110000;	
			data_to_be_sent = {3'b000,value_dynamic};
		  end
		  3:begin // mouse_down
		value_dynamic = ~value;
				display_1 = 7'b1100001;	// |
				display_2 = 7'b1000011;	// v
			data_to_be_sent = {3'b011,value_dynamic};
		  end
		  6:begin // backspace
				display_1 = 7'b1111111;	// empty display
				display_2 = 7'b1111111;	// empty display
				data_to_be_sent = {3'b100,5'b01111};
		  end
		  7:begin // mouse set
				case (j)
					0:begin // up
				display_1 = 7'b1111110;	
				display_2 = 7'b1111110;	
						data_to_be_sent = {3'b100,5'b00010};
					end
					1:begin // up-right
				display_1 = 7'b1111111;	
				display_2 = 7'b1111100;	
						data_to_be_sent = {3'b100,5'b00111};
					end
					2:begin // right
				display_1 = 7'b1111111;	
				display_2 = 7'b1111001;	
						data_to_be_sent = {3'b100,5'b00100};
					end
					3:begin // down-right
				display_1 = 7'b1111111;	
				display_2 = 7'b1110011;	
						data_to_be_sent = {3'b100,5'b00110};
					end
					4:begin // down
				display_1 = 7'b1110111;	
				display_2 = 7'b1110111;	
						data_to_be_sent = {3'b100,5'b00011};
					end
					5:begin //down-left
				display_1 = 7'b1100111;	
				display_2 = 7'b1111111;	
						data_to_be_sent = {3'b100,5'b01000};
					end
					6:begin //left
				display_1 = 7'b1001111;	
				display_2 = 7'b1111111;	
						data_to_be_sent = {3'b100,5'b00101};
					end
					7:begin //up-left
				display_1 = 7'b1011110;	
				display_2 = 7'b1111111;	
						data_to_be_sent = {3'b100,5'b01001};
					end
					8:begin //middle
				display_1 = 7'b0111001;	
				display_2 = 7'b0001111;	
						data_to_be_sent = {3'b100,5'b00001};
					end
				endcase
		  end
		  endcase
end

always @ (posedge clk)
begin
if (increment_debounced)begin
		if (invert)
		begin//no inversion
		if (j == last_j_on_last_i && i == max_i)begin
			i = 0;
			j = 0;
		end
		else begin
			i = (j < max_j) ? i : (i + 1);
			j = (j < max_j) ? j+1 : 'b0;
		end
		end
		else begin//inversion
		if (j == 0 && i == 0)begin
		i = max_i;
		j=last_j_on_last_i;
		end
		else begin
		i = (j > 0) ? i : (i - 1);
		j = (j > 0) ? j-1 : max_j;
		end
		end
end
else if (prev_debounced || next_debounced)begin
	state = next_debounced?((state==7)?0:(state+1)):((state==0)?7:(state-1));
	i = 0;
	j = 0;
	case (state)
	4:begin//num
		max_j=9;
		max_i=3;
		last_j_on_last_i=1;
	end
	5: begin//letter
		max_j=9;
		max_i=3;
		last_j_on_last_i=1;
		end
	7:begin//mouse_pos
		max_j=8;
		last_j_on_last_i=8;
		max_i=0;
	end
	default begin
		max_j=0;
		max_i=0;
		last_j_on_last_i=0;
	end
	endcase
end
end
Seven_segment_LED_Display_Controller (
    .clock(clk), 
    .reset(reset), 
    .display_1(display_1), 
    .display_2(display_2), 
    .Anode_Activate(display_selector), 
    .LED_out(display_segments)
);
 
endmodule

