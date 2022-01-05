// ==================================================================
// 	Engineer:				Brian Sune
//	File:					r22sdf_mod.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					R22SDF Module
// ==================================================================


`timescale 1 ns/ 1 ps

module r22sdf_mod#(
	parameter data_resolution	= 16,
	parameter fft_length		= 4,
	parameter mod_stage			= 0,
	parameter ff_in_en			= 0
)(
	input								sys_clk,
	input								sys_nrst,
	input								sys_en,
	
	input	[data_resolution-1 : 0]		din_r,
	input	[data_resolution-1 : 0]		din_i,
	
	input								sys_en_glb,
	output								cordic_rdy,
	
	output	[data_resolution-1 : 0]		dout_r,
	output	[data_resolution-1 : 0]		dout_i
);
	
	// =========================================================
	// LOG BASE 4
	// =========================================================
	function integer clog4;
		input integer value;
		begin  
			value = value-1;
			for (clog4=0; value>0; clog4=clog4+1)
				value = value>>2;
			end  
	endfunction
	// =========================================================
	
	localparam delay_tick		= clog4(fft_length) - 1 - mod_stage;
	localparam delay_stage		= mod_stage;
	localparam division			= 4**(mod_stage + 1);
	
	wire	[data_resolution-1 : 0]		dout_r_w;
	wire	[data_resolution-1 : 0]		dout_i_w;
	
	r22sdf_4pt#(
		.data_resolution	(data_resolution),
		.delay_tick			(delay_tick),
		.delay_stage		(mod_stage),
		.ff_in_en			(ff_in_en)
	)r22sdf_4pt_inst0(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en_glb),
		.din_r				(din_r),
		.din_i				(din_i),
		.dout_r				(dout_r_w),
		.dout_i				(dout_i_w)
	);
	
	generate
		if(mod_stage > 0)begin: intermediate_stages
			
			wire	[data_resolution : 0]		tw_fac_r;
			wire	[data_resolution : 0]		tw_fac_i;
			
			wire	[data_resolution-1 : 0]		dout_r_mul;
			wire	[data_resolution-1 : 0]		dout_i_mul;
			
			twiddle_mod#(
				.division			(division),
				.fft_length			(fft_length),
				.ff_in_en			(ff_in_en)
			)twiddle_mod_inst0(
				.sys_clk			(sys_clk),
				.sys_nrst			(sys_nrst),
				.sys_en				(sys_en),
				.tw_fac_r			(tw_fac_r),
				.tw_fac_i			(tw_fac_i),
				.cordic_rdy			(cordic_rdy)
			);
			
			mult_r22sdf#(
				.data_resolution	(data_resolution)
			)mult_r22sdf_inst0(
				.din_r				(dout_r_w),
				.din_i				(dout_i_w),
				.tw_fac_r			(tw_fac_r),
				.tw_fac_i			(tw_fac_i),
				.dout_r				(dout_r_mul),
				.dout_i				(dout_i_mul)
			);
			
			assign dout_r = dout_r_mul;
			assign dout_i = dout_i_mul;
			
		end else begin
			assign cordic_rdy = 1;
			assign dout_r = dout_r_w;
			assign dout_i = dout_i_w;
		end
	endgenerate

endmodule
