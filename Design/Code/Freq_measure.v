module Freq_measure
(
	input		wire		clk_100M,
	input		wire 		square,
	output	wire		[31:0]	cnt_clk,			//闸门内系统时钟周期计数
	output	wire		[31:0]	cnt_squ,			//闸门内方波时钟周期计数
	output	wire		[31:0]	cnt_pulse			//闸门内脉冲占空比计数
);

//同步方波和时钟，打两拍处理
reg	square_r0 = 1'b0;
reg	square_r1 = 1'b0;
always@(posedge clk_100M)
begin
	square_r0 <= square;
	square_r1 <= square_r0;	//打一拍可能会产生亚稳态
end

//捕捉方波边沿
reg	square_r2 = 1'b0;
reg	square_r3 = 1'b0;
wire	square_pose,square_nege;
always@(posedge clk_100M)
begin
	square_r2 <= square_r1;
	square_r3 <= square_r2;
end
assign	square_pose = square_r2 & ~square_r3;
assign	square_nege = ~square_r2 & square_r3;

//产生 1s 闸门信号
reg	[31:0]cnt1 = 32'd0;		//产生 1s 的闸门信号计数器
reg	gate = 1'b0;				//闸门信号
always@(posedge clk_100M)
begin
	if(cnt1 == 32'd99_999_999)	begin		//***********
		cnt1 <= 32'd0;
		gate <= ~gate;
	end
	else	begin
		cnt1 <= cnt1+1'b1;
	end
end

//产生与方波同步之后的闸门信号
reg	gatebuf = 1'b0;
always@(posedge clk_100M)
begin
	if(square_pose == 1'b1)
		gatebuf <= gate;		//使闸门信号与待测信号同步，保证一个闸门内包含整数个方波周期
end
reg	gatebuf1 = 1'b0;		//同步闸门信号延时一拍
always@(posedge clk_100M)
begin
		gatebuf1 <= gatebuf;
end

wire	gate_start;
wire	gate_end;
assign	gate_start = gatebuf & ~gatebuf1;		//闸门开启时刻
assign	gate_end   = ~gatebuf & gatebuf1;		//闸门关闭时刻

//计数系统时钟周期
reg	[31:0] cnt2  = 32'd0;
reg	[31:0] cnt2_r = 32'd0;
always@(posedge clk_100M)
begin
	if(gate_start == 1'b1) begin
		cnt2 <= 32'd0;
	end
	else if(gate_end == 1'b1) begin
		cnt2_r <= cnt2;
		cnt2   <= 32'd0;		//将所得结果保存在cnt2_r中，并将计数器清零
	end
	else if(gatebuf1 == 1'b1) begin		//在闸门内计算系统时钟周期
		cnt2 <= cnt2 + 1'b1;
	end
end
assign	cnt_clk = cnt2_r;

//计算待测信号周期数
reg	[31:0] cnt3 = 32'd0;
reg	[31:0] cnt3_r = 32'd0;
always@(posedge clk_100M)
begin
	if(gate_start == 1'b1) begin
		cnt3 <= 32'd0;
	end
	else if(gate_end == 1'b1) begin
		cnt3_r <= cnt3;
		cnt3   <= 32'd0;
	end
	else if(gatebuf1 == 1'b1 && square_nege == 1'b1) begin	//在闸门内计算信号周期数（方波下降沿）
		cnt3 <= cnt3 + 1'b1;
	end
end
assign	cnt_squ = cnt3_r;

//计算待测信号占空比
reg	[31:0]	cnt4 = 32'd0;
reg	[31:0]	cnt4_r = 32'd0;
always@(posedge clk_100M)
begin	
	if(gate_start == 1'b1)	begin
		cnt4 <= 32'd0;
	end
	else if(gate_end == 1'b1)	begin
		cnt4_r <= cnt4;
		cnt4   <= 32'd0;
	end
	else if(gatebuf1 == 1'b1 && square == 1'b1)	begin
		cnt4 <= cnt4 + 1'b1;
	end
end
assign	cnt_pulse = cnt4_r;

endmodule
