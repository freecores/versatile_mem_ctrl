`include "versatile_mem_ctrl_defines.v"
`ifdef SDR_16
 `include "sdr_16_defines.v"
`endif
`ifdef DDR_16
 `include "ddr_16_defines.v"
`endif

module versatile_mem_ctrl_top
  (
    // wishbone side
    wb_adr_i_0, wb_dat_i_0, wb_dat_o_0,
    wb_stb_i_0, wb_cyc_i_0, wb_ack_o_0,
    wb_adr_i_1, wb_dat_i_1, wb_dat_o_1,
    wb_stb_i_1, wb_cyc_i_1, wb_ack_o_1,
    wb_adr_i_2, wb_dat_i_2, wb_dat_o_2,   // Fixed typo /MF
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
   sdram_clk
   );

    // number of wb clock domains
    parameter nr_of_wb_clk_domains = 1;
    // number of wb ports in each wb clock domain
    parameter nr_of_wb_ports_clk0  = 3;
    parameter nr_of_wb_ports_clk1  = 0;
    parameter nr_of_wb_ports_clk2  = 0;
    parameter nr_of_wb_ports_clk3  = 0;
    
    parameter tot_nr_of_wb_ports = nr_of_wb_ports_clk0 + nr_of_wb_ports_clk1 + nr_of_wb_ports_clk2 + nr_of_wb_ports_clk3;

    input  [36*nr_of_wb_ports_clk0-1:0] wb_adr_i_0;
    input  [36*nr_of_wb_ports_clk0-1:0] wb_dat_i_0;
    output [31:0]                       wb_dat_o_0;
    input  [0:nr_of_wb_ports_clk0-1]    wb_stb_i_0, wb_cyc_i_0, wb_ack_o_0;
    
    input  [36*nr_of_wb_ports_clk1-1:0] wb_adr_i_1;
    input  [36*nr_of_wb_ports_clk1-1:0] wb_dat_i_1;
    output [31:0]                       wb_dat_o_1;
    input  [0:nr_of_wb_ports_clk1-1]    wb_stb_i_1, wb_cyc_i_1, wb_ack_o_1;
    
    input  [36*nr_of_wb_ports_clk2-1:0] wb_adr_i_2;   // Fixed typo /MF
    input  [36*nr_of_wb_ports_clk2-1:0] wb_dat_i_2;   // Fixed typo /MF
    output [31:0]                       wb_dat_o_2;
    input  [0:nr_of_wb_ports_clk2-1]    wb_stb_i_2, wb_cyc_i_2, wb_ack_o_2;
    
    input  [36*nr_of_wb_ports_clk3-1:0] wb_adr_i_3;
    input  [36*nr_of_wb_ports_clk3-1:0] wb_dat_i_3;
    output [31:0]                       wb_dat_o_3;
    input  [0:nr_of_wb_ports_clk3-1]    wb_stb_i_3, wb_cyc_i_3, wb_ack_o_3;
        
    input  [0:nr_of_wb_clk_domains-1]   wb_clk;
    input  [0:nr_of_wb_clk_domains-1]   wb_rst;
    
`ifdef SDR_16
   output  [1:0] ba_pad_o;
   output [12:0] a_pad_o;
   output        cs_n_pad_o;
   output        ras_pad_o;
   output        cas_pad_o;
   output        we_pad_o;
   output [15:0] dq_o;
   output  [1:0] dqm_pad_o;
   input  [15:0] dq_i;
   output        dq_oe;
   output        cke_pad_o;
`endif
`ifdef DDR_16
   output        ck_pad_o;
   output        ck_n_pad_o;
   output        cke_pad_o;
   output        ck_fb_pad_o;
   input         ck_fb_pad_i;
   output        cs_n_pad_o;
   output        ras_pad_o;
   output        cas_pad_o;
   output        we_pad_o;
   inout   [1:0] dm_rdqs_pad_io;
   output  [1:0] ba_pad_o;
   output [12:0] addr_pad_o;
   inout  [15:0] dq_pad_io;
   inout   [1:0] dqs_pad_io;
   output        dqs_oe;
   inout   [1:0] dqs_n_pad_io;
   input   [1:0] rdqs_n_pad_i;
   output        odt_pad_o;
`endif
    input        sdram_clk;

    wire [1:0] fifo_empty[0:15];
    wire [1:0] fifo_rd[0:15];
    wire [1:0] fifo_dat_o[35:0];
    wire [1:0] fifo_dat_i[31:0];
    wire [1:0] fifo_wr[0:15];

    wire [35:0] tx_fifo_dat_o;   // tmp added /MF
    
genvar i;

generate   
    if (nr_of_wb_clk_domains > 0) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk0))
        wb0(
            // wishbone side
            .wb_adr_i_v(wb_adr_i_0),
            .wb_dat_i_v(wb_dat_i_0),
            .wb_dat_o(wb_dat_o_0),
            .wb_stb_i(wb_stb_i_0),
            .wb_cyc_i(wb_cyc_i_0),
            .wb_ack_o(wb_ack_o_0),
            .wb_clk(wb_clk[0]),
            .wb_rst(wb_rst[0]),
            // SDRAM controller interface
            .sdram_dat_o(),
            .sdram_fifo_empty(fifo_empty[0][0:nr_of_wb_ports_clk0-1]),
            .sdram_fifo_rd(),
            .sdram_dat_i(),
            .sdram_fifo_wr(),
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
        wb0(
            // wishbone side
            .wb_adr_i_v(wb_adr_i_1),
            .wb_dat_i_v(wb_dat_i_1),
            .wb_dat_o(wb_dat_o_1),
            .wb_stb_i(wb_stb_i_1),
            .wb_cyc_i(wb_cyc_i_1),
            .wb_ack_o(wb_ack_o_1),
            .wb_clk(wb_clk[1]),
            .wb_rst(wb_rst[1]),
            // SDRAM controller interface
            .sdram_dat_o(),
            .sdram_fifo_empty(),
            .sdram_fifo_rd(),
            .sdram_dat_i(),
            .sdram_fifo_wr(),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk1 < 16) begin
            assign fifo_empty[1][nr_of_wb_ports_clk1:15] = {(16-nr_of_wb_ports_clk1){1'b1}};
        end
    end else begin
        assign fifo_empty[1] = {16{1'b1}};
    end
endgenerate

generate   
    if (nr_of_wb_clk_domains > 2) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk1))
        wb0(
            // wishbone side
            .wb_adr_i_v(wb_adr_i_2),
            .wb_dat_i_v(wb_dat_i_2),
            .wb_dat_o(wb_dat_o_2),
            .wb_stb_i(wb_stb_i_2),
            .wb_cyc_i(wb_cyc_i_2),
            .wb_ack_o(wb_ack_o_2),
            .wb_clk(wb_clk[2]),
            .wb_rst(wb_rst[2]),
            // SDRAM controller interface
            .sdram_dat_o(),
            .sdram_fifo_empty(),
            .sdram_fifo_rd(),
            .sdram_dat_i(),
            .sdram_fifo_wr(),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk2 < 16) begin
            assign fifo_empty[2][nr_of_wb_ports_clk2:15] = {(16-nr_of_wb_ports_clk2){1'b1}};
        end
    end else begin
        assign fifo_empty[2] = {16{1'b1}};
    end
endgenerate

generate   
    if (nr_of_wb_clk_domains > 3) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk3))
        wb0(
            // wishbone side
            .wb_adr_i_v(wb_adr_i_3),
            .wb_dat_i_v(wb_dat_i_3),
            .wb_dat_o(wb_dat_o_3),
            .wb_stb_i(wb_stb_i_3),
            .wb_cyc_i(wb_cyc_i_3),
            .wb_ack_o(wb_ack_o_3),
            .wb_clk(wb_clk[3]),
            .wb_rst(wb_rst[3]),
            // SDRAM controller interface
            .sdram_dat_o(),
            .sdram_fifo_empty(),
            .sdram_fifo_rd(),
            .sdram_dat_i(),
            .sdram_fifo_wr(),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk3 < 16) begin
            assign fifo_empty[3][nr_of_wb_ports_clk3:15] = {(16-nr_of_wb_ports_clk3){1'b1}};
        end
    end else begin
        assign fifo_empty[3] = {16{1'b1}};
    end
endgenerate

`ifdef SDR_16
   wire read;
   reg [15:0] dq_i_reg, dq_i_tmp_reg;   
   wire dq_hi, dq_lo;
   reg [15:0] dq;
      
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
      .dq_hi(dq_hi),
      .dq_lo(dq_lo),
      .dqm(dqm_pad_o),
      .dq_oe(dq_oe),
      .a({ba_pad_o,a_pad_o}),
      .cmd({ras_pad_o,cas_pad_o,we_pad_o}),
      .cs_n(cs_n_pad_o),
      .sdram_clk(sdram_clk_0),
      .wb_rst(wb_rst)
      );

   inc_adr inc_adr0
     (
      .adr_i(tx_fifo_dat_o[9:6]),
      .bte_i(tx_fifo_dat_o[4:3]),
      .cti_i(tx_fifo_dat_o[2:0]),
      .init(adr_init),
      .inc(adr_inc | rx_fifo_we),
      .adr_o(burst_adr),
      .done(done),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   assign sdram_clk_0 = sdram_clk;
   assign cke_pad_o = 1'b1;

   defparam delay0.depth=`CL+2;   
   defparam delay0.width=4;
   delay delay0
     (
      .d({read,tx_fifo_b_sel_i_cur}),
      .q({rx_fifo_we,rx_fifo_a_sel_i}),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   always @ (posedge sdram_clk_0 or posedge wb_rst)
     if (wb_rst)
       {dq_i_reg, dq_i_tmp_reg} <= {16'h0000,16'h0000};
     else
       {dq_i_reg, dq_i_tmp_reg} <= {dq_i, dq_i_reg};

   assign rx_fifo_dat_i = {dq_i_tmp_reg, dq_i_reg, 4'h0};

   always @ (posedge sdram_clk_0 or posedge wb_rst)
     if (wb_rst)
       dq <= 16'h0000;
     else
       if (dq_hi)
         dq <= tx_fifo_dat_o[35:20];
       else if (dq_lo)
         dq <= tx_fifo_dat_o[19:4];
       else
         dq <= 16'h0000;

   assign dq_o = dq;

`endif //  `ifdef SDR_16


`ifdef DDR_16
   wire        read, write;
   wire        sdram_clk_90, sdram_clk_180, sdram_clk_270;
   wire        ck_fb;
   reg         cke, ras, cas, we, cs_n;
   wire        ras_o, cas_o, we_o, cs_n_o;
   wire  [1:0] ba_o;
   wire [12:0] addr_o;
   reg   [1:0] ba;
   reg  [12:0] addr;
   wire        dq_en, dqm_en;
   reg  [15:0] dq_tx_reg;
   wire [15:0] dq_tx;
   reg  [31:0] dq_rx_reg;
   wire [31:0] dq_rx;
   wire [15:0] dq_o;
   reg   [3:0] dqm_tx_reg;
   wire  [3:0] dqm_tx;
   wire  [1:0] dqm_o, dqs_o, dqs_n_o;
   wire        ref_delay, ref_delay_ack;
   wire        bl_en, bl_ack;
   wire        tx_fifo_re_i;
   wire        adr_init_delay;
   reg         adr_init_delay_i;
   reg   [3:0] burst_cnt;
   wire  [3:0] burst_next_cnt, burst_length;
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
   defparam delay0.depth=`CL+`AL+2; 
   defparam delay0.width=4;
   delay delay0 (
      .d({read && !burst_mask,tx_fifo_b_sel_i_cur}),
      .q({rx_fifo_we,rx_fifo_a_sel_i}),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );
   
   // write latency, delay the control signals to fit latency of the DDR2 SDRAM
   defparam delay1.depth=`CL+`AL-1;
   defparam delay1.width=2;
   delay delay1 (
      .d({write, burst_mask}),
      .q({dq_en, dqm_en}),
      .clk(sdram_clk_270),
      .rst(wb_rst)
      );

   // if CL>3 delay read from Tx FIFO
   defparam delay2.depth=`CL+`AL-3;
   defparam delay2.width=1;
   delay delay2 (
      .d(tx_fifo_re_i && !burst_mask),
      .q(tx_fifo_re),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // if CL=3, no delay
   //assign tx_fifo_re = tx_fifo_re_i && !burst_mask;

   // Increment address
   defparam delay3.depth=`CL+`AL-1;
   defparam delay3.width=1;
   delay delay3 (
      .d({write|read}),
      .q({adr_inc}),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // DCM/PLL with internal and external feedback
   // Remove skew from internal and external clock
   // Parameters are set in dcm_pll.v
   dcm_pll dcm_pll_0 (
      .rst(wb_rst),
      .clk_in(sdram_clk),
      .clkfb_in(ck_fb_pad_i),
      .clk0_out(sdram_clk_0),
      .clk90_out(sdram_clk_90),
      .clk180_out(sdram_clk_180),
      .clk270_out(sdram_clk_270),
      .clkfb_out(ck_fb)
      );

   // Generate clock with equal delay as data
   ddr_ff_out ddr_ff_out_inst_2  (
      .Q(ck_pad_o),
      .C0(sdram_clk_0),
      .C1(sdram_clk_180),
      .CE(1'b1),
      .D0(1'b1),
      .D1(1'b0),
      .R(1'b0),   // no reset for CK
      .S(1'b0)
      );

   // Generate clock with equal delay as data
   ddr_ff_out ddr_ff_out_inst_3
     (
      .Q(ck_n_pad_o),
      .C0(sdram_clk_0),
      .C1(sdram_clk_180),
      .CE(1'b1),
      .D0(1'b0),
      .D1(1'b1),
      .R(wb_rst),
      .S(1'b0)
      );

   // Generate strobe with equal delay as data
   generate
   for (i=0; i<2; i=i+1) begin:dqs_oddr
   ddr_ff_out ddr_ff_out_inst_4  (
      .Q(dqs_o[i]),
      .C0(sdram_clk_0),
      .C1(sdram_clk_180),
      .CE(1'b1),
      .D0(1'b1),
      .D1(1'b0),
      .R(1'b0),   // no reset for CK
      .S(1'b0)
      );
   end
   endgenerate

   generate
   for (i=0; i<2; i=i+1) begin:dqs_n_oddr
   // Generate strobe with equal delay as data
   ddr_ff_out ddr_ff_out_inst_5
     (
      .Q(dqs_n_o[i]),
      .C0(sdram_clk_0),
      .C1(sdram_clk_180),
      .CE(1'b1),
      .D0(1'b0),
      .D1(1'b1),
      .R(wb_rst),
      .S(1'b0)
      );
   end
   endgenerate

`ifdef XILINX
   // Data and data mask from Tx FIFO
   always @ (posedge sdram_clk_270 or posedge wb_rst)
     if (wb_rst) begin
       dq_tx_reg[15:0] <= 16'h0;
       dqm_tx_reg[1:0] <= 2'b00;
       end
     else begin
       if (dqm_en) begin
         dq_tx_reg[15:0] <= tx_fifo_dat_o[19:4];
         dqm_tx_reg[1:0] <= 2'b00;
         end
       else begin
         dq_tx_reg[15:0] <= tx_fifo_dat_o[19:4];
         dqm_tx_reg[1:0] <= tx_fifo_dat_o[1:0];
       end
     end

   always @ (posedge sdram_clk_180 or posedge wb_rst)
     if (wb_rst) begin
       dqm_tx_reg[3:2]  <= 2'b00;
       end
     else begin
       if (dqm_en) begin
         dqm_tx_reg[3:2]  <= 2'b00;
         end
       else begin
         dqm_tx_reg[3:2]  <= tx_fifo_dat_o[3:2];
       end
     end

   assign dq_tx[15:0] = tx_fifo_dat_o[35:20];
   assign dqm_tx[1:0] = (dqm_en) ? 2'b00 : tx_fifo_dat_o[3:2];

   // Data out
   generate
   for (i=0; i<16; i=i+1) begin:data_out_oddr
      ddr_ff_out ddr_ff_out_inst_0 (
        .Q(dq_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(dq_tx[i]),
        .D1(dq_tx_reg[i]),
        .R(wb_rst),
        .S(1'b0)
        );
   end
   endgenerate

   assign dq_pad_io = dq_en ? dq_o : {16{1'bz}};

   // Data mask
   generate
   for (i=0; i<2; i=i+1) begin:data_mask_oddr
     ddr_ff_out ddr_ff_out_inst_1 (
        .Q(dqm_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(!dqm_tx[i]),
        .D1(!dqm_tx_reg[i]),
        .R(wb_rst),
        .S(1'b0)
        );
   end
   endgenerate

   assign dm_rdqs_pad_io = dq_en ? dqm_o : 2'bzz;
`endif   // XILINX   

`ifdef ALTERA
   // Data out
   generate
   for (i=0; i<16; i=i+1) begin:data_out_oddr
      ddr_ff_out ddr_ff_out_inst_0 (
        .Q(dq_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(tx_fifo_dat_o[i+16+4]),
        .D1(tx_fifo_dat_o[i+4]),
        .R(wb_rst),
        .S(1'b0)
        );
   end
   endgenerate

   assign dq_pad_io = dq_en ? dq_o : {16{1'bz}};

   assign dqm_tx = dqm_en ? {4{1'b0}} : tx_fifo_dat_o[3:0];

   // Data mask
   generate
   for (i=0; i<2; i=i+1) begin:data_mask_oddr
     ddr_ff_out ddr_ff_out_inst_1 (
        .Q(dqm_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(!dqm_tx[i+2]),
        .D1(!dqm_tx[i]),
        .R(wb_rst),
        .S(1'b0)
        );
   end
   endgenerate

   assign dm_rdqs_pad_io = dq_en ? dqm_o : 2'bzz;
`endif   // ALTERA

   // DDR data in
   generate
   for (i=0; i<16; i=i+1) begin:iddr2gen
     ddr_ff_in ddr_ff_in_inst_0 
       (
        .Q0(dq_rx[i]), 
        .Q1(dq_rx[i+16]), 
        .C0(sdram_clk_270), 
        .C1(sdram_clk_90),
        .CE(1'b1), 
        .D(dq_pad_io[i]),   
        .R(wb_rst),  
        .S(1'b0)
        );
   end
   endgenerate

   // Data to Rx FIFO
`ifdef XILINX
   always @ (posedge sdram_clk_0 or posedge wb_rst)
`endif
`ifdef ALTERA
   always @ (posedge sdram_clk_180 or posedge wb_rst)
`endif
     if (wb_rst)
       dq_rx_reg[31:16] <= 16'h0;
     else
       dq_rx_reg[31:16] <= dq_rx[31:16];

   always @ (posedge sdram_clk_180 or posedge wb_rst)
     if (wb_rst)
       dq_rx_reg[15:0] <= 16'h0;
     else
       dq_rx_reg[15:0] <= dq_rx[15:0];

   assign rx_fifo_dat_i = {dq_rx_reg, 4'h0};

   // Assing outputs
   assign dqs_pad_io   = dq_en ? dqs_o : 2'bz;
   assign dqs_n_pad_io = dq_en ? dqs_n_o : 2'bz;
   assign dqs_oe       = dq_en;
   assign ck_fb_pad_o  = ck_fb;

`endif //  `ifdef DDR_16
   
endmodule // wb_sdram_ctrl_top
