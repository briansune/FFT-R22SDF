// ==================================================================
// 	Engineer:				Brian Sune
//	File:					cordic.v
//	Date (YYYY,MM,DD):		2021/12/16
//	Aim:					SQRT / COS / SIN CORDIC
// ==================================================================


`timescale 1 ns/ 1 ps

module cordic#(
	parameter pipeline = 16
)(
	input				sys_clk,
	input				sys_nrst,
	input				sys_en,
	
	input	[15 : 0]	phase_in,
	output	[16 : 0]	eps,
	output	[16 : 0]	sin,
	output	[16 : 0]	cos
);
	
	// gian 0.607253*2^15
	//parameter const_k = 16'h4dba;
	// gian 0.607253*2^16
	localparam const_k = 16'h9b74;
	
	reg 			[15 : 0]	rot			[15 : 0];
	
	// 360°	-- 2^16
	// 1°	-- 2^16/360
	// phase_in = 16bits (input [15:0] phase_in)
	initial begin
		rot[0]		= 16'h2000;    //45
		rot[1]		= 16'h12e4;    //26.5651
		rot[2]		= 16'h09fb;    //14.0362
		rot[3]		= 16'h0511;    //7.1250
		rot[4]		= 16'h028b;    //3.5763
		rot[5]		= 16'h0145;    //1.7899
		rot[6]		= 16'h00a3;    //0.8952
		rot[7]		= 16'h0051;    //0.4476
		rot[8]		= 16'h0028;    //0.2238
		rot[9]		= 16'h0014;    //0.1119
		rot[10]		= 16'h000a;    //0.0560
		rot[11]		= 16'h0005;    //0.0280
		rot[12]		= 16'h0003;    //0.0140
		rot[13]		= 16'h0002;    //0.0070
		rot[14]		= 16'h0001;    //0.0035
		rot[15]		= 16'h0000;    //0.0018
	end
	
	reg signed		[16 : 0]	eps_r;
	reg signed		[16 : 0]	sin_r;
	reg signed		[16 : 0]	cos_r;
	
	//pipeline 16-level    //maybe overflow,matlab result not overflow
	//MSB is signed bit,transform the sin and cos according to phase_in[15:14]
	
	reg signed		[16 : 0]	x			[pipeline : 0];
	reg signed		[16 : 0]	y			[pipeline : 0];
	reg signed		[16 : 0]	z			[pipeline : 0];
	reg				[1 : 0]		quadrant	[pipeline : 0];
	
	//stage 0, not pipeline
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			x[0] <= 17'b0;
			y[0] <= 17'b0;
			z[0] <= 17'b0;
		end else begin
			if(sys_en)begin
				//add one signed bit,0 means positive
				x[0] <= {1'b0, const_k};
				y[0] <= 17'b0;
				//control the phase_in to the range[0-Pi/2]
				z[0] <= {3'b0,phase_in[13:0]};
			end
		end
	end
	
	//stage 1
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			x[1] <= 17'b0;
			y[1] <= 17'b0;
			z[1] <= 17'b0;
		end else begin
			if(sys_en)begin
				//the diff is negative so clockwise
				if(z[0][16])begin
					x[1] <= x[0] + y[0];
					y[1] <= x[0] - y[0];
					z[1] <= z[0] + rot[0];
				end else begin
					x[1] <= x[0] - y[0];//x1 <= x0;
					y[1] <= x[0] + y[0];//y1 <= x0;
					z[1] <= z[0] - rot[0];//reversal 45
				end
			end
		end
	end
	
	generate
		genvar j;
		for(j = 2; j <= pipeline; j = j + 1)begin : pipeline_comp_loop0
			always@(posedge sys_clk or negedge sys_nrst)begin
				if(!sys_nrst)begin
					x[j] <= 17'b0;
					y[j] <= 17'b0;
					z[j] <= 17'b0;
				end else begin
					if(sys_en)begin
						//the diff is negative so clockwise
						if(z[j-1][16])begin
							x[j] <= x[j-1] + (y[j-1]>>>(j-1));
							y[j] <= y[j-1] - (x[j-1]>>>(j-1));
							z[j] <= z[j-1] + rot[j-1];//clockwise 26
						end else begin
							x[j] <= x[j-1] - (y[j-1]>>>(j-1));
							y[j] <= y[j-1] + (x[j-1]>>>(j-1));
							z[j] <= z[j-1] - rot[j-1];//anti-clockwise 26
						end
					end
				end
			end
		end
	endgenerate
	
	
	//according to the pipeline,register phase_in[15:14]
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			quadrant[0] <= 'b0;
		end else begin
			if(sys_en)begin
				quadrant[0] <= phase_in[15:14];
			end
		end
	end
	
	generate
		genvar i;
		for(i = 1; i <= pipeline; i = i + 1)begin : pipeline_loop0
			always@(posedge sys_clk or negedge sys_nrst)begin
				if(!sys_nrst)begin
					quadrant[i] <= 'b0;
				end else begin
					if(sys_en)begin
						quadrant[i] <= quadrant[i-1];
					end
				end
			end
		end
	endgenerate
	
	assign sin = sin_r;
	assign cos = cos_r;
	assign eps = eps_r;
	
	//alter register, according to quadrant[16] to transform the result to the right result
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			eps_r <= 'd0;
		end else begin
			if(sys_en)begin
				eps_r <= z[16];
			end
		end
	end
	
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			cos_r <= 'd0;
			sin_r <= 'd0;
		end else begin
			if(sys_en)begin
				//or 15
				case(quadrant[16])
					//if the phase is in first quadrant,the sin_r(X)=sin(A),cos(X)=cos(A)
					2'b00:begin
						cos_r <= $signed(x[16]);
						sin_r <= $signed(y[16]);
					end
					//if the phase is in second quadrant,the sin(X)=sin(A+90)=cosA,cos(X)=cos(A+90)=-sinA
					2'b01:begin
						cos_r <= -$signed(y[16]);//-sin
						sin_r <= $signed(x[16]);//cos
					end
					//if the phase is in third quadrant,the sin(X)=sin(A+180)=-sinA,cos(X)=cos(A+180)=-cosA
					2'b10:begin
						cos_r <= -$signed(x[16]);//-cos
						sin_r <= -$signed(y[16]);//-sin
					end
					//if the phase is in forth quadrant,the sin(X)=sin(A+270)=-cosA,cos(X)=cos(A+270)=sinA
					2'b11:begin
						cos_r <= $signed(y[16]);//sin
						sin_r <= -$signed(x[16]);//-cos
					end
				endcase
			end
		end
	end
	
endmodule
