module wbwb_bridge (
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_clk, wbs_rst,
	// wishbone master side
	wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_bte_o, wbm_cti_o, wbm_we_o, wbm_cyc_o, wbm_stb_o, wbm_dat_i, wbm_ack_i, wbm_clk, wbm_rst);

input [31:0] wbs_dat_i;
input [31:2] wbs_adr_i;
input [3:0]  wbs_sel_i;
input [1:0]  wbs_bte_i;
input [2:0]  wbs_cti_i;
input wbs_we_i, wbs_cyc_i, wbs_stb_i;
output [31:0] wbs_dat_o;
output reg wbs_ack_o;
input wbs_clk, wbs_rst;

output [31:0] wbm_dat_o;
output reg [31:2] wbm_adr_o;
output [3:0]  wbm_sel_o;
output reg [1:0]  wbm_bte_o;
output reg [2:0]  wbm_cti_o;
output reg wbm_we_o, wbm_cyc_o;
output wbm_stb_o;
input [31:0]  wbm_dat_i;
input wbm_ack_i;
input wbm_clk, wbm_rst;

parameter addr_width = 4;

// bte
parameter linear       = 2'b00;
parameter wrap4        = 2'b01;
parameter wrap8        = 2'b10;
parameter wrap16       = 2'b11;
// cti
parameter classic      = 3'b000;
parameter incburst     = 3'b010;
parameter endofburst   = 3'b111;

parameter adr  = 1'b0;
parameter data = 1'b1;

reg wbs_we_reg, wbs_bte_reg, wbs, wbm;
reg wbs_ack_o_rd;
wire wbs_ack_o_wr;

wire [35:0] a_d, a_q, b_d, b_q;
wire a_wr, a_rd, a_fifo_full, a_fifo_empty, b_wr, b_rd, b_fifo_full, b_fifo_empty;

reg [1:16] count;
reg count_zero;

`define WBS_EOC (wbs_bte_i==linear | wbs_cti_i==endofburst) & wbs_cyc_i & wbs_stb_i
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	wbs <= adr;
else
	if (wbs_cyc_i & wbs_stb_i & (wbs==adr) & !a_fifo_full)
		wbs <= data;
	else if ((`WBS_EOC & !a_fifo_full) & (a_rd | (wbs_stb_i & wbs_we_i)))
		wbs <= adr;

// wbs FIFO
assign a_d = (wbs==adr) ? {wbs_adr_i[31:2],wbs_we_i,wbs_bte_i,wbs_cti_i} : {wbs_dat_i,wbs_sel_i};
assign a_wr = ((wbs== adr) & wbs_cyc_i & wbs_stb_i & !a_fifo_full) ? 1'b1 :
              ((wbs==data) & wbs_cyc_i & wbs_stb_i & !a_fifo_full & wbs_we_i) ? 1'b1 :
              1'b0;
assign wbs_dat_o = a_q[35:4];
assign a_rd = !a_fifo_empty;
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	wbs_ack_o_rd <= 1'b0;
else
	wbs_ack_o_rd <= a_rd;
	
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	{wbs_we_reg,wbs_bte_reg} <= 2'b00;
else
	{wbs_we_reg,wbs_bte_reg} <= {wbs_we_i,|wbs_bte_i};

assign wbs_ack_o_wr = wbs==data & wbs_we_reg & wbs_stb_i;

assign wbs_ack_o = wbs_ack_o_rd | wbs_ack_o_wr;	
			
// wbm FIFO
always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	wbm <= adr;
else
	if (!b_fifo_empty)
		wbm <= data;
	else if (wbm_ack_i & ((b_q[4:3]==wrap4 & count[3]) | (b_q[4:3]==wrap8 & count[7]) | (b_q[4:3]==wrap16 & count[15])))
		wbm <= adr;
assign b_d = {wbm_dat_i,4'b1111};
assign b_wr = !wbm_we_o & wbm_ack_i;
assign b_rd = (wbm==adr & !b_fifo_empty) ? 1'b1 :
              (wbm==data & wbm_ack_i) ? 1'b1 :
              1'b0;
always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	{count,count_zero} <= {16'h8000,1'b1};
else
	casex ({b_fifo_empty,wbm_bte_o,count,count_zero,wbm_ack_i})
	{1'b0,linear,16'b1xxxxxxxxxxxxxxx,1'bx,1'b1}: {count, count_zero} <= {16'h8000,1'b1};
	{1'b0,wrap4 ,16'bxxx1xxxxxxxxxxxx,1'bx,1'b1}: {count, count_zero} <= {16'h8000,1'b1};
	{1'b0,wrap8 ,16'bxxxxxxx1xxxxxxxx,1'bx,1'b1}: {count, count_zero} <= {16'h8000,1'b1};
	{1'b0,wrap16,16'bxxxxxxxxxxxxxxx1,1'bx,1'b1}: {count, count_zero} <= {16'h8000,1'b1};
	{1'b0,2'bxx,{16{1'bx}},1'b0,1'b1} 			: {count, count_zero} <= {count >> 1,1'b0};
	default : ;
	endcase
assign wbm_cyc_o = wbm;
assign wbm_stb_o = (wbm==adr) ? 1'b0 :
                   (wbm==data & wbm_we_o) ? !b_fifo_empty :
                   1'b1;
always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	{wbm_adr_o,wbm_we_o,wbm_bte_o,wbm_cti_o} <= {32'h0,1'b0,linear,classic};
else begin
	if (wbm==adr & !b_fifo_empty)
		{wbm_adr_o,wbm_we_o,wbm_bte_o,wbm_cti_o} <= b_q;
	else if ((b_q[4:3]==wrap4 & count[3]) | (b_q[4:3]==wrap8 & count[7]) | (b_q[4:3]==wrap16 & count[15]))
		wbm_cti_o <= endofburst;
end	
assign {wbm_dat_o,wbm_sel_o} = b_q;

async_fifo_dw_simplex_top
# ( .data_width(36), .addr_width(addr_width))
fifo (
	// a side
    .a_d(a_d), 
    .a_wr(a_wr), 
    .a_fifo_full(a_fifo_full),
    .a_q(a_q),
    .a_rd(a_rd),
    .a_fifo_empty(a_fifo_empty), 
	.a_clk(wbs_clk), 
	.a_rst(wbs_rst),
	// b side
    .b_d(b_d), 
    .b_wr(b_wr), 
    .b_fifo_full(b_fifo_full),
    .b_q(b_q), 
    .b_rd(b_rd), 
    .b_fifo_empty(b_fifo_empty), 
	.b_clk(wbm_clk), 
	.b_rst(wbm_rst)	
    );
    
endmodule
