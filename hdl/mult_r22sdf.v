// ==================================================================
// 	Engineer:				Brian Sune
//	File:					mult_r22sdf.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					Complex Multiplication
// ==================================================================


`timescale 1 ns/ 1 ps

module mult_r22sdf#(
	parameter data_resolution = 16
)(
	
	// input								sys_clk,
	// input								sys_nrst,
	// input								sys_en,
	
	input	[data_resolution-1 : 0]		din_r,
	input	[data_resolution-1 : 0]		din_i,
	
	input	[data_resolution : 0]		tw_fac_r,
	input	[data_resolution : 0]		tw_fac_i,
	
	output	[data_resolution-1 : 0]		dout_r,
	output	[data_resolution-1 : 0]		dout_i
);
	
	wire	[data_resolution*2+1 : 0]		mul_r;
	wire	[data_resolution*2+1 : 0]		mul_i;
	
	assign mul_r = $signed(din_r) * $signed(tw_fac_r) - $signed(din_i) * $signed(tw_fac_i);
	assign mul_i = $signed(din_i) * $signed(tw_fac_r) + $signed(din_r) * $signed(tw_fac_i);
	
	assign dout_r = mul_r[16 +: data_resolution];
	assign dout_i = mul_i[16 +: data_resolution];
	
endmodule
