// ==================================================================
// 	Engineer:				Brian Sune
//	File:					mult_r22sdf.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					Complex Multiplication
// ==================================================================


`timescale 1 ns/ 1 ps

module mult_r22sdf#(
	parameter data_resolution = 16,
	parameter pipeline_num = 0
)(
	
	input								sys_clk,
	input								sys_nrst,
	input								sys_en,
	
	input	[data_resolution-1 : 0]		din_r,
	input	[data_resolution-1 : 0]		din_i,
	
	input	[data_resolution : 0]		tw_fac_r,
	input	[data_resolution : 0]		tw_fac_i,
	
	output	[data_resolution-1 : 0]		dout_r,
	output	[data_resolution-1 : 0]		dout_i
);
	
	wire	[data_resolution*2+1 : 0]		mul_r;
	wire	[data_resolution*2+1 : 0]		mul_i;
	
	wire									glb_rst;
	
	assign glb_rst = !sys_nrst;
	
	// a+bj * c+dj > ac-bd + bcj + adj
	
			// always@(posedge sys_clk)begin
				// if(glb_rst)begin
	
			// always@(posedge sys_clk or negedge sys_nrst)begin
				// if(!sys_nrst)begin
	
	generate
		if(pipeline_num == 1)begin: BALANCE_PIPELINE
			
			reg		[data_resolution*2 : 0]		r_ac;
			reg		[data_resolution*2 : 0]		r_bd;
			reg		[data_resolution*2 : 0]		r_bc;
			reg		[data_resolution*2 : 0]		r_ad;
			
			always@(posedge sys_clk)begin
				if(glb_rst)begin
					r_ac <= 'd0;
					r_bd <= 'd0;
					r_bc <= 'd0;
					r_ad <= 'd0;
				end else if(sys_en) begin
					r_ac <= $signed(din_r) * $signed(tw_fac_r);
					r_bd <= $signed(din_i) * $signed(tw_fac_i);
					r_bc <= $signed(din_i) * $signed(tw_fac_r);
					r_ad <= $signed(din_r) * $signed(tw_fac_i);
				end
			end
			
			assign mul_r = $signed(r_ac) - $signed(r_bd);
			assign mul_i = $signed(r_bc) + $signed(r_ad);
			
		end else if(pipeline_num == 2)begin: INTERMEDIATE_OUT_PIPELINE
			
			reg		[data_resolution*2 : 0]		r_ac;
			reg		[data_resolution*2 : 0]		r_bd;
			reg		[data_resolution*2 : 0]		r_bc;
			reg		[data_resolution*2 : 0]		r_ad;
			
			reg		[data_resolution*2+1 : 0]	mul_r_r;
			reg		[data_resolution*2+1 : 0]	mul_i_r;
			
			always@(posedge sys_clk)begin
				if(glb_rst)begin
					r_ac <= 'd0;
					r_bd <= 'd0;
					r_bc <= 'd0;
					r_ad <= 'd0;
				end else if(sys_en) begin
					r_ac <= $signed(din_r) * $signed(tw_fac_r);
					r_bd <= $signed(din_i) * $signed(tw_fac_i);
					r_bc <= $signed(din_i) * $signed(tw_fac_r);
					r_ad <= $signed(din_r) * $signed(tw_fac_i);
				end
			end
			
			always@(posedge sys_clk)begin
				if(glb_rst)begin
					mul_r_r <= 'd0;
					mul_i_r <= 'd0;
				end else if(sys_en) begin
					mul_r_r <= $signed(r_ac) - $signed(r_bd);
					mul_i_r <= $signed(r_bc) + $signed(r_ad);
				end
			end
			
			assign mul_r = mul_r_r;
			assign mul_i = mul_i_r;
		
		end else if(pipeline_num == 3)begin: IO_INTER_PIPELINE
			
			reg		[data_resolution-1 : 0]		din_r_r;
			reg		[data_resolution-1 : 0]		din_i_r;
			
			reg		[data_resolution : 0]		tw_fac_r_r;
			reg		[data_resolution : 0]		tw_fac_i_r;
			
			reg		[data_resolution*2 : 0]		r_ac;
			reg		[data_resolution*2 : 0]		r_bd;
			reg		[data_resolution*2 : 0]		r_bc;
			reg		[data_resolution*2 : 0]		r_ad;
			
			reg		[data_resolution*2+1 : 0]	mul_r_r;
			reg		[data_resolution*2+1 : 0]	mul_i_r;
			
			always@(posedge sys_clk)begin
				if(glb_rst)begin
					din_r_r <= 'd0;
					din_i_r <= 'd0;
					tw_fac_r_r <= 'd0;
					tw_fac_i_r <= 'd0;
				end else if(sys_en) begin
					din_r_r <= din_r;
					din_i_r <= din_i;
					tw_fac_r_r <= tw_fac_r;
					tw_fac_i_r <= tw_fac_i;
				end
			end
			
			always@(posedge sys_clk)begin
				if(glb_rst)begin
					r_ac <= 'd0;
					r_bd <= 'd0;
					r_bc <= 'd0;
					r_ad <= 'd0;
				end else if(sys_en) begin
					r_ac <= $signed(din_r_r) * $signed(tw_fac_r_r);
					r_bd <= $signed(din_i_r) * $signed(tw_fac_i_r);
					r_bc <= $signed(din_i_r) * $signed(tw_fac_r_r);
					r_ad <= $signed(din_r_r) * $signed(tw_fac_i_r);
				end
			end
			
			always@(posedge sys_clk)begin
				if(glb_rst)begin
					mul_r_r <= 'd0;
					mul_i_r <= 'd0;
				end else if(sys_en) begin
					mul_r_r <= $signed(r_ac) - $signed(r_bd);
					mul_i_r <= $signed(r_bc) + $signed(r_ad);
				end
			end
			
			assign mul_r = mul_r_r;
			assign mul_i = mul_i_r;
			
		end else begin: NO_PIPELINE
			
			assign mul_r = $signed(din_r) * $signed(tw_fac_r) - $signed(din_i) * $signed(tw_fac_i);
			assign mul_i = $signed(din_i) * $signed(tw_fac_r) + $signed(din_r) * $signed(tw_fac_i);
			
		end
	endgenerate
	
	assign dout_r = mul_r[16 +: data_resolution];
	assign dout_i = mul_i[16 +: data_resolution];
	
endmodule
