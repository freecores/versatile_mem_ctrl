`include "wb_sdram_ctrl_defines.v"

module wb_sdram_ctrl_top
  (
   // wishbone i/f
`ifdef PORT0
   input  [31:0] wbs0_dat_i,
   output [31:0] wbs0_dat_o,
   input  [31:2] wbs0_adr_i,
   input  [3:0]  wbs0_sel_i,
   input  [2:0]  wbs0_cti_i,
   input  [1:0]  wbs0_bte_i,
   input         wbs0_we_i,
   input         wbs0_cyc_i,
   input         wbs0_stb_i,
   output        wbs0_ack_o,
`endif
`ifdef PORT1
   input  [31:0] wbs1_dat_i,
   output [31:0] wbs1_dat_o,
   input  [31:2] wbs1_adr_i,
   input  [3:0]  wbs1_sel_i,
   input  [2:0]  wbs1_cti_i,
   input  [1:0]  wbs1_bte_i,
   input         wbs1_we_i,
   input         wbs1_cyc_i,
   input         wbs1_stb_i,
   output        wbs1_ack_o,
`endif
`ifdef PORT2
   input  [31:0] wbs2_dat_i,
   output [31:0] wbs2_dat_o,
   input  [31:2] wbs2_adr_i,
   input  [3:0]  wbs2_sel_i,
   input  [2:0]  wbs2_cti_i,
   input  [1:0]  wbs2_bte_i,
   input         wbs2_we_i,
   input         wbs2_cyc_i,
   input         wbs2_stb_i,
   output        wbs2_ack_o,
`endif
`ifdef PORT3
   input  [31:0] wbs3_dat_i,
   output [31:0] wbs3_dat_o,
   input  [31:2] wbs3_adr_i,
   input  [3:0]  wbs3_sel_i,
   input  [2:0]  wbs3_cti_i,
   input  [1:0]  wbs3_bte_i,
   input         wbs3_we_i,
   input         wbs3_cyc_i,
   input         wbs3_stb_i,
   output        wbs3_ack_o,
`endif
`ifdef PORT4
   input  [31:0] wbs4_dat_i,
   output [31:0] wbs4_dat_o,
   input  [31:2] wbs4_adr_i,
   input  [3:0]  wbs4_sel_i,
   input  [2:0]  wbs4_cti_i,
   input  [1:0]  wbs4_bte_i,
   input         wbs4_we_i,
   input         wbs4_cyc_i,
   input         wbs4_stb_i,
   output        wbs4_ack_o,
`endif
`ifdef PORT5
   input  [31:0] wbs5_dat_i,
   output [31:0] wbs5_dat_o,
   input  [31:2] wbs5_adr_i,
   input  [3:0]  wbs5_sel_i,
   input  [2:0]  wbs5_cti_i,
   input  [1:0]  wbs5_bte_i,
   input         wbs5_we_i,
   input         wbs5_cyc_i,
   input         wbs5_stb_i,
   output        wbs5_ack_o,
`endif
`ifdef PORT6
   input  [31:0] wbs6_dat_i,
   output [31:0] wbs6_dat_o,
   input  [31:2] wbs6_adr_i,
   input  [3:0]  wbs6_sel_i,
   input  [2:0]  wbs6_cti_i,
   input  [1:0]  wbs6_bte_i,
   input         wbs6_we_i,
   input         wbs6_cyc_i,
   input         wbs6_stb_i,
   output        wbs6_ack_o,
`endif
`ifdef PORT7
   input  [31:0] wbs7_dat_i,
   output [31:0] wbs7_dat_o,
   input  [31:2] wbs7_adr_i,
   input  [3:0]  wbs7_sel_i,
   input  [2:0]  wbs7_cti_i,
   input  [1:0]  wbs7_bte_i,
   input         wbs7_we_i,
   input         wbs7_cyc_i,
   input         wbs7_stb_i,
   output        wbs7_ack_o,
`endif
   input wb_clk,
   input wb_rst,
   // SDRAM signals
   input sdram_clk
   );

   wire tx_fifo_a_dat_i;
   wire tx_fifo_we;
wire [2:0] tx_fifo_a_sel_i;
wire [7:0] tx_fifo_full;

// counters to keep track of fifo fill

`ifdef PORT0
   wire wbs0_flag;
cyc_mask_counter cnt0
  (
   .clear((&wbs0_cti_i | !|wbs0_cti_i) & (!wbs0_flag | !wbs0_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd0)&tx_fifo_a_we) | wbs0_ack_o),
   .zq(wbs0_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT1
   wire wbs1_flag;
cyc_mask_counter cnt1
  (
   .clear((&wbs1_cti_i | !|wbs1_cti_i) & (!wbs1_flag | !wbs1_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd1)&tx_fifo_a_we) | wbs1_ack_o),
   .zq(wbs1_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT2
   wire wbs2_flag;
cyc_mask_counter cnt2
  (
   .clear((&wbs2_cti_i | !|wbs2_cti_i) & (!wbs2_flag | !wbs2_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd2)&tx_fifo_a_we) | wbs2_ack_o),
   .zq(wbs2_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT3
   wire wbs3_flag;
cyc_mask_counter cnt3
  (
   .clear((&wbs3_cti_i | !|wbs3_cti_i) & (!wbs3_flag | !wbs3_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd3)&tx_fifo_a_we) | wbs3_ack_o),
   .zq(wbs0_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT4
   wire wbs4_flag;
cyc_mask_counter cnt4
  (
   .clear((&wbs4_cti_i | !|wbs4_cti_i) & (!wbs4_flag | !wbs4_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd4)&tx_fifo_a_we) | wbs4_ack_o),
   .zq(wbs4_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT5
   wire wbs5_flag;
cyc_mask_counter cnt5
  (
   .clear((&wbs5_cti_i | !|wbs5_cti_i) & (!wbs5_flag | !wbs5_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd5)&tx_fifo_a_we) | wbs5_ack_o),
   .zq(wbs5_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT6
   wire wbs6_flag;
cyc_mask_counter cnt6
  (
   .clear((&wbs6_cti_i | !|wbs6_cti_i) & (!wbs6_flag | !wbs6_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd6)&tx_fifo_a_we) | wbs6_ack_o),
   .zq(wbs6_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT7
   wire wbs7_flag;
cyc_mask_counter cnt7
  (
   .clear((&wbs7_cti_i | !|wbs7_cti_i) & (!wbs7_flag | !wbs7_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd7)&tx_fifo_a_we) | wbs7_ack_o),
   .zq(wbs7_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

// priority order - ongoing,4,5,6,7,0,1,2,3
assign {tx_fifo_a_sel_i,tx_fifo_we} 
  =
`ifdef PORT4 
    (!wbs4_flag & wbs4_stb_i & !tx_fifo_full[4]) ? {3'd4,1'b1} :
`endif
`ifdef PORT5
    (!wbs5_flag & wbs5_stb_i & !tx_fifo_full[5]) ? {3'd5,1'b1} :
`endif
`ifdef PORT6
    (!wbs6_flag & wbs6_stb_i & !tx_fifo_full[6]) ? {3'd6,1'b1} :
`endif
`ifdef PORT7
    (!wbs7_flag & wbs7_stb_i & !tx_fifo_full[7]) ? {3'd7,1'b1} :
`endif
`ifdef PORT0
    (!wbs0_flag & wbs0_stb_i & !tx_fifo_full[0]) ? {3'd0,1'b1} :
`endif
`ifdef PORT1
    (!wbs1_flag & wbs1_stb_i & !tx_fifo_full[1]) ? {3'd1,1'b1} :
`endif
`ifdef PORT2
    (!wbs2_flag & wbs2_stb_i & !tx_fifo_full[2]) ? {3'd2,1'b1} :
`endif
`ifdef PORT3
    (!wbs3_flag & wbs3_stb_i & !tx_fifo_full[3]) ? {3'd3,1'b1} :
`endif
`ifdef PORT4 
    (wbs4_stb_i & !tx_fifo_full[4]) ? {3'd4,1'b1} :
`endif
`ifdef PORT5
    (wbs5_stb_i & !tx_fifo_full[5]) ? {3'd5,1'b1} :
`endif
`ifdef PORT6
    (wbs6_stb_i & !tx_fifo_full[6]) ? {3'd6,1'b1} :
`endif
`ifdef PORT7
    (wbs7_stb_i & !tx_fifo_full[7]) ? {3'd7,1'b1} :
`endif
`ifdef PORT0
    (wbs0_stb_i & !tx_fifo_full[0]) ? {3'd0,1'b1} :
`endif
`ifdef PORT1
    (wbs1_stb_i & !tx_fifo_full[1]) ? {3'd1,1'b1} :
`endif
`ifdef PORT2
    (wbs2_stb_i & !tx_fifo_full[2]) ? {3'd2,1'b1} :
`endif
`ifdef PORT3
    (wbs3_stb_i & !tx_fifo_full[3]) ? {3'd3,1'b1} :
`endif
    {3'd0,1'b0};

// tx_fifo dat_i mux
assign tx_fifo_dat_i
  =
`ifdef PORT0
   (tx_fifo_a_sel_i==3'd0) &  wbs0_flag ? {wbs0_adr_i,wbs0_we_i,wbs0_bte_i,wbs0_cti_i} :
   (tx_fifo_a_sel_i==3'd0) & !wbs0_flag ? {wbs0_dat_i,wbs0_sel_i} :
`endif
`ifdef PORT1
   (tx_fifo_a_sel_i==3'd1) &  wbs1_flag ? {wbs1_adr_i,wbs1_we_i,wbs1_bte_i,wbs1_cti_i} :
   (tx_fifo_a_sel_i==3'd1) & !wbs1_flag ? {wbs1_dat_i,wbs1_sel_i} :
`endif
`ifdef PORT2
   (tx_fifo_a_sel_i==3'd2) &  wbs2_flag ? {wbs2_adr_i,wbs2_we_i,wbs2_bte_i,wbs2_cti_i} :
   (tx_fifo_a_sel_i==3'd2) & !wbs2_flag ? {wbs2_dat_i,wbs2_sel_i} :
`endif
`ifdef PORT3
   (tx_fifo_a_sel_i==3'd3) &  wbs3_flag ? {wbs3_adr_i,wbs3_we_i,wbs3_bte_i,wbs3_cti_i} :
   (tx_fifo_a_sel_i==3'd3) & !wbs3_flag ? {wbs3_dat_i,wbs3_sel_i} :
`endif
`ifdef PORT4
   (tx_fifo_a_sel_i==3'd4) &  wbs4_flag ? {wbs4_adr_i,wbs4_we_i,wbs4_bte_i,wbs4_cti_i} :
   (tx_fifo_a_sel_i==3'd4) & !wbs4_flag ? {wbs4_dat_i,wbs4_sel_i} :
`endif
`ifdef PORT5
   (tx_fifo_a_sel_i==3'd5) &  wbs5_flag ? {wbs5_adr_i,wbs5_we_i,wbs5_bte_i,wbs5_cti_i} :
   (tx_fifo_a_sel_i==3'd5) & !wbs5_flag ? {wbs5_dat_i,wbs5_sel_i} :
`endif
`ifdef PORT6
   (tx_fifo_a_sel_i==3'd6) &  wbs6_flag ? {wbs6_adr_i,wbs6_we_i,wbs6_bte_i,wbs6_cti_i} :
   (tx_fifo_a_sel_i==3'd6) & !wbs6_flag ? {wbs6_dat_i,wbs6_sel_i} :
`endif
`ifdef PORT7
   (tx_fifo_a_sel_i==3'd7) &  wbs7_flag ? {wbs7_adr_i,wbs7_we_i,wbs7_bte_i,wbs7_cti_i} :
   (tx_fifo_a_sel_i==3'd7) & !wbs7_flag ? {wbs7_dat_i,wbs7_sel_i} :
`endif
   {wbs0_adr_i,wbs0_we_i,wbs0_bte_i,wbs0_cti_i};

fifo tx_fifo
  (
   // A side
   .a_dat_i(tx_fifo_dat_i),
   .a_we_i(tx_fifo_we),
   .a_fifo_sel_i(tx_fifo_a_sel_i),
   .a_fifo_full_o(tx_fifo_full),
   .a_clk(wb_clk),
   // B side
   .b_dat_o(),
   .b_dat_i(),
   .b_we_i(),
   .b_re_i(),
   .b_fifo_sel_i(),
   .b_fifo_empty_o(),
   .b_clk(sdram_clk),
   // misc
   .rst(wb_rst) 	 
   );


endmodule // wb_sdram_ctrl_top
