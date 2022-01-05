// ==================================================================
// 	Engineer:				Brian Sune
//	File:					r22sdf_16pt.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					FFT R22-SDF
// ==================================================================


`timescale 1 ns/ 1 ps

module r22sdf_16pt#(
	parameter data_resolution = 16,
	parameter fft_length = 16,
	parameter intermediate_ff = 0
)(
	
	input								sys_clk,
	input								sys_nrst,
	input								sys_en,
	
	input	[data_resolution-1 : 0]		din_r,
	input	[data_resolution-1 : 0]		din_i,
	
	output	[data_resolution-1 : 0]		dout_r,
	output	[data_resolution-1 : 0]		dout_i
);
	
	wire	[data_resolution-1 : 0]		dout_r_1t0;
	wire	[data_resolution-1 : 0]		dout_i_1t0;
	
	wire					sys_en_glb;
	
	wire	[1 : 0]			cordic_rdy;
	
	assign sys_en_glb = sys_en & cordic_rdy[1];
	
	r22sdf_mod#(
		.data_resolution	(data_resolution),
		.fft_length			(fft_length),
		.mod_stage			(1),
		.ff_in_en			(intermediate_ff)
	)r22sdf_mod_s1(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en),
		
		.sys_en_glb			(sys_en_glb),
		.cordic_rdy			(cordic_rdy[1]),
		
		.din_r				(din_r),
		.din_i				(din_i),
		.dout_r				(dout_r_1t0),
		.dout_i				(dout_i_1t0)
	);
	
	r22sdf_mod#(
		.data_resolution	(data_resolution),
		.fft_length			(fft_length),
		.mod_stage			(0),
		.ff_in_en			(intermediate_ff)
	)r22sdf_mod_s0(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en),
		
		.sys_en_glb			(sys_en_glb),
		.cordic_rdy			(cordic_rdy[0]),
		
		.din_r				(dout_r_1t0),
		.din_i				(dout_i_1t0),
		.dout_r				(dout_r),
		.dout_i				(dout_i)
	);
	
endmodule
