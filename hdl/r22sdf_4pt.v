// ==================================================================
// 	Engineer:				Brian Sune
//	File:					r22sdf_4pt.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					Butterfly Type-I
// ==================================================================


`timescale 1 ns/ 1 ps

module r22sdf_4pt#(
	parameter data_resolution	= 16,
	parameter delay_tick		= 0,
	parameter delay_stage		= 0,
	parameter ff_in_en			= 0,
	parameter ff_out_en			= 0,
	parameter dsp_ff_num		= 0
)(
	
	input								sys_clk,
	input								sys_nrst,
	input								sys_en,
	
	input	[data_resolution-1 : 0]		din_r,
	input	[data_resolution-1 : 0]		din_i,
	
	output	[data_resolution-1 : 0]		dout_r,
	output	[data_resolution-1 : 0]		dout_i
);
	
	// ==============================================================
	`include "logfunc.vh"
	// ==============================================================
	
	// ==============================================================
	localparam bf2i_delay = 4**(delay_stage)*2;
	localparam bf2ii_delay = 4**(delay_stage);
	
	localparam tick_bit_width = clog2(bf2i_delay);
	
	localparam tickd_ff_path_dsp = (dsp_ff_num * delay_tick);
	
	localparam tickd_ff_path_in_bf2i	= (ff_in_en > 0) ? (2 * delay_tick + 0) : 0;
	localparam tickd_ff_path_in_bf2ii	= (ff_in_en > 0) ? (2 * delay_tick + 1) : 0;
	
	localparam tickd_ff_path_out_bf2i	= (ff_out_en > 0) ? (2 * delay_tick + 0) : 0;
	localparam tickd_ff_path_out_bf2ii	= (ff_out_en > 0) ? (2 * delay_tick + 1) : 0;
	
	localparam tick_cnt_bf2i_init	= -(tickd_ff_path_in_bf2i + tickd_ff_path_out_bf2i + tickd_ff_path_dsp);
	localparam tick_cnt_bf2ii_init	= -(tickd_ff_path_in_bf2ii + tickd_ff_path_out_bf2ii + tickd_ff_path_dsp);
	
	// ==============================================================
	
	wire	[data_resolution-1 : 0]		d_bus_r;
	wire	[data_resolution-1 : 0]		d_bus_i;
	
	// ==============================================================
	reg		[tick_bit_width : 0]		tick_cnt_bf2i;
	
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			tick_cnt_bf2i <= tick_cnt_bf2i_init;
		end else begin
			if(sys_en)begin
				tick_cnt_bf2i <= tick_cnt_bf2i + 'd1;
			end
		end
	end
	
	bf2i#(
		.data_resolution	(data_resolution),
		.delay_num			(bf2i_delay),
		.ff_in_en			(ff_in_en),
		.ff_out_en			(ff_out_en)
	)bf2i_inst_s0(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en),
		
		.sel				(tick_cnt_bf2i[tick_bit_width]),
		
		.din_r				(din_r),
		.din_i				(din_i),
		
		.dout_r				(d_bus_r),
		.dout_i				(d_bus_i)
	);
	// ==============================================================
	
	// ==============================================================
	reg		[tick_bit_width : 0]		tick_cnt_bf2ii;
	
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			tick_cnt_bf2ii <= tick_cnt_bf2ii_init;
		end else begin
			if(sys_en)begin
				tick_cnt_bf2ii <= tick_cnt_bf2ii + 'd1;
			end
		end
	end
	
	bf2ii#(
		.data_resolution	(data_resolution),
		.delay_num			(bf2ii_delay),
		.ff_in_en			(ff_in_en),
		.ff_out_en			(ff_out_en)
	)bf2ii_inst_s0(
		.sys_clk			(sys_clk),
		.sys_nrst			(sys_nrst),
		.sys_en				(sys_en),
		
		.sel				(tick_cnt_bf2ii[tick_bit_width:tick_bit_width-1]),
		
		.din_r				(d_bus_r),
		.din_i				(d_bus_i),
		
		.dout_r				(dout_r),
		.dout_i				(dout_i)
	);
	// ==============================================================
	
endmodule
