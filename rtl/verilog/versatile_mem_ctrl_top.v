`include "versatile_mem_ctrl_defines.v"
`ifdef SDR_16
 `include "sdr_16_defines.v"
`endif

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
`endif //  `ifdef PORT7
`ifdef SDR_16
   output reg [1:0] ba_pad_o,
   output reg [12:0] a_pad_o,
   output reg cs_n_pad_o,
   output reg ras_pad_o,
   output reg cas_pad_o,
   output reg we_pad_o,
   output reg [15:0] dq_pad_o,
   output reg [1:0] dqm_pad_o,
   input      [15:0] dq_pad_i,
   output reg dq_pad_oe,
   output     cke,
`endif
   input wb_clk,
   input wb_rst,
   // SDRAM signals
   input sdram_clk
   );

   wire [35:0] tx_fifo_dat_i, tx_fifo_dat_o, tx_fifo_dat_wb;
   wire tx_fifo_we, tx_fifo_re, tx_fifo_wb;
   wire [2:0] tx_fifo_a_sel_i, tx_fifo_b_sel_i;
   reg [2:0]  tx_fifo_b_sel_i_cur;
   wire [7:0] tx_fifo_full, tx_fifo_empty;
   
   wire [3:0] burst_adr;
   wire       adr_init, adr_inc;
   
   wire       done;
   wire [14:0] a;
   wire        cs_n;

   wire        ref_req, ref_ack;
   
   
// counters to keep track of fifo fill

`ifdef PORT0
   wire wbs0_flag;
ctrl_counter cnt0
  (
   .clear((&wbs0_cti_i | !(|wbs0_cti_i)) & (!wbs0_flag | !wbs0_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd0)&tx_fifo_we) | wbs0_ack_o),
   .zq(wbs0_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT1
   wire wbs1_flag;
ctrl_counter cnt1
  (
   .clear((&wbs1_cti_i | !(|wbs1_cti_i)) & (!wbs1_flag | !wbs1_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd1)&tx_fifo_we) | wbs1_ack_o),
   .zq(wbs1_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT2
   wire wbs2_flag;
ctrl_counter cnt2
  (
   .clear((&wbs2_cti_i | !(|wbs2_cti_i)) & (!wbs2_flag | !wbs2_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd2)&tx_fifo_we) | wbs2_ack_o),
   .zq(wbs2_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT3
   wire wbs3_flag;
ctrl_counter cnt3
  (
   .clear((&wbs3_cti_i | !(|wbs3_cti_i)) & (!wbs3_flag | !wbs3_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd3)&tx_fifo_we) | wbs3_ack_o),
   .zq(wbs0_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT4
   wire wbs4_flag;
ctrl_counter cnt4
  (
   .clear((&wbs4_cti_i | !(|wbs4_cti_i)) & (!wbs4_flag | !wbs4_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd4)&tx_fifo_we) | wbs4_ack_o),
   .zq(wbs4_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT5
   wire wbs5_flag;
ctrl_counter cnt5
  (
   .clear((&wbs5_cti_i | !(|wbs5_cti_i)) & (!wbs5_flag | !wbs5_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd5)&tx_fifo_we) | wbs5_ack_o),
   .zq(wbs5_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT6
   wire wbs6_flag;
ctrl_counter cnt6
  (
   .clear((&wbs6_cti_i | !(|wbs6_cti_i)) & (!wbs6_flag | !wbs6_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd6)&tx_fifo_we) | wbs6_ack_o),
   .zq(wbs6_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
`endif

`ifdef PORT7
   wire wbs7_flag;
ctrl_counter cnt7
  (
   .clear((&wbs7_cti_i | !(|wbs7_cti_i)) & (!wbs7_flag | !wbs7_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd7)&tx_fifo_we) | wbs7_ack_o),
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
      .b_dat_o(tx_fifo_dat_o),
      .b_re_i(tx_fifo_re),
      .b_fifo_sel_i(tx_fifo_b_sel_i),
      .b_fifo_empty_o(tx_fifo_empty),
      .b_clk(sdram_clk),
      // misc
      .rst(wb_rst) 	 
      );
   
   assign tx_fifo_b_sel_i
     = 
       (adr_init & !tx_fifo_empty[4]) ? 3'd4 :
       (adr_init & !tx_fifo_empty[5]) ? 3'd5 :
       (adr_init & !tx_fifo_empty[6]) ? 3'd6 :
       (adr_init & !tx_fifo_empty[7]) ? 3'd7 :
       (adr_init & !tx_fifo_empty[0]) ? 3'd0 :
       (adr_init & !tx_fifo_empty[1]) ? 3'd1 :
       (adr_init & !tx_fifo_empty[2]) ? 3'd2 :
       (adr_init & !tx_fifo_empty[3]) ? 3'd3 :
       tx_fifo_b_sel_i_cur;

   always @ (posedge sdram_clk or posedge wb_rst)
     if (wb_rst)
       tx_fifo_b_sel_i_cur <= 3'd0;
     else if (adr_init)
       tx_fifo_b_sel_i_cur <= tx_fifo_b_sel_i;
   
   
   inc_adr inc_adr0
     (
      .adr_i(tx_fifo_dat_o[9:6]),
      .bte_i(tx_fifo_dat_o[4:3]),
      .cti_i(tx_fifo_dat_o[2:0]),
      .fifo_empty(tx_fifo_empty), 
      .init(adr_init),
      .inc(adr_inc),
      .adr_o(burst_adr),
      .done(done),
      .clk(sdram_clk),
      .rst(wb_rst)
      );

`ifdef SDR_16
   reg dq_oe, dq_flag;
   wire [2:0] cmd;

   ref_counter ref_counter0
     (
      .zq(ref_req),
      .clk(sdram_clk),
      .rst(wb_rst)
      );
      
   // SDR SDRAM 16 FSM
   sdr_16 sdr_16_0
     (
      .adr_inc(adr_inc),
      .adr_init(adr_init),
      .fifo_re(tx_fifo_re),
      .ba(`BA),
      .row(`ROW),
      .col(`COL),
      .we(tx_fifo_dat_o[5]),
      .done(done),
      .fifo_empty(tx_fifo_empty),
      .fifo_sel(tx_fifo_b_sel_i_cur),
      // refresh
      .ref_req(ref_req),
      .ref_ack(ref_ack),
      // sdram
      .a(a),
      .cmd(cmd),
      .cs_n(cs_n),
      .sdram_clk(sdram_clk),
      .wb_rst(wb_rst)
      );

   always @ (posedge sdram_clk or posedge wb_rst)
     if (wb_rst)
       {dq_pad_o,dqm_pad_o,dq_oe,dq_flag} <= {16'h0000,2'b00,1'b0,1'b0};
     else
       if (cmd == `CMD_WRITE)
	 {dq_pad_o,dqm_pad_o,dq_oe,dq_flag} <= {tx_fifo_dat_o[35:20],!tx_fifo_dat_o[3:2],1'b1,1'b1};
       else if (dq_flag)
	 {dq_pad_o,dqm_pad_o,dq_oe,dq_flag} <= {tx_fifo_dat_o[19: 4],!tx_fifo_dat_o[1:0],1'b1,1'b0};
       else
	 {dq_oe,dq_flag} <= {1'b0,1'b0};

   always @ (posedge sdram_clk or posedge wb_rst)
     if (wb_rst)
       {ba_pad_o, a_pad_o, cs_n_pad_o, ras_pad_o, cas_pad_o, we_pad_o} <= {2'b00,13'h0,1'b1,`CMD_NOP};
     else
       {ba_pad_o, a_pad_o, cs_n_pad_o, ras_pad_o, cas_pad_o, we_pad_o} <= {a,cs_n,cmd};
       	 
   assign cke = 1'b1;
   
`endif //  `ifdef SDR_16
   
   // ack
`ifdef PORT0
   assign wbs0_ack_o = !wbs0_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd0);
`endif
`ifdef PORT1
   assign wbs1_ack_o = !wbs1_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd1);
`endif
`ifdef PORT2
   assign wbs2_ack_o = !wbs2_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd2);
`endif
`ifdef PORT3
   assign wbs3_ack_o = !wbs3_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd3);
`endif
`ifdef PORT4
   assign wbs4_ack_o = !wbs4_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd4);
`endif
`ifdef PORT5
   assign wbs5_ack_o = !wbs5_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd5);
`endif
`ifdef PORT6
   assign wbs6_ack_o = !wbs6_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd6);
`endif
`ifdef PORT7
   assign wbs7_ack_o = !wbs7_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd7);   
`endif
   
endmodule // wb_sdram_ctrl_top
