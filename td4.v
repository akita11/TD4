// TinyTapeout in&out
// 8 IN, 8 OUT, 8 INOUT
// OUT     4 A[3:0]
// OUT     4 OUT[3:0]
// IN      8 D[7:0]
// INOUT/I 4 IN[3:0]
// INOUT/O 8 RA[3:0] RB[3:0]
//           CF??
module td4(clk, rst, addr, data, cf);
   input clk, rst;
   input [7:0] data;
   output [3:0] addr;
   output 	cf;
   input [3:0] 	port_i;
   output [3:0] port_o;

   wire [3:0] 	op, im;
   wire [3:0] 	ld_n;
   wire [1:0] 	sel;	
   wire [3:0] 	adder_s;
   wire 	co;
   reg 		cf_n;
   reg [3:0] 	adder_a;
   reg [3:0] 	reg_a, reg_b, port_o;
   reg [3:0] 	addr;
   
   assign cf = cf_n;
   assign op = data[7:4], im = data[3:0];

   // selector
   assign sl[0] = op[0] | op[3];
   assign sl[1] = op[1];

   // instruction decoder
   assign ld_n[0] = op[2] | op[3];
   assign ld_n[1] = ~op[2] | op[3];
   assign ld_n[2] = ~(~op[2] & op[3]);
   assign ld_n[3] = ~(~op[3] & op[2] & (cf_n | op[0]));

   // 74283
   {co, adder_s} = adder_a + im;

   // 74153 x2
   always @(sel, reg_a, reg_b) begin
      case (sel)
	2'b00 : addr_a <= reg_a;
	2'b01 : addr_a <= reg_b;
	2'b10 : addr_a <= port_i;
	2'b11 : addr_a <= 4'b0000;
      endcase
   end

   always @(posedge clk, rst) begin
     if (rst == 1'b1) begin
	reg_a <= 4'b0000; reg_b <= 4'b0000; port_o <= 4'b0000; addr <= 4'b0000;
     end
     else begin
	if (ld_n[0] == 1'b0) reg_a <= adder_s; // 74161
	if (ld_n[1] == 1'b0) reg_b <= adder_s; // 74161
	if (ld_n[2] == 1'b0) port_o <= adder_s; // 74161
	if (ld_n[3] == 1'b0) addr <= adder_s; // 74161
	else addr <= addr + 4'b0001;
	cf_n <= co; // 7474
     end
   end
endmodule
