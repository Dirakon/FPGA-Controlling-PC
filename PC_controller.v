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

  reg [3:0] state;
  
  // ---STATES---
  // 0 - mouse_left (+right/left click)
  // 1 - mouse_up (+right/left click)
  // 2 - mouse_right (+right/left click)
  // 3 - mouse_down (+right/left click)
  // 4 - enter_number
  // 5 - enter_letter
  // 6 - backspace
  // 7 - set_mouse_position 

  wire next_debounced;
  wire prev_debounced;
  wire increment_debounced;
  button_debouncer  debouncer 
  (	
    .clk(clk),

    .raw_button_input(next_raw),

    .on_button_down(next_debounced)
  );	
  button_debouncer  debouncer2 
  (	
    .clk(clk),

    .raw_button_input(prev_raw),

    .on_button_down(prev_debounced)
  );	
  button_debouncer  debouncer3 
  (	
    .clk(clk),

    .raw_button_input(increment_raw),

    .on_button_down(increment_debounced)
  );	

  reg[4:0] max_tens=0; 
  reg[4:0] max_ones=0; // max value of ones in general
  reg[4:0] max_ones_on_max_tens=0; // max value of ones on last ten
  wire data_is_ready_to_transmit;
  reg[3:0] tens;  // first digit (represents tens)
  reg [3:0] ones;  // second digit (represents ones)
  reg[6:0]display_1;
  reg[6:0]display_2; 
  reg[7:0] data_to_be_sent;
  reg [4:0] value_dynamic; // temp variable for sending instruction values
  
  initial begin
    tens='b0;
    ones = 'b0; 
    state = 'b0;
    data_to_be_sent = 'b11111111;
    value_dynamic = 'b00000;
  end
  
  async_receiver RX(
    .clk(clk), 
    .RxD(RxD), 
    .ready_to_transmit(data_is_ready_to_transmit)
  );
  async_transmitter TX(
							  .clk(clk), 
                       .TxD(TxD), 
                       .TxD_start(data_is_ready_to_transmit), 
                       .TxD_data(data_to_be_sent), 
                       .assert_pressed(send_data)
								);
							 
  always@(posedge clk)
    begin
      case (state)
        4,5: begin // num, letters
          value_dynamic = tens*10+ones;
          data_to_be_sent = {(state==4?'b110:'b101),value_dynamic};
          case (tens)
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
          case (ones)
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
          display_1 = 7'b0000110;	// <-
          display_2 = 7'b0111111;	
          // if increment button => invert? left-click : right-click
          data_to_be_sent = (!increment_raw)?(invert?8'b100_01010:8'b100_01011):{3'b001,~value};
        end
        1:begin // mouse_up
          display_1 = 7'b1011000;	// ^
          display_2 = 7'b1001100;	// |
          // if increment button => invert? left-click : right-click
          data_to_be_sent = (!increment_raw)?(invert?8'b100_01010:8'b100_01011):{3'b010,~value};
        end
        2:begin // mouse_right
          display_1 = 7'b0111111;	// ->
          display_2 = 7'b0110000;	
          // if increment button => invert? left-click : right-click
          data_to_be_sent = (!increment_raw)?(invert?8'b100_01010:8'b100_01011):{3'b000,~value}; 
        end
        3:begin // mouse_down
          display_1 = 7'b1100001;	// |
          display_2 = 7'b1000011;	// v
          // if increment button => invert? left-click : right-click
          data_to_be_sent = (!increment_raw)?(invert?8'b100_01010:8'b100_01011):{3'b011,~value};
        end
        6:begin // backspace
          display_1 = 7'b1111111;	// empty display
          display_2 = 7'b1111111;	// empty display
          data_to_be_sent = 8'b100_01111;
        end
        7:begin // mouse set
          case (ones)
            0:begin // up
              display_1 = 7'b1111110;	// -
              display_2 = 7'b1111110;	//
              data_to_be_sent = 8'b100_00010;
            end
            1:begin // up-right
              display_1 = 7'b1111111;	// >
              display_2 = 7'b1111100;	//
              data_to_be_sent = 8'b100_00111;
            end
            2:begin // right
              display_1 = 7'b1111111;	//  |
              display_2 = 7'b1111001;	//  |
              data_to_be_sent = 8'b100_00100;
            end
            3:begin // down-right
              display_1 = 7'b1111111;	//
              display_2 = 7'b1110011;	//  >
              data_to_be_sent = 8'b100_00110;
            end
            4:begin // down
              display_1 = 7'b1110111;	//
              display_2 = 7'b1110111;	// _
              data_to_be_sent = 8'b100_00011;
            end
            5:begin //down-left
              display_1 = 7'b1100111;	//
              display_2 = 7'b1111111;	// <
              data_to_be_sent = 8'b100_01000;
            end
            6:begin //left
              display_1 = 7'b1001111;	// |
              display_2 = 7'b1111111;	// |
              data_to_be_sent = 8'b100_00101;
            end
            7:begin //up-left
              display_1 = 7'b1011110;	// <
              display_2 = 7'b1111111;	//
              data_to_be_sent = 8'b100_01001;
            end
            8:begin //middle
              display_1 = 7'b0111001;	// _|_
              display_2 = 7'b0001111;	//  |
              data_to_be_sent = 8'b100_00001;
            end
          endcase
        end
      endcase
    end

  always @ (posedge clk)
    begin
      if (increment_debounced)begin
        if (invert)
          begin // no inversion
            if (ones == max_ones_on_max_tens && tens == max_tens)begin
              tens = 0;
              ones = 0;
            end
            else begin
              tens = (ones < max_ones) ? tens : (tens + 1);
              ones = (ones < max_ones) ? ones+1 : 'b0;
            end
          end
        else begin // inversion
          if (ones == 0 && tens == 0)begin
            tens = max_tens;
            ones=max_ones_on_max_tens;
          end
          else begin
            tens = (ones > 0) ? tens : (tens - 1);
            ones = (ones > 0) ? ones-1 : max_ones;
          end
        end
      end
      else if (prev_debounced || next_debounced)begin
        state = next_debounced?((state==7)?0:(state+1)):((state==0)?7:(state-1));
        tens = 0;
        ones = 0;
        case (state)
          4:begin//num
            max_ones=9;
            max_tens=3;
            max_ones_on_max_tens=1;
          end
          5: begin//letter
            max_ones=9;
            max_tens=3;
            max_ones_on_max_tens=1;
          end
          7:begin//mouse_pos
            max_ones=8;
            max_ones_on_max_tens=8;
            max_tens=0;
          end
          default begin
            max_ones=0;
            max_tens=0;
            max_ones_on_max_tens=0;
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

