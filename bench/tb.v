//`include "tb_defines.v"
`timescale 1ns/1ns
module versatile_mem_ctrl_tb
  (
   output OK
   );

`ifdef NR_OF_WBM
	parameter nr_of_wbm = `NR_OF_WBM;
`else
	parameter nr_of_wbm = 1;
`endif

`ifdef SDRAM_CLK_PERIOD
	parameter sdram_clk_period = `SDRAM_CLK_PERIOD;
`else
	parameter sdram_clk_period = 8;
`endif

`ifdef WB_CLK_PERIODS
	parameter [1:nr_of_wbm] wb_clk_periods = {`WB_CLK_PERIODS};
`else
	parameter [1:nr_of_wbm] wb_clk_periods = (20);
`endif
	parameter wb_clk_period = 20;
	
   wire [31:0] wbm_a_dat_o [1:nr_of_wbm];
   wire [3:0]  wbm_a_sel_o [1:nr_of_wbm];
   wire [31:0] wbm_a_adr_o [1:nr_of_wbm];
   wire [2:0]  wbm_a_cti_o [1:nr_of_wbm];
   wire [1:0]  wbm_a_bte_o [1:nr_of_wbm];
   wire        wbm_a_we_o  [1:nr_of_wbm];
   wire        wbm_a_cyc_o [1:nr_of_wbm];
   wire        wbm_a_stb_o [1:nr_of_wbm];
   wire [31:0] wbm_a_dat_i [1:nr_of_wbm];
   wire        wbm_a_ack_i [1:nr_of_wbm];
   reg         wbm_a_clk   [1:nr_of_wbm];
   reg         wbm_a_rst   [1:nr_of_wbm];

   wire [31:0] wbm_b_dat_o [1:nr_of_wbm];
   wire [3:0]  wbm_b_sel_o [1:nr_of_wbm];
   wire [31:2] wbm_b_adr_o [1:nr_of_wbm];
   wire [2:0]  wbm_b_cti_o [1:nr_of_wbm];
   wire [1:0]  wbm_b_bte_o [1:nr_of_wbm];
   wire        wbm_b_we_o  [1:nr_of_wbm];
   wire        wbm_b_cyc_o [1:nr_of_wbm];
   wire        wbm_b_stb_o [1:nr_of_wbm];
   wire [31:0] wbm_b_dat_i [1:nr_of_wbm];
   wire        wbm_b_ack_i [1:nr_of_wbm];

   wire [31:0] wb_sdram_dat_i;
   wire [3:0]  wb_sdram_sel_i;
   wire [31:2] wb_sdram_adr_i;
   wire [2:0]  wb_sdram_cti_i;
   wire [1:0]  wb_sdram_bte_i;
   wire        wb_sdram_we_i;
   wire        wb_sdram_cyc_i;
   wire        wb_sdram_stb_i;
   wire [31:0] wb_sdram_dat_o;
   wire        wb_sdram_ack_o;
   reg         wb_sdram_clk;
   reg         wb_sdram_rst;
                             
	wire [1:nr_of_wbm] wbm_OK;
	
	genvar i;
              
`define DUT sdr_sdram_16_ctrl
`define SDR 16
`ifdef SDR
	wire [1:0]  ba, ba_pad;
   	wire [12:0] a, a_pad;
   	wire [`SDR-1:0] dq_i, dq_o, dq_pad;
   	wire        dq_oe;
   	wire [1:0]  dqm, dqm_pad;
   	wire        cke, cke_pad, cs_n, cs_n_pad, ras, ras_pad, cas, cas_pad, we, we_pad;
    
	assign #1 {ba_pad,a_pad} = {ba,a};
	assign #1 {ras_pad, cas_pad, we_pad} = {ras,cas,we};
	assign #1 dqm_pad = dqm;
	assign #1 cke_pad = cke;
	assign cs_n_pad = cs_n;
	
	mt48lc16m16a2 mem(
	 	.Dq(dq_pad), 
	 	.Addr(a_pad), 
	 	.Ba(ba_pad), 
	 	.Clk(wb_sdram_clk), 
	 	.Cke(cke_pad), 
	 	.Cs_n(cs_n_pad), 
	 	.Ras_n(ras_pad), 
	 	.Cas_n(cas_pad), 
	 	.We_n(we_pad), 
	 	.Dqm(dqm_pad));
	 	
	 	assign #1 dq_pad = (dq_oe) ? dq_o : {`SDR{1'bz}};
	 	assign #1 dq_i = dq_pad;
	 		 	
	`DUT DUT(
	// wisbone i/f
	.dat_i(wb_sdram_dat_i), 
	.adr_i({wb_sdram_adr_i[24:2],1'b0}), 
	.sel_i(wb_sdram_sel_i),
        .cti_i(wb_sdram_cti_i),
	.bte_i(wb_sdram_bte_i), 
	.we_i (wb_sdram_we_i), 
	.cyc_i(wb_sdram_cyc_i), 
	.stb_i(wb_sdram_stb_i), 
	.dat_o(wb_sdram_dat_o), 
	.ack_o(wb_sdram_ack_o),
	// SDR SDRAM
	.ba(ba), 
	.a(a), 
	.cmd({ras, cas, we}),
	.cke(cke),
	.cs_n(cs_n), 
	.dqm(dqm), 
	.dq_i(dq_i), 
	.dq_o(dq_o), 
	.dq_oe(dq_oe),
	// system
	.clk(wb_sdram_clk), .rst(wb_sdram_rst));
	 	
`endif        

// wishbone master(s)
generate
	for (i=1; i <= nr_of_wbm; i=i+1) begin: wb_master
		
		wbm wbmi(
		.adr_o(wbm_a_adr_o[i]),
		.bte_o(wbm_a_bte_o[i]),
		.cti_o(wbm_a_cti_o[i]),
		.dat_o(wbm_a_dat_o[i]),
		.sel_o(wbm_a_sel_o[i]),
		.we_o (wbm_a_we_o[i]),
		.cyc_o(wbm_a_cyc_o[i]),
		.stb_o(wbm_a_stb_o[i]),
		.dat_i(wbm_a_dat_i[i]),
		.ack_i(wbm_a_ack_i[i]),
		.clk(wbm_a_clk[i]),
		.reset(wbm_a_rst[i]),
		.OK(wbm_OK[i])
);

	wb3wb3_bridge wbwb_bridgei (
	// wishbone slave side
	.wbs_dat_i(wbm_a_dat_o[i]), 
	.wbs_adr_i(wbm_a_adr_o[i][31:2]), 
	.wbs_sel_i(wbm_a_sel_o[i]), 
	.wbs_bte_i(wbm_a_bte_o[i]), 
	.wbs_cti_i(wbm_a_cti_o[i]), 
	.wbs_we_i (wbm_a_we_o[i]), 
	.wbs_cyc_i(wbm_a_cyc_o[i]), 
	.wbs_stb_i(wbm_a_stb_o[i]), 
	.wbs_dat_o(wbm_a_dat_i[i]), 
	.wbs_ack_o(wbm_a_ack_i[i]), 
	.wbs_clk(wbm_a_clk[i]), 
	.wbs_rst(wbm_a_rst[i]),
	// wishbone master side
	.wbm_dat_o(wbm_b_dat_o[i]), 
	.wbm_adr_o(wbm_b_adr_o[i]), 
	.wbm_sel_o(wbm_b_sel_o[i]), 
	.wbm_bte_o(wbm_b_bte_o[i]), 
	.wbm_cti_o(wbm_b_cti_o[i]), 
	.wbm_we_o (wbm_b_we_o[i]), 
	.wbm_cyc_o(wbm_b_cyc_o[i]), 
	.wbm_stb_o(wbm_b_stb_o[i]), 
	.wbm_dat_i(wbm_b_dat_i[i]), 
	.wbm_ack_i(wbm_b_ack_i[i]), 
	.wbm_clk(wb_sdram_clk), 
	.wbm_rst(wb_sdram_rst));
		
    end
endgenerate

`define SINGLE_WB
`ifdef SINGLE_WB
	assign wb_sdram_dat_i=wbm_b_dat_o[1];
	assign wb_sdram_sel_i=wbm_b_sel_o[1];
	assign wb_sdram_adr_i=wbm_b_adr_o[1];
	assign wb_sdram_we_i =wbm_b_we_o[1];
	assign wb_sdram_bte_i=wbm_b_bte_o[1];
	assign wb_sdram_cti_i=wbm_b_cti_o[1];
	assign wb_sdram_cyc_i=wbm_b_cyc_o[1];
	assign wb_sdram_stb_i=wbm_b_stb_o[1];
	assign wbm_b_dat_i[1]=wb_sdram_dat_o;
	assign wbm_b_ack_i[1]=wb_sdram_ack_o;
`endif

	assign OK = &wbm_OK;
	

generate 
	for (i=1; i <= nr_of_wbm; i=i+1) begin: wb_reset

   		// Wishbone reset
   		initial
     	begin
		#0      wbm_a_rst[i] = 1'b1;
		#200    wbm_a_rst[i] = 1'b0;	
     	end

   		// Wishbone clock
   		initial
     	begin
		#0 wbm_a_clk[i] = 1'b0;
		forever
	  		#(wb_clk_period/2) wbm_a_clk[i] = !wbm_a_clk[i];
     	end


     end
endgenerate

   // SDRAM reset
   initial
     begin
	#0      wb_sdram_rst = 1'b1;
	#200    wb_sdram_rst = 1'b0;	
     end
   
   // SDRAM clock
   initial
     begin
	#0 wb_sdram_clk = 1'b0;
	forever
	  #(sdram_clk_period/2) wb_sdram_clk = !wb_sdram_clk;
     end
   
endmodule // versatile_mem_ctrl_tb
