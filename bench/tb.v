`include "tb_defines.v"
`timescale 1ns/1ns
module versatile_mem_ctrl_tb
  (
   output OK
   );

   // number of wb clock domains
   parameter nr_of_wb_clk_domains = 1;
   // number of wb ports in each wb clock domain
   parameter nr_of_wb_ports_clk0  = 3;
   parameter nr_of_wb_ports_clk1  = 0;
   parameter nr_of_wb_ports_clk2  = 0;
   parameter nr_of_wb_ports_clk3  = 0;

   reg 	  sdram_clk, wb_clk, wb_rst;

   wire [31:0] wb0_dat_i;
   wire [3:0]  wb0_sel_i;
   wire [31:0] wb0_adr_i;
   wire [2:0]  wb0_cti_i;
   wire [1:0]  wb0_bte_i;
   wire        wb0_cyc_i;
   wire        wb0_stb_i;
   wire [31:0] wb0_dat_o;
   wire        wb0_ack_o;
   
   wire [31:0] wb1_dat_i;
   wire [3:0]  wb1_sel_i;
   wire [31:0] wb1_adr_i;
   wire [2:0]  wb1_cti_i;
   wire [1:0]  wb1_bte_i;
   wire        wb1_cyc_i;
   wire        wb1_stb_i;
   wire [31:0] wb1_dat_o;
   wire        wb1_ack_o;
   
   wire [31:0] wb4_dat_i;
   wire [3:0]  wb4_sel_i;
   wire [31:0] wb4_adr_i;
   wire [2:0]  wb4_cti_i;
   wire [1:0]  wb4_bte_i;
   wire        wb4_cyc_i;
   wire        wb4_stb_i;
   wire [31:0] wb4_dat_o;
   wire        wb4_ack_o;

   wire [1:0]  ba, bad;
   wire [12:0] a, ad;
   wire [15:0] dq_i;
   wire [15:0] dq_o;
   wire [15:0] dq_io;
   wire [1:0]  dqs, dqs_n, dqs_i, dqs_o, dqs_n_i, dqs_n_o, dqs_io, dqs_n_io;
   wire [1:0]  dqm, dqmd, dm_rdqs;
   wire        dq_oe, dqs_oe;
   wire        cs_n, cs_nd, ras, rasd, cas, casd, we, wed, cke, cked;
   wire        ck_fb_i, ck_fb_o;

   // 
   wire [36*nr_of_wb_ports_clk0-1:0] wb_dat_i_v;
   wire [36*nr_of_wb_ports_clk0-1:0] wb_adr_i_v;
   wire [31:0]                       wb_dat_o_v;
   wire [0:nr_of_wb_ports_clk0-1]    wb_cyc_i_v;
   wire [0:nr_of_wb_ports_clk0-1]    wb_stb_i_v;
   wire [0:nr_of_wb_ports_clk0-1]    wb_ack_o_v;
   // 
   assign wb_dat_i_v = {4'h0,wb4_dat_i,4'h0,wb1_dat_i,3'h0,wb0_dat_i};
   assign wb_adr_i_v = {4'h0,wb4_adr_i,4'h0,wb1_adr_i,3'h0,wb0_adr_i};
   assign wb_cyc_i_v = {wb4_cyc_i,wb1_cyc_i,wb0_cyc_i};
   assign wb_stb_i_v = {wb4_stb_i,wb1_stb_i,wb0_stb_i};
   assign wb_ack_o_v = {};

`ifdef SDR_16          // SDR SDRAM
   wb0 wb0i
     (
      .adr(wb0_adr_i),
      .bte(wb0_bte_i),
      .cti(wb0_cti_i),
      .cyc(wb0_cyc_i),
      .dat(wb0_dat_i),
      .sel(wb0_sel_i),
      .stb(wb0_stb_i),
      .we (wb0_we_i),
      .ack(wb0_ack_o),
      .clk(wb_clk),
      .dat_i(wb0_dat_o),
      .reset(wb_rst) 
      );
   wb1 wb1i
     (
      .adr(wb1_adr_i),
      .bte(wb1_bte_i),
      .cti(wb1_cti_i),
      .cyc(wb1_cyc_i),
      .dat(wb1_dat_i),
      .sel(wb1_sel_i),
      .stb(wb1_stb_i),
      .we (wb1_we_i),
      .ack(wb1_ack_o),
      .clk(wb_clk),
      .dat_i(wb1_dat_o),
      .reset(wb_rst) 
      );
   wb4 wb4i
     (
      .adr(wb4_adr_i),
      .bte(wb4_bte_i),
      .cti(wb4_cti_i),
      .cyc(wb4_cyc_i),
      .dat(wb4_dat_i),
      .sel(wb4_sel_i),
      .stb(wb4_stb_i),
      .we (wb4_we_i),
      .ack(wb4_ack_o),
      .clk(wb_clk),
      .dat_i(wb4_dat_o),
      .reset(wb_rst) 
      );
`endif

`ifdef DDR_16          // DDR2 SDRAM
   wb0_ddr wb0i
     (
      .adr(wb0_adr_i),
      .bte(wb0_bte_i),
      .cti(wb0_cti_i),
      .cyc(wb0_cyc_i),
      .dat(wb0_dat_i),
      .sel(wb0_sel_i),
      .stb(wb0_stb_i),
      .we (wb0_we_i),
      .ack(wb0_ack_o),
      .clk(wb_clk),
      .dat_i(wb0_dat_o),
      .reset(wb_rst) 
      );
   wb1_ddr wb1i
     (
      .adr(wb1_adr_i),
      .bte(wb1_bte_i),
      .cti(wb1_cti_i),
      .cyc(wb1_cyc_i),
      .dat(wb1_dat_i),
      .sel(wb1_sel_i),
      .stb(wb1_stb_i),
      .we (wb1_we_i),
      .ack(wb1_ack_o),
      .clk(wb_clk),
      .dat_i(wb1_dat_o),
      .reset(wb_rst) 
      );
   wb4_ddr wb4i
     (
      .adr(wb4_adr_i),
      .bte(wb4_bte_i),
      .cti(wb4_cti_i),
      .cyc(wb4_cyc_i),
      .dat(wb4_dat_i),
      .sel(wb4_sel_i),
      .stb(wb4_stb_i),
      .we (wb4_we_i),
      .ack(wb4_ack_o),
      .clk(wb_clk),
      .dat_i(wb4_dat_o),
      .reset(wb_rst) 
      );
`endif

  versatile_mem_ctrl_top dut (
    // wb clk0
    .wb_dat_i_0(wb_dat_i_v),	 
    .wb_dat_o_0(wb_dat_o_v),	 
    .wb_adr_i_0(wb_adr_i_v), 
    //.wb_sel_i_0(),	 
    //.wb_cti_i_0(),	 
    //.wb_bte_i_0(),	 
    //.wb_we_i_0(),
    .wb_cyc_i_0(wb_cyc_i_v),	 
    .wb_stb_i_0(wb_stb_i_v),       
    .wb_ack_o_0(wb_ack_o_v),
    // wb clk1
/*    .wb_dat_i_1(),	
    .wb_dat_o_1(),	
    .wb_adr_i_1(),
    .wb_sel_i_1(),	
    .wb_cti_i_1(),	
    .wb_bte_i_1(),	
    .wb_we_i_1(),	
    .wb_cyc_i_1(),	
    .wb_stb_i_1(),      
    .wb_ack_o_1(),   */
    // wb clk2 
/*    .wb_dat_i_2(),	
    .wb_dat_o_2(),	
    .wb_adr_i_2(),
    .wb_sel_i_2(),	
    .wb_cti_i_2(),	
    .wb_bte_i_2(),	
    .wb_we_i_2(),	
    .wb_cyc_i_2(),	
    .wb_stb_i_2(),      
    .wb_ack_o_2(),   */
    // wb clk3
/*    .wb_dat_i_3(),	
    .wb_dat_o_3(),	
    .wb_adr_i_3(),
    .wb_sel_i_3(),	
    .wb_cti_i_3(),	
    .wb_bte_i_3(),	
    .wb_we_i_3(),	
    .wb_cyc_i_3(),	
    .wb_stb_i_3(),      
    .wb_ack_o_3(),  */
    // SDR SDRAM 16
   `ifdef SDR_16
    .ba_pad_o(ba),
    .a_pad_o(a),
    .cs_n_pad_o(cs_n),
    .ras_pad_o(ras),
    .cas_pad_o(cas),
    .we_pad_o(we),
    .dq_o(dq_o),
    .dqm_pad_o(dqm),
    .dq_i(dq_i),
    .dq_oe(dq_oe),
    .cke_pad_o(cke),
    `endif
    `ifdef DDR_16
    // DDR2 SDRAM 16
    .ck_pad_o(ck),
    .ck_n_pad_o(ck_n),
    .cke_pad_o(cke),
    .ck_fb_pad_o(ck_fb_o),
    .ck_fb_pad_i(ck_fb_i),
    .cs_n_pad_o(cs_n),
    .ras_pad_o(ras),
    .cas_pad_o(cas),
    .we_pad_o(we),
    .dm_rdqs_pad_io(dm_rdqs),
    .ba_pad_o(ba),
    .addr_pad_o(a),
    .dq_pad_io(dq_io),
    .dqs_pad_io(dqs_io),
    .dqs_oe(dqs_oe),
    .dqs_n_pad_io(dqs_n_io),
    .rdqs_n_pad_i(),
    .odt_pad_o(),
    `endif
    // misc     
    .wb_clk(wb_clk),
    .wb_rst(wb_rst),
    .sdram_clk(sdram_clk)
    );

`ifdef SDR_16
   assign #1 dq_io = dq_oe ? dq_o : {16{1'bz}};
   assign #1 dq_i  = dq_io;
   assign #1 dqmd = dqm;
   assign #1 dqs_io = dqs_oe ? dqs_o : {2{1'bz}};
   assign #1 dqs_i  = dqs_io;
   assign #1 dqs_n_io = dqs_oe ? dqs_n_o : {2{1'bz}};
   assign #1 dqs_n_i  = dqs_n_io;
`endif

`ifdef DDR_16
   assign #1 dqmd = dqm;
   assign    ck_fb_i = ck_fb_o;
`endif

   assign #1 ad = a;
   assign #1 bad = ba;
   assign #1 cked = cke;
   assign #1 cs_nd = cs_n;
   assign #1 rasd = ras;
   assign #1 casd = cas;
   assign #1 wed = we;
   
`ifdef SDR_16          // SDR SDRAM Simulation model
mt48lc16m16a2 sdram
  (
   .Dq(dq_io), 
   .Addr(ad), 
   .Ba(bad), 
   .Clk(sdram_clk), 
   .Cke(cked), 
   .Cs_n(cs_nd), 
   .Ras_n(rasd), 
   .Cas_n(casd), 
   .We_n(wed), 
   .Dqm(dqmd)
   );
`endif
`ifdef DDR_16          // DDR2 SDRAM Simulation model
ddr2 ddr2_sdram
  (
   .ck(ck),
   .ck_n(ck_n),
   .cke(cke),
   .cs_n(cs_n),
   .ras_n(ras),
   .cas_n(cas),
   .we_n(we),
   .dm_rdqs(dm_rdqs),
   .ba(ba),
   .addr(a),
   .dq(dq_io),
   .dqs(dqs_io),
   .dqs_n(dqs_n_io),
   .rdqs_n(),
   .odt()
   );
`endif
   
   initial
     begin
	#0 wb_rst = 1'b1;
	#200 wb_rst = 1'b1;	
	#200000 wb_rst = 1'b0;	
     end
   
   initial
     begin
	#0 wb_clk = 1'b0;
	forever
	  #20 wb_clk = !wb_clk;   // 25MHz
     end
   
   initial
     begin
	#0 sdram_clk = 1'b0;
	forever
	  #4 sdram_clk = !sdram_clk;   // 125MHz
     end
   
endmodule // versatile_mem_ctrl_tb
