// This is to start the multiply module
// It begins here.
module counter(
// Clock Input (50 MHz)
  input  CLOCK_50,
  //  Push Buttons
  input  [3:0]  KEY,
  //  DPDT Switches 
  input  [17:0]  SW,
  
   //  7-SEG Displays  
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  output [2:0] sum,
  output cout,
  // This is added to the convert the 8-bits to different HEX_
  output [3:0] ONES, TENS,HUNDREDS,
  //  LEDs
  output  [8:0]  LEDG,  //  LED Green[8:0]
  output  [17:0]  LEDR, //  LED Red[17:0]
  //  GPIO Connections
  inout  [35:0]  GPIO_0, GPIO_1
);
//  set all inout ports to tri-state
assign  GPIO_0    =  36'hzzzzzzzzz;
assign  GPIO_1    =  36'hzzzzzzzzz;

// Connect dip switches to red LEDs
assign LEDR[17:0] = SW[17:0];
wire [15:0] A;
//always @(negedge KEY[3])
//    A <= SW[15:0];
// The algorithm to be used comes here.
// This time we use counter code here.
//module countercode(D,clk,load,Q);
countercode(SW[2:0],KEY[0],KEY[1],sum[2:0]);

// Before assigning the 8-bit sum to different HEX,
// we call this module to send the desired decimal.
// multiply_to_BCD(A,ONES, TENS, HUNDREDS);
BCD(sum[2:0],HUNDREDS,TENS,ONES);
hex_7seg dsp0(ONES,HEX0);
hex_7seg dsp1(TENS,HEX1);
hex_7seg dsp2(HUNDREDS,HEX2);
assign HEX3 = blank;
assign HEX4 = blank;
assign HEX5 = blank;
assign HEX6 = blank;
assign HEX7 = blank;

wire [6:0] blank = ~7'h00;
assign A = SW[15:0];
endmodule

module hex_7seg(hex_digit,seg);
input [3:0] hex_digit;
output [6:0] seg;
reg [6:0] seg;
// seg = {g,f,e,d,c,b,a};
// 0 is on and 1 is off

always @ (hex_digit)
case (hex_digit)
        4'h0: seg = ~7'h3F;
        4'h1: seg = ~7'h06;     // ---a----
        4'h2: seg = ~7'h5B;     // |      |
        4'h3: seg = ~7'h4F;     // f      b
        4'h4: seg = ~7'h66;     // |      |
        4'h5: seg = ~7'h6D;     // ---g----
        4'h6: seg = ~7'h7D;     // |      |
        4'h7: seg = ~7'h07;     // e      c
        4'h8: seg = ~7'h7F;     // |      |
        4'h9: seg = ~7'h67;     // ---d----
        4'ha: seg = ~7'h77;
        4'hb: seg = ~7'h7C;
        4'hc: seg = ~7'h39;
        4'hd: seg = ~7'h5E;
        4'he: seg = ~7'h79;
        4'hf: seg = ~7'h71;
endcase
endmodule

module T_FF (T,Clock,Q);
/* Port modes */
input T,Clock;
output Q;
// Registered identifiers
reg Q;
// Functionality
always @ (posedge Clock)	
	if (T == 1)
	   Q <= ~Q;
endmodule 

module BCD(
input  [7:0] binary,
output reg [3:0] Hundreds,
output reg[3:0] Tens,
output reg[3:0] Ones
);
integer i; 
always @ (binary)
begin 
//set 100's 10's and 1's to zero
Hundreds = 4'd0;
Tens     = 4'd0;
Ones     = 4'd0;
for(i=7; i >= 0; i=i-1)
begin
      if(Hundreds >= 5)
           Hundreds = Hundreds + 3;
		if(Tens >= 5)
           Tens = Tens + 3;
		if(Ones >= 5)
           Ones = Ones + 3;
	//Shift left one bit
	Hundreds = Hundreds << 1;
	Hundreds[0]=Tens[3];
	Tens = Tens << 1;
	Tens[0]= Ones[3];
	Ones = Ones << 1;
	Ones[0]=binary[i];
end     // begin end comes
end     // begin end comes
endmodule

module countercode(D,clk,load,Q);
input[2:0] D;
input clk;
input load;
output [2:0] Q;

wire  DA1,DB1,DB2,DB3,DC1,DC2,DC3;
reg [2:0] cnt;
// A =cnt[0]  B=cnt[1]  C=cnt[2]
always@(negedge clk)
begin
   if(~load)
   cnt=D;
  else 
   cnt =Q;
  end
  
  // Sequence is 001, 011, 010, 110, 111, 101, 100 (repeat) 001……
  // Digital      1    3    2    6    7    5     4           1

   // code Ta flip flop
   // Ta = C’BA + CB’+CA’
   // A =cnt[0]  B=cnt[1]  C=cnt[2]

assign DA1 = (~cnt[2]&cnt[1]&cnt[0])|(cnt[2]&~cnt[1])|(cnt[2]&~cnt[0]);
T_FF(DA1,clk,Q[0]);
 
  // Code for Tb flip flip
 // Tb = C’B’ + CBA
 // A =cnt[0]  B=cnt[1]  C=cnt[2]
assign DB1 = (~cnt[2]&~cnt[1])|(cnt[2]&cnt[1]&cnt[0]);   
T_FF(DB1,clk,Q[1]);

  // Code for Tc  Flip flop
  // A =cnt[0]  B=cnt[1]  C=cnt[2]
 // Tc = C’A’ + B’A’
assign DC1 = (~cnt[2]&~cnt[0])|(~cnt[1]&~cnt[0]);
T_FF(DC1,clk,Q[2]);
endmodule 
