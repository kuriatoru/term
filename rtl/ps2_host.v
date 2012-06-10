/*
 * PS/2 Host controller
 */

`include "ps2_host_defines.v"

module ps2_host(
	input wire sys_clk,
	input wire sys_rst,
	inout wire ps2_clk,
	inout wire ps2_data,
 
	input  wire [7:0] tx_data,
	input  wire send_req,
	output wire busy,
 
	output wire [7:0] rx_data,
	output wire ready,
	output wire error
);
 
ps2_host_clk_ctrl ps2_host_clk_ctrl (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.send_req(send_req),
	.ps2_clk(ps2_clk),
	.ps2_clk_posedge(ps2_clk_posedge),
	.ps2_clk_negedge(ps2_clk_negedge)
);
 
ps2_host_watchdog ps2_host_watchdog(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.ps2_clk_posedge(ps2_clk_posedge),
	.ps2_clk_negedge(ps2_clk_negedge),
	.watchdog_rst(watchdog_rst)
);
 
ps2_host_rx ps2_host_rx(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst | busy | watchdog_rst),
	.ps2_clk_negedge(ps2_clk_negedge),
	.ps2_data(ps2_data),
	.rx_data(rx_data),
	.ready(ready),
	.error(error)
);
 
ps2_host_tx ps2_host_tx(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst | watchdog_rst),
	.ps2_clk_posedge(ps2_clk_posedge),
	.ps2_data(ps2_data),
	.tx_data(tx_data),
	.send_req(send_req),
	.busy(busy)
);
 
endmodule

module ps2_host_clk_ctrl(
	input  wire sys_clk,
	input  wire sys_rst,
	input  wire send_req,
	inout  wire ps2_clk,
	output wire ps2_clk_posedge,
	output wire ps2_clk_negedge
);
 
reg [1:0] ps2_clk_samples;
always @(posedge sys_clk)
	ps2_clk_samples <= sys_rst ? 2'b11 : {ps2_clk_samples[0], ps2_clk};

assign ps2_clk_posedge = ~ps2_clk_samples[1] &  ps2_clk_samples[0];
assign ps2_clk_negedge =  ps2_clk_samples[1] & ~ps2_clk_samples[0];
 
reg [`T_100_MICROSECONDS_SIZE - 1:0] inhibit_timer;
wire timer_is_zero = ~|inhibit_timer;

always @(posedge sys_clk)
	if(sys_rst | (~send_req & timer_is_zero))
		inhibit_timer <= 0;
	else
		inhibit_timer <= timer_is_zero ? `T_100_MICROSECONDS : inhibit_timer - 1;
 
assign ps2_clk = timer_is_zero ? 1'bz : 1'b0;
 
endmodule

module ps2_host_rx(
	input  wire sys_clk,
	input  wire sys_rst,
	input  wire ps2_clk_negedge,
	input  wire ps2_data,
	output reg [7:0] rx_data,
	output reg ready,
	output reg error
);
 
reg [11:0] frame;

always @(posedge sys_clk)
	if(sys_rst | ready)
		frame <= 1;
	else
		frame <= ps2_clk_negedge ? {frame[10:0], ps2_data} : frame;
 
always @(posedge sys_clk)
	ready <= frame[11] & ~sys_rst;
 
always @(posedge sys_clk)
	if(sys_rst)
		rx_data <= 0;
	else
		rx_data <= frame[11] ? {frame[2], frame[3], frame[4], frame[5], frame[6], frame[7], frame[8], frame[9]} : rx_data;
 
always @(posedge sys_clk)
	if(sys_rst)
		error <= 0;
	else
		error <= frame[11] ? ~(~frame[10] & (~frame[1] == ^frame[9:2]) & frame[0]) : error;
 
endmodule

module ps2_host_tx(
	input  wire sys_clk,
	input  wire sys_rst,
	input  wire ps2_clk_posedge,
	inout  wire ps2_data,
	input  wire [7:0] tx_data,
	input  wire send_req,
	output wire busy
);
 
reg [11:0] frame;
wire frame_is_zero = ~|frame;
always @(posedge sys_clk)
	if(sys_rst | (~send_req & frame_is_zero))
		frame <= 0;
	else if(frame_is_zero)
		frame <= {2'b00, tx_data[0], tx_data[1], tx_data[2], tx_data[3], tx_data[4], tx_data[5], tx_data[6], tx_data[7], ~^tx_data, 1'b1};
	else
		frame <= (ps2_clk_posedge) ? {frame[10:0], 1'b0} : frame;
 
assign ps2_data = ((~|frame[10:0]) | frame[0]) ? 1'bz : frame[11];
 
assign busy = ~frame_is_zero;
 
endmodule

module ps2_host_watchdog(
	input  wire sys_clk,
	input  wire sys_rst,
	input  wire ps2_clk_posedge,
	input  wire ps2_clk_negedge,
	output wire watchdog_rst
);
 
wire ps2_clk_edge = ps2_clk_posedge | ps2_clk_negedge;
 
reg watchdog_active;
always @(posedge sys_clk)
	if(sys_rst | watchdog_rst | ~(watchdog_active | ps2_clk_edge))
		watchdog_active = 0;
	else
		watchdog_active = 1;
 
reg [`T_200_MICROSECONDS_SIZE - 1:0] watchdog_timer;
always @(posedge sys_clk)
	if(sys_rst | watchdog_rst | ~watchdog_active | ps2_clk_edge)
		watchdog_timer <= `T_200_MICROSECONDS;
	else
		watchdog_timer <= watchdog_timer - 1;
 
assign watchdog_rst = (|watchdog_timer) ? 1'b0 : 1'b1;
 
endmodule
