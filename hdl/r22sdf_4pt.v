// ==================================================================
// 	Engineer:				Brian Sune
//	File:					r22sdf_4pt.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					R22SDF 4PT Base
// ==================================================================


`timescale 1 ns/ 1 ps

module r22sdf_4pt#(
	parameter data_resolution	= 16,
	parameter delay_tick		= 0,
	parameter delay_stage		= 0,
	parameter ff_in_en			= 1,
	parameter ff_out_en			= 0
)(
	
	input								sys_clk,
	input								sys_nrst,
	input								sys_en,
	
	input	[data_resolution-1 : 0]		din_r,
	input	[data_resolution-1 : 0]		din_i,
	
	output	[data_resolution-1 : 0]		dout_r,
	output	[data_resolution-1 : 0]		dout_i
);
	// =========================================================
	// LOG BASE 2
	// =========================================================
	function integer clog2;
		input integer value;
		begin  
			value = value-1;
			for (clog2=0; value>0; clog2=clog2+1)
				value = value>>1;
			end  
	endfunction
	// =========================================================
	
	localparam bf2i_delay = 4**(delay_stage)*2;
	localparam bf2ii_delay = 4**(delay_stage);
	
	localparam tick_bit_width = clog2(bf2i_delay);
	
	wire	[data_resolution-1 : 0]		d_bus_r;
	wire	[data_resolution-1 : 0]		d_bus_i;
	
	reg		[tick_bit_width : 0]		tick_cnt_bf2i;
	reg		[tick_bit_width : 0]		tick_cnt_bf2ii;
	
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			tick_cnt_bf2i <= -(ff_in_en * 2 * delay_tick);
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
		.ff_out_en			(0)
	)bf2i_inst_s0(
		.sys_clk	(sys_clk),
		.sys_nrst	(sys_nrst),
		.sys_en		(sys_en),
		
		.sel		(tick_cnt_bf2i[tick_bit_width]),
		
		.din_r		(din_r),
		.din_i		(din_i),
		
		.dout_r		(d_bus_r),
		.dout_i		(d_bus_i)
	);
	
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			tick_cnt_bf2ii <= -(ff_in_en * (2 * delay_tick + 1));
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
		.sys_clk	(sys_clk),
		.sys_nrst	(sys_nrst),
		.sys_en		(sys_en),
		
		.sel		(tick_cnt_bf2ii[tick_bit_width:tick_bit_width-1]),
		
		.din_r		(d_bus_r),
		.din_i		(d_bus_i),
		
		.dout_r		(dout_r),
		.dout_i		(dout_i)
	);
	
endmodule
