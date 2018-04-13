`timescale 1ns/1ps

module tb_freq();
/*
reg 	sclk;
reg		rst_n;
reg		pulse;
wire 	[31:0]	cnt_clk;
wire 	[31:0]	cnt_squ;
wire 	[31:0]	cnt_pulse;

initial	sclk = 1;
always	#5	sclk = ~sclk;

initial	begin
	rst_n = 0;
	#100
	rst_n = 1;
end

reg	[31:0]	cnt = 0;
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n)	cnt <= 0;
	else if(cnt == 35)	cnt <= 0;
	else cnt <= cnt + 1;
end
always@(posedge sclk or negedge rst_n)	begin
	if(!rst_n)	pulse <= 0;
	else if(cnt == 19)	pulse <= 0;
	else if(cnt == 34)	pulse <= 1;
end

//--------------------------------//
Freq_measure 	Freq_measure_inst0(
	.clk_100M	(sclk),
	.square		(pulse),
	.cnt_clk	(cnt_clk),
	.cnt_squ	(cnt_squ),
	.cnt_pulse	(cnt_pulse)
);
//--------------------------------//
*/
reg 	sclk;
reg		rst_n;
reg		pulse_r0;
reg		pulse_r1;
wire	[31:0]	cnt_time;

initial	sclk = 1;
always	#5	sclk = ~sclk;

initial	begin
	rst_n = 0;
	pulse_r0 = 0;
	pulse_r1 = 0;
	#100
	rst_n = 1;
	#500
	pulse_r0 <= 1;
	#1500
	pulse_r1 <= 1;
end

//---------------------//
Time_measure	Time_measure_inst0(
	.clk		(sclk),
	.rst_n		(rst_n),
	.squ_r0		(pulse_r0),
	.squ_r1		(pulse_r1),
	.cnt_time	(cnt_time)
);

endmodule