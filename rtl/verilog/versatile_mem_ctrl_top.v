`timescale 1ns/1ns
`ifdef DDR_16
 `include "ddr_16_defines.v"
`endif
`ifdef SDR_16
 `include "sdr_16_defines.v"
`endif
module versatile_mem_ctrl_top
  (
   // wishbone side
   wb_adr_i_0, wb_dat_i_0, wb_dat_o_0,
   wb_stb_i_0, wb_cyc_i_0, wb_ack_o_0,
   wb_adr_i_1, wb_dat_i_1, wb_dat_o_1,
   wb_stb_i_1, wb_cyc_i_1, wb_ack_o_1,
   wb_adr_i_2, wb_dat_i_2, wb_dat_o_2,
   wb_stb_i_2, wb_cyc_i_2, wb_ack_o_2,
   wb_adr_i_3, wb_dat_i_3, wb_dat_o_3,
   wb_stb_i_3, wb_cyc_i_3, wb_ack_o_3,
   wb_clk, wb_rst,

`ifdef SDR_16
   ba_pad_o, a_pad_o, cs_n_pad_o, ras_pad_o, cas_pad_o, we_pad_o, dq_o, dqm_pad_o, dq_i, dq_oe, cke_pad_o,
`endif

`ifdef DDR_16
   ck_pad_o, ck_n_pad_o, cke_pad_o, ck_fb_pad_o, ck_fb_pad_i,
   cs_n_pad_o, ras_pad_o, cas_pad_o,  we_pad_o,
   dm_rdqs_pad_io,  ba_pad_o, addr_pad_o, dq_pad_io, dqs_pad_io, dqs_oe, dqs_n_pad_io, rdqs_n_pad_i, odt_pad_o,
`endif
   // SDRAM signals
   sdram_clk, sdram_rst
   );

   // number of wb clock domains
   parameter nr_of_wb_clk_domains = 1;
   // number of wb ports in each wb clock domain
   parameter nr_of_wb_ports_clk0  = 1;
   parameter nr_of_wb_ports_clk1  = 0;
   parameter nr_of_wb_ports_clk2  = 0;
   parameter nr_of_wb_ports_clk3  = 0;

   /*
   // Now these are defines, synthesis tool was doing strange things! jb
   parameter ba_size = 2;
   parameter row_size = 13;
   parameter col_size = 9;
   parameter [2:0] cl = 3'b010; // valid options 010, 011 used for SDR LMR
   */
   
   input  [36*nr_of_wb_ports_clk0-1:0] wb_adr_i_0;
   input [36*nr_of_wb_ports_clk0-1:0]  wb_dat_i_0;
   output [32*nr_of_wb_ports_clk0-1:0] wb_dat_o_0;
   input [0:nr_of_wb_ports_clk0-1]     wb_stb_i_0, wb_cyc_i_0, wb_ack_o_0;
   
   input [36*nr_of_wb_ports_clk1-1:0]  wb_adr_i_1;
   input [36*nr_of_wb_ports_clk1-1:0]  wb_dat_i_1;
   output [32*nr_of_wb_ports_clk1-1:0] wb_dat_o_1;
   input [0:nr_of_wb_ports_clk1-1]     wb_stb_i_1, wb_cyc_i_1, wb_ack_o_1;
   
   input [36*nr_of_wb_ports_clk2-1:0]  wb_adr_i_2;
   input [36*nr_of_wb_ports_clk2-1:0]  wb_dat_i_2;
   output [32*nr_of_wb_ports_clk2-1:0] wb_dat_o_2;
   input [0:nr_of_wb_ports_clk2-1]     wb_stb_i_2, wb_cyc_i_2, wb_ack_o_2;
   
   input [36*nr_of_wb_ports_clk3-1:0]  wb_adr_i_3;
   input [36*nr_of_wb_ports_clk3-1:0]  wb_dat_i_3;
   output [32*nr_of_wb_ports_clk3-1:0] wb_dat_o_3;
   input [0:nr_of_wb_ports_clk3-1]     wb_stb_i_3, wb_cyc_i_3, wb_ack_o_3;
   
   input [0:nr_of_wb_clk_domains-1]    wb_clk;
   input [0:nr_of_wb_clk_domains-1]    wb_rst;
   
`ifdef SDR_16
   output [1:0] 		       ba_pad_o;
   output [12:0] 		       a_pad_o;
   output 			       cs_n_pad_o;
   output 			       ras_pad_o;
   output 			       cas_pad_o;
   output 			       we_pad_o;
   output reg [(`SDRAM_DATA_WIDTH)-1:0] 		       dq_o /*synthesis syn_useioff=1 syn_allow_retiming=0 */;
   output [1:0] 		       dqm_pad_o;
   input [(`SDRAM_DATA_WIDTH)-1:0] 		       dq_i /*synthesis syn_useioff=1 syn_allow_retiming=0 */;
   output 			       dq_oe;
   output 			       cke_pad_o;
`endif
`ifdef DDR_16
   output 			       ck_pad_o;
   output 			       ck_n_pad_o;
   output 			       cke_pad_o;
   output 			       ck_fb_pad_o;
   input 			       ck_fb_pad_i;
   output 			       cs_n_pad_o;
   output 			       ras_pad_o;
   output 			       cas_pad_o;
   output 			       we_pad_o;
   inout [1:0] 			       dm_rdqs_pad_io;
   output [1:0] 		       ba_pad_o;
   output [12:0] 		       addr_pad_o;
   inout [15:0] 		       dq_pad_io;
   inout [1:0] 			       dqs_pad_io;
   output 			       dqs_oe;
   inout [1:0] 			       dqs_n_pad_io;
   input [1:0] 			       rdqs_n_pad_i;
   output 			       odt_pad_o;
`endif
   input 			       sdram_clk, sdram_rst;

   wire [0:15] 			       fifo_empty[0:3];
   wire 			       current_fifo_empty;
   wire [0:15] 			       fifo_re[0:3];
   wire [35:0] 			       fifo_dat_o[0:3];
   wire [31:0] 			       fifo_dat_i;
   wire [0:15] 			       fifo_we[0:3];
   wire 			       fifo_rd_adr, fifo_rd_data, fifo_wr, idle, count0;
   
   wire [0:15] 			       fifo_sel_i, fifo_sel_dly;
   reg [0:15] 			       fifo_sel_reg;
   wire [1:0] 			       fifo_sel_domain_i, fifo_sel_domain_dly;
   reg [1:0] 			       fifo_sel_domain_reg;

   reg 				       refresh_req;
   
   wire [35:0] 			       tx_fifo_dat_o;   // tmp added /MF

   generate   
      if (nr_of_wb_clk_domains > 0) begin    
         versatile_mem_ctrl_wb
           # (.nr_of_wb_ports(nr_of_wb_ports_clk0))
         wb0
	   (
            // wishbone side
            .wb_adr_i_v(wb_adr_i_0),
            .wb_dat_i_v(wb_dat_i_0),
            .wb_dat_o_v(wb_dat_o_0),
            .wb_stb_i(wb_stb_i_0),
            .wb_cyc_i(wb_cyc_i_0),
            .wb_ack_o(wb_ack_o_0),
            .wb_clk(wb_clk[0]),
            .wb_rst(wb_rst[0]),
            // SDRAM controller interface
            .sdram_dat_o(fifo_dat_o[0]),
            .sdram_fifo_empty(fifo_empty[0][0:nr_of_wb_ports_clk0-1]),
            .sdram_fifo_rd_adr(fifo_rd_adr),
            .sdram_fifo_rd_data(fifo_rd_data),
            .sdram_fifo_re(fifo_re[0][0:nr_of_wb_ports_clk0-1]),
            .sdram_dat_i(fifo_dat_i),
            .sdram_fifo_wr(fifo_wr),
            .sdram_fifo_we(fifo_we[0][0:nr_of_wb_ports_clk0-1]),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
      end
      if (nr_of_wb_ports_clk0 < 16) begin
         assign fifo_empty[0][nr_of_wb_ports_clk0:15] = {(16-nr_of_wb_ports_clk0){1'b1}};
      end
   endgenerate

   generate   
      if (nr_of_wb_clk_domains > 1) begin    
         versatile_mem_ctrl_wb
           # (.nr_of_wb_ports(nr_of_wb_ports_clk1))
         wb1
	   (
            // wishbone side
            .wb_adr_i_v(wb_adr_i_1),
            .wb_dat_i_v(wb_dat_i_1),
            .wb_dat_o_v(wb_dat_o_1),
            .wb_stb_i(wb_stb_i_1),
            .wb_cyc_i(wb_cyc_i_1),
            .wb_ack_o(wb_ack_o_1),
            .wb_clk(wb_clk[1]),
            .wb_rst(wb_rst[1]),
            // SDRAM controller interface
            .sdram_dat_o(fifo_dat_o[1]),
            .sdram_fifo_empty(fifo_empty[1][0:nr_of_wb_ports_clk1-1]),
            .sdram_fifo_rd_adr(fifo_rd_adr),
            .sdram_fifo_rd_data(fifo_rd_data),
            .sdram_fifo_re(fifo_re[1][0:nr_of_wb_ports_clk1-1]),
            .sdram_dat_i(fifo_dat_i),
            .sdram_fifo_wr(fifo_wr),
            .sdram_fifo_we(fifo_we[1][0:nr_of_wb_ports_clk1-1]),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
         if (nr_of_wb_ports_clk1 < 16) begin
            assign fifo_empty[1][nr_of_wb_ports_clk1:15] = {(16-nr_of_wb_ports_clk1){1'b1}};
         end
      end else begin
         assign fifo_empty[1] = {16{1'b1}};
         assign fifo_dat_o[1] = {36{1'b0}};
      end
   endgenerate

   generate   
      if (nr_of_wb_clk_domains > 2) begin    
         versatile_mem_ctrl_wb
           # (.nr_of_wb_ports(nr_of_wb_ports_clk1))
         wb2
	   (
            // wishbone side
            .wb_adr_i_v(wb_adr_i_2),
            .wb_dat_i_v(wb_dat_i_2),
            .wb_dat_o_v(wb_dat_o_2),
            .wb_stb_i(wb_stb_i_2),
            .wb_cyc_i(wb_cyc_i_2),
            .wb_ack_o(wb_ack_o_2),
            .wb_clk(wb_clk[2]),
            .wb_rst(wb_rst[2]),
            // SDRAM controller interface
            .sdram_dat_o(fifo_dat_o[2]),
            .sdram_fifo_empty(fifo_empty[2][0:nr_of_wb_ports_clk2-1]),
            .sdram_fifo_rd_adr(fifo_rd_adr),
            .sdram_fifo_rd_data(fifo_rd_data),
            .sdram_fifo_re(fifo_re[2][0:nr_of_wb_ports_clk2-1]),
            .sdram_dat_i(fifo_dat_i),
            .sdram_fifo_wr(fifo_wr),
            .sdram_fifo_we(fifo_we[2][0:nr_of_wb_ports_clk2-1]),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
         if (nr_of_wb_ports_clk2 < 16) begin
            assign fifo_empty[2][nr_of_wb_ports_clk2:15] = {(16-nr_of_wb_ports_clk2){1'b1}};
         end
      end else begin
         assign fifo_empty[2] = {16{1'b1}};
         assign fifo_dat_o[2] = {36{1'b0}};
      end
   endgenerate

   generate   
      if (nr_of_wb_clk_domains > 3) begin    
         versatile_mem_ctrl_wb
           # (.nr_of_wb_ports(nr_of_wb_ports_clk3))
         wb3
	   (
            // wishbone side
            .wb_adr_i_v(wb_adr_i_3),
            .wb_dat_i_v(wb_dat_i_3),
            .wb_dat_o_v(wb_dat_o_3),
            .wb_stb_i(wb_stb_i_3),
            .wb_cyc_i(wb_cyc_i_3),
            .wb_ack_o(wb_ack_o_3),
            .wb_clk(wb_clk[3]),
            .wb_rst(wb_rst[3]),
            // SDRAM controller interface
            .sdram_dat_o(fifo_dat_o[3]),
            .sdram_fifo_empty(fifo_empty[3][0:nr_of_wb_ports_clk3-1]),
            .sdram_fifo_rd_adr(fifo_rd_adr),
            .sdram_fifo_rd_data(fifo_rd_data),
            .sdram_fifo_re(fifo_re[3][0:nr_of_wb_ports_clk3-1]),
            .sdram_dat_i(fifo_dat_i),
            .sdram_fifo_wr(fifo_wr),
            .sdram_fifo_we(fifo_we[3][0:nr_of_wb_ports_clk3-1]),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
         if (nr_of_wb_ports_clk3 < 16) begin
            assign fifo_empty[3][nr_of_wb_ports_clk3:15] = {(16-nr_of_wb_ports_clk3){1'b1}};
         end
      end else begin
         assign fifo_empty[3] = {16{1'b1}};
         assign fifo_dat_o[3] = {36{1'b0}};
      end
   endgenerate

   encode encode0 
     (
      .fifo_empty_0(fifo_empty[0]), .fifo_empty_1(fifo_empty[1]), .fifo_empty_2(fifo_empty[2]), .fifo_empty_3(fifo_empty[3]),
      .fifo_sel(fifo_sel_i), .fifo_sel_domain(fifo_sel_domain_i)
      );

   always @ (posedge sdram_clk or posedge sdram_rst)
     begin
	if (sdram_rst)
          {fifo_sel_reg,fifo_sel_domain_reg} <= {16'h0,2'b00};
	else
          if (idle)
            {fifo_sel_reg,fifo_sel_domain_reg} <= {fifo_sel_i,fifo_sel_domain_i};
     end

   decode decode0 
     (
      .fifo_sel(fifo_sel_reg), .fifo_sel_domain(fifo_sel_domain_reg),
      .fifo_we_0(fifo_re[0]), .fifo_we_1(fifo_re[1]), .fifo_we_2(fifo_re[2]), .fifo_we_3(fifo_re[3])
      );

   // fifo_re[0-3] is a one-hot read enable structure
   // fifo_empty should go active when chosen fifo queue is empty
   assign current_fifo_empty = (idle) ? (!(|fifo_sel_i)) : (|(fifo_empty[0] & fifo_re[0])) | (|(fifo_empty[1] & fifo_re[1])) | (|(fifo_empty[2] & fifo_re[2])) | (|(fifo_empty[3] & fifo_re[3]));

   decode decode1 
     (
      .fifo_sel(fifo_sel_dly), .fifo_sel_domain(fifo_sel_domain_dly),
      .fifo_we_0(fifo_we[0]), .fifo_we_1(fifo_we[1]), .fifo_we_2(fifo_we[2]), .fifo_we_3(fifo_we[3])
      );

`ifdef SDR_16

   wire ref_cnt_zero;
   reg [(`SDRAM_DATA_WIDTH)-1:0] dq_i_reg, dq_i_tmp_reg;
   reg [17:0] dq_o_tmp_reg;
   wire       cmd_aref, cmd_read;
   
   // refresch counter
   ref_counter ref_counter0( .zq(ref_cnt_zero), .rst(sdram_rst), .clk(sdram_clk));
   always @ (posedge sdram_clk or posedge sdram_rst)
     if (sdram_rst)
       refresh_req <= 1'b0;
     else
       if (ref_cnt_zero)
         refresh_req <= 1'b1;
       else if (cmd_aref)
         refresh_req <= 1'b0;
   
   // SDR SDRAM 16 FSM
   fsm_sdr_16 fsm_sdr_16_0 
     (
      .adr_i({fifo_dat_o[fifo_sel_domain_reg][`BA_SIZE+`ROW_SIZE+`COL_SIZE+6-2:6],1'b0}),
      .we_i(fifo_dat_o[fifo_sel_domain_reg][5]),
      .bte_i(fifo_dat_o[fifo_sel_domain_reg][4:3]),
      .sel_i({fifo_dat_o[fifo_sel_domain_reg][3:2],dq_o_tmp_reg[1:0]}),
      .fifo_empty(current_fifo_empty), 
      .fifo_rd_adr(fifo_rd_adr), 
      .fifo_rd_data(fifo_rd_data),
      .state_idle(idle), 
      .count0(count0),
      .refresh_req(refresh_req),
      .cmd_aref(cmd_aref), 
      .cmd_read(cmd_read),
      .ba(ba_pad_o), .a(a_pad_o), 
      .cmd({ras_pad_o, cas_pad_o, we_pad_o}), 
      .dq_oe(dq_oe), 
      .dqm(dqm_pad_o),
      .sdram_clk(sdram_clk), 
      .sdram_rst(sdram_rst)
      );
   /*
   defparam fsm_sdr_16_0.ba_size = ba_size;
   defparam fsm_sdr_16_0.row_size = row_size;
   defparam fsm_sdr_16_0.col_size = col_size;
   defparam fsm_sdr_16_0.init_cl = cl;
   */
   assign cs_pad_o = 1'b0;
   assign cke_pad_o = 1'b1;

   genvar     i;
   generate
      for (i=0; i < 16; i=i+1) begin : dly

         defparam delay0.depth=`INIT_CL+2;   
         defparam delay0.width=1;
         delay delay0 (
		       .d(fifo_sel_reg[i]),
		       .q(fifo_sel_dly[i]),
		       .clk(sdram_clk),
		       .rst(sdram_rst)
		       );
      end
      
      defparam delay1.depth=`INIT_CL+2;   
      defparam delay1.width=2;
      delay delay1 (
		    .d(fifo_sel_domain_reg),
		    .q(fifo_sel_domain_dly),
		    .clk(sdram_clk),
		    .rst(sdram_rst)
		    );
      
      defparam delay2.depth=`INIT_CL+2;   
      defparam delay2.width=1;
      delay delay2 (
		    .d(cmd_read),
		    .q(fifo_wr),
		    .clk(sdram_clk),
		    .rst(sdram_rst)
		    );    
      
   endgenerate  

   // output registers
   assign cs_n_pad_o = 1'b0;
   assign cke_pad_o  = 1'b1;
   
   always @ (posedge sdram_clk or posedge sdram_rst)
     if (sdram_rst)
       {dq_i_reg, dq_i_tmp_reg} <= {16'h0000,16'h0000};
     else
       {dq_i_reg, dq_i_tmp_reg} <= {dq_i, dq_i_reg};

   assign fifo_dat_i = {dq_i_tmp_reg, dq_i_reg};
   
   always @ (posedge sdram_clk or posedge sdram_rst)
     if (sdram_rst)
       dq_o_tmp_reg <= 18'h0;
     else
       dq_o_tmp_reg <= {fifo_dat_o[fifo_sel_domain_reg][19:4],fifo_dat_o[fifo_sel_domain_reg][1:0]};
   
   // output dq_o mux and dffs
   always @ (posedge sdram_clk or posedge sdram_rst)
     if (sdram_rst)
       dq_o <= 16'h0000;
     else
       if (~count0)
         dq_o <= fifo_dat_o[fifo_sel_domain_reg][35:20];
       else
         dq_o <= dq_o_tmp_reg[17:2];
   
   /*
    // data mask signals should be not(sel_i) for write and 2'b00 for read
    always @ (posedge sdram_clk or posedge sdram_rst)
    if (sdram_rst)
    dqm_pad_o <= 2'b00;
    else
    if (~count0)
    dqm_pad_o <= ~fifo_dat_o[fifo_sel_domain_reg][3:2];
    else
    dqm_pad_o <= ~dq_o_tmp_reg[1:0];
    */
   /*
    always @ (posedge sdram_clk or posedge sdram_rst)
    if (sdram_rst) begin
    {dq_o, dqm_pad_o} <= {16'h0000,2'b00};
    
    end else
    if (~count0) begin
    dq_o <= fifo_dat_o[fifo_sel_domain_reg][35:20];
    dq_o_tmp_reg[17:2] <= fifo_dat_o[fifo_sel_domain_reg][19:4];
    if (cmd_read)
    dqm_pad_o <= 2'b00;
    else
    dqm_pad_o <= ~fifo_dat_o[fifo_sel_domain_reg][3:2];
    if (cmd_read)
    dq_o_tmp_reg[1:0] <= 2'b00;
    else
    dq_o_tmp_reg[1:0] <= ~fifo_dat_o[fifo_sel_domain_reg][1:0];
       end else
    {dq_o,dqm_pad_o} <= dq_o_tmp_reg;
    */


`endif //  `ifdef SDR_16


`ifdef DDR_16
   wire        read, write;
   wire        sdram_clk_90, sdram_clk_180, sdram_clk_270;
   wire        ck_fb;
   reg         cke, ras, cas, we, cs_n;
   wire        ras_o, cas_o, we_o, cs_n_o;
   wire [1:0]  ba_o;
   wire [12:0] addr_o;
   reg [1:0]   ba;
   reg [12:0]  addr;
   wire        dq_en, dqm_en;
   reg [15:0]  dq_tx_reg;
   wire [15:0] dq_tx;
   reg [31:0]  dq_rx_reg;
   wire [31:0] dq_rx;
   wire [15:0] dq_o;
   reg [3:0]   dqm_tx_reg;
   wire [3:0]  dqm_tx;
   wire [1:0]  dqm_o, dqs_o, dqs_n_o;
   wire        ref_delay, ref_delay_ack;
   wire        bl_en, bl_ack;
   wire        tx_fifo_re_i;
   wire        adr_init_delay;
   reg         adr_init_delay_i;
   reg [3:0]   burst_cnt;
   wire [3:0]  burst_next_cnt, burst_length;
   wire        burst_mask;
   wire [12:0] cur_row;

   // DDR SDRAM 16 FSM
   ddr_16 ddr_16_0
     (
      .adr_init(adr_init),
      .fifo_re(tx_fifo_re_i),
      .fifo_re_d(tx_fifo_re),
      .tx_fifo_dat_o(tx_fifo_dat_o),
      .burst_adr(burst_adr),
      .fifo_empty(tx_fifo_empty),
      .fifo_sel(tx_fifo_b_sel_i_cur),
      .read(read),
      .write(write),
      .ref_req(ref_req),
      .ref_ack(ref_ack),
      .ref_delay(ref_delay),
      .ref_delay_ack(ref_delay_ack),
      .bl_en(bl_en),
      .bl_ack(bl_ack),
      .a({ba_o,addr_o}),
      .cmd({ras_o,cas_o,we_o}),
      .cs_n(cs_n_o),
      .cur_row(cur_row),
      .sdram_clk(sdram_clk_0),
      .wb_rst(wb_rst)
      );

   inc_adr inc_adr0
     (
      .adr_i(tx_fifo_dat_o[9:6]),
      .bte_i(tx_fifo_dat_o[4:3]),
      .cti_i(tx_fifo_dat_o[2:0]),
      .init(adr_init),
      .inc(),
      .adr_o(burst_adr),
      .done(done),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // Delay, refresh to activate/refresh
   ref_delay_counter ref_delay_counter0
     (
      .cke(ref_delay),
      .zq(ref_delay_ack),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );
   
   // Burst length, DDR2 SDRAM
   burst_length_counter burst_length_counter0
     (
      .cke(bl_en),
      .zq(bl_ack),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // Wishbone burst length
   assign burst_length = (adr_init && tx_fifo_dat_o[2:0] == 3'b000) ? 4'd1 :   // classic cycle
                         (adr_init && tx_fifo_dat_o[2:0] == 3'b010) ? 4'd4 :   // incremental burst cycle
                         burst_length;

   // Burst mask
   // Burst length counter
   assign burst_next_cnt = (burst_cnt == 3) ? 4'd0 : burst_cnt + 4'd1;
   always @ (posedge sdram_clk_0 or posedge wb_rst)
     if (wb_rst)
       burst_cnt <= 4'h0;
     else
       if (bl_en)
         burst_cnt <= burst_next_cnt;
   // Burst Mask
   assign burst_mask = (burst_cnt >= burst_length) ? 1'b1 : 1'b0;

   // Control outports, DDR2 SDRAM
   always @ (posedge sdram_clk_180 or posedge wb_rst)
     if (wb_rst) begin
	cs_n <= 1'b0;
	cke  <= 1'b0;
	ras  <= 1'b0;
	cas  <= 1'b0;
	we   <= 1'b0;
	ba   <= 2'b00;
	addr <= 13'b0000000000000;
     end
     else begin
	cs_n <= cs_n_o;
	cke  <= 1'b1;
	ras  <= ras_o;
	cas  <= cas_o;
	we   <= we_o;
	ba   <= ba_o;
	addr <= addr_o;
     end

   assign cke_pad_o  = cke;
   assign ras_pad_o  = ras;
   assign cas_pad_o  = cas;
   assign we_pad_o   = we;
   assign ba_pad_o   = ba;
   assign addr_pad_o = addr;
   assign cs_n_pad_o = cs_n;


   // Read latency, delay the control signals to fit latency of the DDR2 SDRAM
   defparam delay0.depth=`INIT_CL+`AL+2; 
   defparam delay0.width=4;
   delay delay0 
     (
      .d({read && !burst_mask,tx_fifo_b_sel_i_cur}),
      .q({rx_fifo_we,rx_fifo_a_sel_i}),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );
   
   // write latency, delay the control signals to fit latency of the DDR2 SDRAM
   defparam delay1.depth=`INIT_CL+`AL-1;
   defparam delay1.width=2;
   delay delay1 
     (
      .d({write, burst_mask}),
      .q({dq_en, dqm_en}),
      .clk(sdram_clk_270),
      .rst(wb_rst)
      );

   // if CL>3 delay read from Tx FIFO
   defparam delay2.depth=`INIT_CL+`AL-3;
   defparam delay2.width=1;
   delay delay2 
     (		 
		 .d(tx_fifo_re_i && !burst_mask),
		 .q(tx_fifo_re),
		 .clk(sdram_clk_0),
		 .rst(wb_rst)
		 );

   // if CL=3, no delay
   //assign tx_fifo_re = tx_fifo_re_i && !burst_mask;

   // Increment address
   defparam delay3.depth=`INIT_CL+`AL-1;
   defparam delay3.width=1;
   delay delay3 
     (
      .d({write|read}),
      .q({adr_inc}),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // DCM/PLL with internal and external feedback
   // Remove skew from internal and external clock
   // Parameters are set in dcm_pll.v
   dcm_pll dcm_pll_0 
     (
      .rst(wb_rst),
      .clk_in(sdram_clk),
      .clkfb_in(ck_fb_pad_i),
      .clk0_out(sdram_clk_0),
      .clk90_out(sdram_clk_90),
      .clk180_out(sdram_clk_180),
      .clk270_out(sdram_clk_270),
      .clkfb_out(ck_fb)
      );

   // DDR2 IF
   versatile_mem_ctrl_ddr versatile_mem_ctrl_ddr_0 
     (
      // DDR2 SDRAM ports
      .ck_o(ck_pad_o),
      .ck_n_o(ck_n_pad_o),
      .dq_io(dq_pad_io),
      .dqs_io(dqs_pad_io),
      .dqs_n_io(dqs_n_pad_io), 
      .dm_rdqs_io(dm_rdqs_pad_io),
      // Memory controller side
      .tx_dat_i(tx_fifo_dat_o),
      .rx_dat_o(rx_fifo_dat_i),
      .dq_en(dq_en),
      .dqm_en(dqm_en),
      .wb_rst(wb_rst),
      .sdram_clk_0(sdram_clk_0),
      .sdram_clk_90(sdram_clk_90),
      .sdram_clk_180(sdram_clk_180),
      .sdram_clk_270(sdram_clk_270));

   // Assing outputs
   // Non-DDR outputs
   assign ba_pad_o     = ba;
   assign addr_pad_o   = addr;
   assign dqs_oe       = dq_en;
   assign cke_pad_o    = cke;
   assign ras_pad_o    = ras;
   assign cas_pad_o    = cas;
   assign we_pad_o     = we;
   assign cs_n_pad_o   = cs_n;
   assign ck_fb_pad_o  = ck_fb;

`endif //  `ifdef DDR_16
   
endmodule // wb_sdram_ctrl_top
