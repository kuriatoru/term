`timescale 1ns / 1ps

module terminal(
	input wire clk,
	input wire RxD,
	output TxD,
	output wire Hsync,
	output wire Vsync,
	output wire [ 2 : 0 ] vgaRed,
	output wire [ 2 : 0 ] vgaGreen,
	output wire [ 1 : 0 ] vgaBlue,
	inout PS2KeyboardData,
	inout PS2KeyboardClk,
        output [7:0] seg,
        output [3:0] an
);

reg wr;
reg [7:0] mychar;
wire [7:0] scan;
wire [7:0] asciichar;
wire [7:0] rx_byte;
wire transmit;
wire received;
wire rst;

assign rst = 0;

ps2_host ps2_host(
	.sys_clk(clk),
	.sys_rst(rst),
	.ps2_clk(PS2KeyboardClk),
	.ps2_data(PS2KeyboardData),

	.tx_data(8'b0),
	.send_req(1'b0),
	/*.busy(busy),*/

	.rx_data(scan),
	.ready(ready),
	.error(error)
);

scan2ascii scan2ascii (
	.clk(clk),
	.rst(rst),
	.scan(scan),
	.scanrdy(ready),
	.ascii(asciichar),
	.asciirdy(transmit)
);

uart uart(
	.clk(clk),
	.rst(rst), 
	.rx(RxD), 
	.tx(TxD), 
	.transmit(transmit), 
	.tx_byte(asciichar), 
	.received(received), 
	.rx_byte(rx_byte), 
	.is_receiving(receiving),
        .is_transmitting(transmitting),
	.recv_error(recv_error) 
);

vga myvga(
	.clk(clk),
	.rst(rst),
	.we(received),
	.character(rx_byte),
	.Hsync(Hsync),
	.Vsync(Vsync),
	.vgaRed(vgaRed),
	.vgaGreen(vgaGreen),
	.vgaBlue(vgaBlue) 
);

reg [7:0] savedscan;

always @(posedge clk)
	if(ready)
		savedscan <= scan;

hexdisplay disp(
	.clk(clk),
	.word({8'b0, savedscan}),
	.seg(seg),
	.an(an)
);

endmodule
