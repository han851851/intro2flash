`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  // Your code goes here...

	/*
	input logic clk,
	input logic nRST,
	input logic serial_in,
	input logic start,
	//output logic ready,
	output logic serial_out,
	output logic done,
	output logic recieve
	*/

	top_mod inst0 (.clk(hz100), .nRST(reset), .load_btn(pb[18]), .start_btn(pb[19]), .pb_in(pb[15:0]), .hex0(ss0), .hex1(ss1), .hex2(ss2), .hex3(ss3), .hex4(ss4), .hex5(ss5), .hex6(ss6), .hex7(ss7), .done(red), ) 

endmodule
