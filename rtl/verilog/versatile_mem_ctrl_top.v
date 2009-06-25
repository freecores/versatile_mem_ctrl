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
   output [1:0] ba_pad_o,
   output [12:0] a_pad_o,
   output cs_n_pad_o,
   output ras_pad_o,
   output cas_pad_o,
   output we_pad_o,
   output [15:0] dq_o,
   output [1:0] dqm_pad_o,
   input  [15:0] dq_i,
   output dq_oe,
   output cke_pad_o,
`endif
   input wb_clk,
   input wb_rst,
   // SDRAM signals
   input sdram_clk
   );

   wire [35:0] tx_fifo_dat_i, tx_fifo_dat_o;
   wire tx_fifo_we, tx_fifo_re;
   wire [2:0] tx_fifo_a_sel_i, tx_fifo_b_sel_i;
   reg [2:0]  tx_fifo_b_sel_i_cur;
   wire [7:0] tx_fifo_full, tx_fifo_empty;

   wire [35:0] rx_fifo_dat_i, rx_fifo_dat_o;
   wire        rx_fifo_we, rx_fifo_re;
   wire [2:0]  rx_fifo_a_sel_i, rx_fifo_b_sel_i;
   wire [7:0]  rx_fifo_full, rx_fifo_empty;   
   
   wire [3:0] burst_adr;
   wire       adr_init, adr_inc;
   
   wire        ref_zf, ref_ack;
   reg 	       ref_req;
   
`ifdef PORT0
   reg 	       wbs0_ack_re;
`endif
`ifdef PORT1
   reg 	       wbs1_ack_re;
`endif
`ifdef PORT2
   reg 	       wbs2_ack_re;
`endif
`ifdef PORT3
   reg 	       wbs3_ack_re;
`endif
`ifdef PORT4
   reg 	       wbs4_ack_re;
`endif
`ifdef PORT5
   reg 	       wbs5_ack_re;
`endif
`ifdef PORT6
   reg 	       wbs6_ack_re;
`endif
`ifdef PORT7
   reg 	       wbs7_ack_re;
`endif
   
// counters to keep track of fifo fill

`ifdef PORT0
   wire wbs0_flag, we_req0;
   fifo_fill cnt0
     (
      .wbs_flag(wbs0_flag),
      .we_req(we_req0),
      .bte(wbs0_bte_i),
      .cti(wbs0_cti_i),
      .cyc(wbs0_cyc_i),
      .stb(wbs0_stb_i),
      .we(wbs0_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd0) & tx_fifo_we),
      .ack(wbs0_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
   
   /*
ctrl_counter cnt0
  (
   .clear((&wbs0_cti_i | !(|wbs0_cti_i)) & (!wbs0_flag | !wbs0_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd0)&tx_fifo_we) | wbs0_ack_o),
   .zq(wbs0_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT1
   wire wbs1_flag, we_req1;
   fifo_fill cnt1
     (
      .wbs_flag(wbs1_flag),
      .we_req(we_req1),
      .bte(wbs1_bte_i),
      .cti(wbs1_cti_i),
      .cyc(wbs1_cyc_i),
      .stb(wbs1_stb_i),
      .we(wbs1_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd1) & tx_fifo_we),
      .ack(wbs1_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
 /*
   wire wbs1_flag;
ctrl_counter cnt1
  (
   .clear((&wbs1_cti_i | !(|wbs1_cti_i)) & (!wbs1_flag | !wbs1_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd1)&tx_fifo_we) | wbs1_ack_o),
   .zq(wbs1_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
 */
`endif

`ifdef PORT2
   wire wbs2_flag, we_req2;
   fifo_fill cnt2
     (
      .wbs_flag(wbs2_flag),
      .we_req(we_req2),
      .bte(wbs2_bte_i),
      .cti(wbs2_cti_i),
      .cyc(wbs2_cyc_i),
      .stb(wbs2_stb_i),
      .we(wbs2_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd2) & tx_fifo_we),
      .ack(wbs2_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    
   /*
   wire wbs2_flag;
ctrl_counter cnt2
  (
   .clear((&wbs2_cti_i | !(|wbs2_cti_i)) & (!wbs2_flag | !wbs2_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd2)&tx_fifo_we) | wbs2_ack_o),
   .zq(wbs2_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT3
   wire wbs3_flag, we_req3;
   fifo_fill cnt3
     (
      .wbs_flag(wbs3_flag),
      .we_req(we_req3),
      .bte(wbs3_bte_i),
      .cti(wbs3_cti_i),
      .cyc(wbs3_cyc_i),
      .stb(wbs3_stb_i),
      .we(wbs3_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd3) & tx_fifo_we),
      .ack(wbs3_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    /*
   wire wbs3_flag;
ctrl_counter cnt3
  (
   .clear((&wbs3_cti_i | !(|wbs3_cti_i)) & (!wbs3_flag | !wbs3_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd3)&tx_fifo_we) | wbs3_ack_o),
   .zq(wbs0_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT4
   
   wire wbs4_flag, we_req4;
   fifo_fill cnt4
     (
      .wbs_flag(wbs4_flag),
      .we_req(we_req4),
      .bte(wbs4_bte_i),
      .cti(wbs4_cti_i),
      .cyc(wbs4_cyc_i),
      .stb(wbs4_stb_i),
      .we(wbs4_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd4) & tx_fifo_we),
      .ack(wbs4_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
/*
   wire wbs4_flag;
ctrl_counter cnt4
  (
   .clear((&wbs4_cti_i | !(|wbs4_cti_i)) & (!wbs4_flag | !wbs4_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd4)&tx_fifo_we) | wbs4_ack_o),
   .zq(wbs4_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
 */
`endif

`ifdef PORT5
   wire wbs5_flag, we_req5;
   fifo_fill cnt0
     (
      .wbs_flag(wbs5_flag),
      .we_req(we_req5),
      .bte(wbs5_bte_i),
      .cti(wbs5_cti_i),
      .cyc(wbs5_cyc_i),
      .stb(wbs5_stb_i),
      .we(wbs5_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd5) & tx_fifo_we),
      .ack(wbs5_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    /*
   wire wbs5_flag;
ctrl_counter cnt5
  (
   .clear((&wbs5_cti_i | !(|wbs5_cti_i)) & (!wbs5_flag | !wbs5_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd5)&tx_fifo_we) | wbs5_ack_o),
   .zq(wbs5_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT6
   wire wbs6_flag, we_req6;
   fifo_fill cnt6
     (
      .wbs_flag(wbs6_flag),
      .we_req(we_req6),
      .bte(wbs6_bte_i),
      .cti(wbs6_cti_i),
      .cyc(wbs6_cyc_i),
      .stb(wbs6_stb_i),
      .we(wbs6_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd6) & tx_fifo_we),
      .ack(wbs6_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    
   /*
   wire wbs6_flag;
ctrl_counter cnt6
  (
   .clear((&wbs6_cti_i | !(|wbs6_cti_i)) & (!wbs6_flag | !wbs6_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd6)&tx_fifo_we) | wbs6_ack_o),
   .zq(wbs6_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT7
   wire wbs7_flag, we_req7;
   fifo_fill cnt7
     (
      .wbs_flag(wbs7_flag),
      .we_req(we_req7),
      .bte(wbs7_bte_i),
      .cti(wbs7_cti_i),
      .cyc(wbs7_cyc_i),
      .stb(wbs7_stb_i),
      .we(wbs7_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd7) & tx_fifo_we),
      .ack(wbs7_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    
   /*
   wire wbs7_flag;
ctrl_counter cnt7
  (
   .clear((&wbs7_cti_i | !(|wbs7_cti_i)) & (!wbs7_flag | !wbs7_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd7)&tx_fifo_we) | wbs7_ack_o),
   .zq(wbs7_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

// priority order - ongoing,4,5,6,7,0,1,2,3
assign {tx_fifo_a_sel_i,tx_fifo_we} 
  =
	      /*
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
    (!wbs0_flag & we_req0 & !tx_fifo_full[0]) ? {3'd0,1'b1} :
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
	       */
`ifdef PORT4 
    (we_req4 & !tx_fifo_full[4]) ? {3'd4,1'b1} :
`endif
`ifdef PORT5
    (we_req5 & !tx_fifo_full[5]) ? {3'd5,1'b1} :
`endif
`ifdef PORT6
    (we_req6 & !tx_fifo_full[6]) ? {3'd6,1'b1} :
`endif
`ifdef PORT7
    (we_req7 & !tx_fifo_full[7]) ? {3'd7,1'b1} :
`endif
`ifdef PORT0
    (we_req0 & !tx_fifo_full[0]) ? {3'd0,1'b1} :
`endif
`ifdef PORT1
    (we_req1 & !tx_fifo_full[1]) ? {3'd1,1'b1} :
`endif
`ifdef PORT2
    (we_req2 & !tx_fifo_full[2]) ? {3'd2,1'b1} :
`endif
`ifdef PORT3
    (we_req3 & !tx_fifo_full[3]) ? {3'd3,1'b1} :
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
      // A side (wb)
      .a_dat_i(tx_fifo_dat_i),
      .a_we_i(tx_fifo_we),
      .a_fifo_sel_i(tx_fifo_a_sel_i),
      .a_fifo_full_o(tx_fifo_full),
      .a_clk(wb_clk),
      // B side (sdram)
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
      .init(adr_init),
      .inc(adr_inc),
      .adr_o(burst_adr),
      .done(done),
      .clk(sdram_clk),
      .rst(wb_rst)
      );

   ref_counter ref_counter0
     (
      .zq(ref_zf),
      .clk(sdram_clk),
      .rst(wb_rst)
      );

   always @ (posedge sdram_clk or posedge wb_rst)
     if (wb_rst)
       ref_req <= 1'b1;
     else
       if (ref_zf)
	 ref_req <= 1'b1;
       else if (ref_ack)
	 ref_req <= 1'b0;
   

`ifdef SDR_16
   wire read;
   reg [15:0] dq_i_reg, dq_i_tmp_reg;   
      
   // SDR SDRAM 16 FSM
   sdr_16 sdr_16_0
     (
      .adr_inc(adr_inc),
      .adr_init(adr_init),
      .fifo_re(tx_fifo_re),
      .tx_fifo_dat_o(tx_fifo_dat_o),
      .burst_adr(burst_adr),
      .done(done),
      .fifo_empty(tx_fifo_empty),
      .fifo_sel(tx_fifo_b_sel_i_cur),
      .read(read),
      // refresh
      .ref_req(ref_req),
      .ref_ack(ref_ack),
      // sdram
      .dq(dq_o),
      .dqm(dqm_pad_o),
      .dq_oe(dq_oe),
      .a({ba_pad_o,a_pad_o}),
      .cmd({ras_pad_o,cas_pad_o,we_pad_o}),
      .cs_n(cs_n_pad_o),
      .sdram_clk(sdram_clk),
      .wb_rst(wb_rst)
      );
   
   assign cke_pad_o = 1'b1;

   defparam delay0.depth=`CL+2;   
   delay delay0
     (
      .d({read,tx_fifo_b_sel_i_cur}),
      .q({rx_fifo_we,rx_fifo_a_sel_i}),
      .clk(sdram_clk),
      .rst(wb_rst)
      );

   always @ (posedge sdram_clk or posedge wb_rst)
     if (wb_rst)
       {dq_i_reg, dq_i_tmp_reg} <= {16'h0000,16'h0000};
     else
       {dq_i_reg, dq_i_tmp_reg} <= {dq_i, dq_i_reg};

   assign rx_fifo_dat_i = {dq_i_tmp_reg, dq_i_reg, 4'h0};
   
`endif //  `ifdef SDR_16

   // receiving side FIFO
   fifo rx_fifo
     (
      // A side (sdram)
      .a_dat_i(rx_fifo_dat_i),
      .a_we_i(rx_fifo_we),
      .a_fifo_sel_i(rx_fifo_a_sel_i),
      .a_fifo_full_o(rx_fifo_full),
      .a_clk(sdram_clk),
      // B side (wb)
      .b_dat_o(rx_fifo_dat_o),
      .b_re_i(rx_fifo_re),
      .b_fifo_sel_i(rx_fifo_b_sel_i),
      .b_fifo_empty_o(rx_fifo_empty),
      .b_clk(wb_clk),
      // misc
      .rst(wb_rst) 	 
      );

   // WB/FIFO readout priority
   // 4,5,6,7,0,1,2,3
   assign {rx_fifo_re, rx_fifo_b_sel_i} = 
`ifdef PORT4
     !rx_fifo_empty[4] & wbs4_stb_i ? {1'b1,3'd4} :
`endif		    	    		       
`ifdef PORT5	    	    		       
     !rx_fifo_empty[5] & wbs5_stb_i ? {1'b1,3'd5} :
`endif		    	    		       
`ifdef PORT6	    	    		       
     !rx_fifo_empty[6] & wbs6_stb_i ? {1'b1,3'd6} :
`endif		    	    		       
`ifdef PORT7	    	    		       
     !rx_fifo_empty[7] & wbs7_stb_i ? {1'b1,3'd7} :
`endif		    	    		       
`ifdef PORT0	    	    		       
     !rx_fifo_empty[0] & wbs0_stb_i ? {1'b1,3'd0} :
`endif		    	    		       
`ifdef PORT1	    	    		       
     !rx_fifo_empty[1] & wbs1_stb_i ? {1'b1,3'd1} :
`endif		    	    		       
`ifdef PORT2	    	    		       
     !rx_fifo_empty[2] & wbs2_stb_i ? {1'b1,3'd2} :
`endif		    	    		       
`ifdef PORT3	    	    		       
     !rx_fifo_empty[3] & wbs3_stb_i ? {1'b1,3'd3} :
`endif
       {1'b0,3'd4};

   // ack read
   // delay one cycle to compensate for synchronous FIFO readout
   always @ (posedge wb_clk or posedge wb_rst)
     if (wb_rst)
       begin
`ifdef PORT0
	  wbs0_ack_re <= 1'b0;
`endif
`ifdef PORT1
	  wbs1_ack_re <= 1'b0;
`endif
`ifdef PORT2
	  wbs2_ack_re <= 1'b0;
`endif
`ifdef PORT3
	  wbs3_ack_re <= 1'b0;
`endif
`ifdef PORT4
	  wbs4_ack_re <= 1'b0;
`endif
`ifdef PORT5
	  wbs5_ack_re <= 1'b0;
`endif
`ifdef PORT6
	  wbs6_ack_re <= 1'b0;
`endif
`ifdef PORT7
	  wbs7_ack_re <= 1'b0;
`endif
       end
     else
       begin
`ifdef PORT0
	  wbs0_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd0);
`endif
`ifdef PORT1
	  wbs1_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd1);
`endif
`ifdef PORT2
	  wbs2_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd2);
`endif
`ifdef PORT3
	  wbs3_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd3);
`endif
`ifdef PORT4
	  wbs4_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd4);
`endif
`ifdef PORT5
	  wbs5_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd5);
`endif
`ifdef PORT6
	  wbs6_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd6);
`endif
`ifdef PORT7
	  wbs7_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd7);
`endif
       end
   
   // ack
`ifdef PORT0
   assign wbs0_dat_o = rx_fifo_dat_o[35:4];
   assign wbs0_ack_o = (!wbs0_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd0)) | wbs0_ack_re;
`endif
`ifdef PORT1
   assign wbs1_dat_o = rx_fifo_dat_o[35:4];
   assign wbs1_ack_o = (!wbs1_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd1)) | wbs1_ack_re;
`endif
`ifdef PORT2
   assign wbs2_dat_o = rx_fifo_dat_o[35:4];
   assign wbs2_ack_o = (!wbs2_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd2)) | wbs2_ack_re;
`endif
`ifdef PORT3
   assign wbs3_dat_o = rx_fifo_dat_o[35:4];
   assign wbs3_ack_o = (!wbs3_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd3)) | wbs3_ack_re;
`endif
`ifdef PORT4
   assign wbs4_dat_o = rx_fifo_dat_o[35:4];
   assign wbs4_ack_o = (!wbs4_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd4)) | wbs4_ack_re;
`endif
`ifdef PORT5
   assign wbs5_dat_o = rx_fifo_dat_o[35:4];
   assign wbs5_ack_o = (!wbs5_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd5)) | wbs5_ack_re;
`endif
`ifdef PORT6
   assign wbs6_dat_o = rx_fifo_dat_o[35:4];
   assign wbs6_ack_o = (!wbs6_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd6)) | wbs6_ack_re;
`endif
`ifdef PORT7
   assign wbs7_dat_o = rx_fifo_dat_o[35:4];
   assign wbs7_ack_o = (!wbs7_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd7)) | wbs7_ack_re;   
`endif
   
endmodule // wb_sdram_ctrl_top
