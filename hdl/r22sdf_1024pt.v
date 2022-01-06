// ==================================================================
// 	Engineer:				Brian Sune
//	File:					r22sdf_1024pt.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					FFT R22-SDF
// ==================================================================


`timescale 1 ns/ 1 ps

module r22sdf_1024pt#(
	parameter data_resolution	= 16,
	parameter fft_length		= 1024,
	parameter inter_input_ff	= 1,
	parameter inter_output_ff	= 1,
	parameter dsp_ff_num		= 3
)(
	
	input								sys_clk,
	input								sys_nrst,
	input								sys_en,
	
	input	[data_resolution-1 : 0]		din_r,
	input	[data_resolution-1 : 0]		din_i,
	
	output	[data_resolution-1 : 0]		dout_r,
	output	[data_resolution-1 : 0]		dout_i
);
	
	wire	[data_resolution-1 : 0]		dout_r_4t3;
	wire	[data_resolution-1 : 0]		dout_i_4t3;
	
	wire	[data_resolution-1 : 0]		dout_r_3t2;
	wire	[data_resolution-1 : 0]		dout_i_3t2;
	
	wire	[data_resolution-1 : 0]		dout_r_2t1;
	wire	[data_resolution-1 : 0]		dout_i_2t1;
	
	wire	[data_resolution-1 : 0]		dout_r_1t0;
	wire	[data_resolution-1 : 0]		dout_i_1t0;
	
	wire					sys_en_glb;
	
	wire	[4 : 0]			cordic_rdy;
	
	assign sys_en_glb = sys_en & cordic_rdy[4];
	
	r22sdf_mod#(
		.mod_stage			(4),
		.data_resolution	(data_resolution),
		.fft_length			(fft_length),
		.ff_in_en			(inter_input_ff),
		.ff_out_en			(inter_output_ff),
		.dsp_ff_num			(dsp_ff_num)
	)r22sdf_mod_s4(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en),
		
		.sys_en_glb			(sys_en_glb),
		.cordic_rdy			(cordic_rdy[4]),
		
		.din_r				(din_r),
		.din_i				(din_i),
		.dout_r				(dout_r_4t3),
		.dout_i				(dout_i_4t3)
	);
	
	r22sdf_mod#(
		.mod_stage			(3),
		.data_resolution	(data_resolution),
		.fft_length			(fft_length),
		.ff_in_en			(inter_input_ff),
		.ff_out_en			(inter_output_ff),
		.dsp_ff_num			(dsp_ff_num)
	)r22sdf_mod_s3(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en),
		
		.sys_en_glb			(sys_en_glb),
		.cordic_rdy			(cordic_rdy[3]),
		
		.din_r				(dout_r_4t3),
		.din_i				(dout_i_4t3),
		.dout_r				(dout_r_3t2),
		.dout_i				(dout_i_3t2)
	);
	
	r22sdf_mod#(
		.mod_stage			(2),
		.data_resolution	(data_resolution),
		.fft_length			(fft_length),
		.ff_in_en			(inter_input_ff),
		.ff_out_en			(inter_output_ff),
		.dsp_ff_num			(dsp_ff_num)
	)r22sdf_mod_s2(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en),
		
		.sys_en_glb			(sys_en_glb),
		.cordic_rdy			(cordic_rdy[2]),
		
		.din_r				(dout_r_3t2),
		.din_i				(dout_i_3t2),
		.dout_r				(dout_r_2t1),
		.dout_i				(dout_i_2t1)
	);
	
	r22sdf_mod#(
		.mod_stage			(1),
		.data_resolution	(data_resolution),
		.fft_length			(fft_length),
		.ff_in_en			(inter_input_ff),
		.ff_out_en			(inter_output_ff),
		.dsp_ff_num			(dsp_ff_num)
	)r22sdf_mod_s1(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en),
		
		.sys_en_glb			(sys_en_glb),
		.cordic_rdy			(cordic_rdy[1]),
		
		.din_r				(dout_r_2t1),
		.din_i				(dout_i_2t1),
		.dout_r				(dout_r_1t0),
		.dout_i				(dout_i_1t0)
	);
	
	r22sdf_mod#(
		.mod_stage			(0),
		.data_resolution	(data_resolution),
		.fft_length			(fft_length),
		.ff_in_en			(inter_input_ff),
		.ff_out_en			(inter_output_ff),
		.dsp_ff_num			(dsp_ff_num)
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
