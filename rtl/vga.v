module vga (
	input wire clk,
	input wire rst,
	input wire we,
	input wire [7:0] character,
	output reg  Hsync,
	output reg  Vsync,
	output reg  [ 2 : 0 ] vgaRed,
	output reg  [ 2 : 0 ] vgaGreen,
	output reg  [ 1 : 0 ] vgaBlue
);

wire printable;
reg pxclk;
reg [8:0] column;
reg [3:0] crow;
reg [2:0] ccolumn;
reg [5:0] row;
reg [7:0] char;
reg [8:0] X = 9'b0;
reg [5:0] Y = 6'b0;

reg [11 : 0] sweeper = 12'd3200;

reg iscur;
reg [1 : 0] count = 0;
reg [7 : 0] videomem [3199 : 0];
reg [7 : 0] fontmem[3071 : 0];
initial $readmemh("1.hex", videomem);
initial $readmemh("lat0-12.mem", fontmem);

assign printable = character >= 32 && character <= 126;
always @(posedge clk) 
	if(sweeper != 3200) begin
		videomem[sweeper] <= 8'h20;
		sweeper <= sweeper + 12'b1;
	end else begin
	if(we) begin
		if(X == 9'd79 || character == 8'd13) // Carriage return 
			X <= 0;
		else
			if(printable)
				X <= X + 1;

		if(X != 9'd00 && character == 8'h08) // backspace
			X <= X - 1;

		if(X == 9'd79 || character == 8'd10) // Line feed
			if(Y == 6'd39) begin
				Y <= 6'b0;
				sweeper <= 0;
			end else
				Y <= Y + 1;
	end 
		count <= count + 1'b1;
	if(we && printable)
		videomem[Y*80+X]<=character;

	if((hsync_count>11'd159)&&(vsync_count>11'd40)) begin
		column<= (hsync_count-11'd159)/8;
		ccolumn <= (hsync_count-11'd159)%8;
		row <= (vsync_count-11'd40)/12;
		crow <= (vsync_count-11'd40)%12;
		char <= videomem[row*80+column];
		iscur=((column==X)&&(row==Y));
		if(iscur) begin
			if((fontmem[char*12+crow][3'b111-ccolumn])==1'b1) begin
				vgaRed <= 3'b0;
				vgaGreen <=  3'b0;
				vgaBlue <=  2'b0; 
			end else begin
				vgaRed <= 3'b111;
				vgaGreen <= 3'b111;
				vgaBlue <= 2'b11;
			end
		end else
			if((fontmem[char*12+crow][3'b111-ccolumn]) == 1'b1) begin
				vgaRed <= 3'b111;
				vgaGreen <=  3'b111;
				vgaBlue <=  2'b11; 
			end else begin
				vgaRed <= 3'b0;
				vgaGreen <= 3'b0;
				vgaBlue <= 2'b0;
			end
	end else begin
		vgaRed <= 3'b0;
		vgaGreen <= 3'b0;
		vgaBlue <= 2'b0;
	end
end

always @(posedge clk)
	pxclk <= count[1]; // 25Mhz pixel clock

reg [ 10 : 0 ] hsync_count;
reg [  9 : 0 ] vsync_count;

always @(posedge pxclk)
	if(rst)
		hsync_count <= 11'd0;
	else if(hsync_count == 11'd799)
		hsync_count <= 11'd0;
	else
		hsync_count <= hsync_count + 1'd1;

always @(posedge pxclk)
	if(rst)
		Hsync <= 1'b1;
	else if(hsync_count == 11'd15)
		Hsync <= 1'b0;
	else if(hsync_count == 11'd111)
		Hsync <= 1'b1;

always @(posedge pxclk)
	if(rst)
		vsync_count <= 10'd0;
	else if(hsync_count == 11'd799) begin
		if(vsync_count == 11'd520)
			vsync_count <= 10'd0;
		else
			vsync_count <= vsync_count + 1'b1;
	end

always @(posedge pxclk)
	if(rst)
		Vsync <= 1'b1;
	else if(vsync_count == 11'd9)
		Vsync <= 1'b0;
	else if(vsync_count == 11'd11)
		Vsync <= 1'b1;

endmodule
