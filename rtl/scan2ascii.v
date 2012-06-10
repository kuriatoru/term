module scan2ascii (
	input clk,
	input rst,
	input [7:0] scan,
	input scanrdy,

	output reg [7:0] ascii,
	output reg asciirdy = 0
);

reg extended;
reg released;
reg right_shift;
reg left_shift;
reg [1:0] history = 2'b0;

assign shift = right_shift || left_shift;

always @(posedge clk)
	if(rst)
		history <= 2'b0;
	else
		history <= {history[0], scanrdy};

always @(posedge clk)
	if(rst) begin
		asciirdy <= 0;
		released <= 0;
		extended <= 0;
		right_shift <= 0;
		left_shift <= 0;
		ascii <= 8'b0;
	end else if(history != 2'b10) begin
		asciirdy <= 1'b0;
	end else if(scan == 8'hF0) begin
		asciirdy <= 1'b0;
		ascii <= scan;
		released <= 1'b1;
	end else if(scan == 8'hE0) begin
		asciirdy <= 1'b1;
		ascii <= scan;
		extended <= 1'b1;
	end else if(!extended && scan == 8'h12) begin
		left_shift <= !released;
		released <= 0;
	end else if(!extended && scan == 8'h59) begin
		right_shift <= !released;
		released <= 0;
	end else if(!released) begin
		case({extended, scan})
		9'h66: ascii <= 8'h7f; // backspace
		9'h0d: ascii <= 8'h09; // tab
		9'h29: ascii <= 8'h20; // space
		9'h45: ascii <= shift ? 8'h29 : 8'h30; // 0
		9'h16: ascii <= shift ? 8'h21 : 8'h31; // 1
		9'h1e: ascii <= shift ? 8'h40 : 8'h32; // 2
		9'h26: ascii <= shift ? 8'h23 : 8'h33; // 3
		9'h25: ascii <= shift ? 8'h24 : 8'h34; // 4
		9'h2e: ascii <= shift ? 8'h25 : 8'h35; // 5
		9'h36: ascii <= shift ? 8'h5e : 8'h36; // 6
		9'h3d: ascii <= shift ? 8'h26 : 8'h37; // 7
		9'h3e: ascii <= shift ? 8'h2a : 8'h38; // 8
		9'h46: ascii <= shift ? 8'h28 : 8'h39; // 9
		9'h1c: ascii <= shift ? 8'h41 : 8'h61; // a
		9'h32: ascii <= shift ? 8'h42 : 8'h62; // b
		9'h21: ascii <= shift ? 8'h43 : 8'h63; // c
		9'h23: ascii <= shift ? 8'h44 : 8'h64; // d
		9'h24: ascii <= shift ? 8'h45 : 8'h65; // e
		9'h2b: ascii <= shift ? 8'h46 : 8'h66; // f
		9'h34: ascii <= shift ? 8'h47 : 8'h67; // g
		9'h33: ascii <= shift ? 8'h48 : 8'h68; // h
		9'h43: ascii <= shift ? 8'h49 : 8'h69; // i
		9'h3b: ascii <= shift ? 8'h4a : 8'h6a; // j
		9'h42: ascii <= shift ? 8'h4b : 8'h6b; // k
		9'h4b: ascii <= shift ? 8'h4c : 8'h6c; // l
		9'h3a: ascii <= shift ? 8'h4d : 8'h6d; // m
		9'h31: ascii <= shift ? 8'h4e : 8'h6e; // n
		9'h44: ascii <= shift ? 8'h4f : 8'h6f; // o
		9'h4d: ascii <= shift ? 8'h50 : 8'h70; // p
		9'h15: ascii <= shift ? 8'h51 : 8'h71; // q
		9'h2d: ascii <= shift ? 8'h52 : 8'h72; // r
		9'h1b: ascii <= shift ? 8'h53 : 8'h73; // s
		9'h2c: ascii <= shift ? 8'h54 : 8'h74; // t
		9'h3c: ascii <= shift ? 8'h55 : 8'h75; // u
		9'h2a: ascii <= shift ? 8'h56 : 8'h76; // v
		9'h1d: ascii <= shift ? 8'h57 : 8'h77; // w
		9'h22: ascii <= shift ? 8'h58 : 8'h78; // x
		9'h35: ascii <= shift ? 8'h59 : 8'h79; // y
		9'h1a: ascii <= shift ? 8'h5a : 8'h7a; // z
		9'h1a: ascii <= shift ? 8'h5b : 8'h7a; // z
		9'h4e: ascii <= shift ? 8'h5f : 8'h2d; // -, _
		9'h4a: ascii <= shift ? 8'h3f : 8'h2f; // /, ?
		9'h0e: ascii <= shift ? 8'h7e : 8'h60; // `, ~
		9'h55: ascii <= shift ? 8'h2b : 8'h3d; // =, +
		9'h52: ascii <= shift ? 8'h22 : 8'h27; // ', "
		9'h5d: ascii <= shift ? 8'h7c : 8'h5c; // \, |
		9'h61: ascii <= shift ? 8'h7c : 8'h5c; // \, | SIC!
		9'h41: ascii <= shift ? 8'h3c : 8'h2c; // ,, <
		9'h49: ascii <= shift ? 8'h3e : 8'h2e; // ., >
		9'h4c: ascii <= shift ? 8'h3a : 8'h3b; // ;, :
		9'h54: ascii <= shift ? 8'h7b : 8'h5b; // [, {
		9'h5b: ascii <= shift ? 8'h7d : 8'h5d; // \, |
		9'h70: ascii <= 8'h30; // num pad 0
		9'h69: ascii <= 8'h31; // num pad 1
		9'h72: ascii <= 8'h32; // num pad 2
		9'h7a: ascii <= 8'h33; // num pad 3
		9'h6b: ascii <= 8'h34; // num pad 4
		9'h73: ascii <= 8'h35; // num pad 5
		9'h74: ascii <= 8'h36; // num pad 6
		9'h6c: ascii <= 8'h37; // num pad 7
		9'h75: ascii <= 8'h38; // num pad 8
		9'h7d: ascii <= 8'h39; // num pad 9
		9'h7c: ascii <= 8'h2a; // num pad *
		9'h7b: ascii <= 8'h2d; // num pad -
		9'h79: ascii <= 8'h2b; // num pad +
		9'h5a: ascii <= 8'h0a; // return
		default: ascii <= 8'h2e;
		endcase
		asciirdy <= 1;
		extended <= 0;
	end else begin
		asciirdy <= 0;
		released <= 0;
		extended <= 0;
	end
endmodule
