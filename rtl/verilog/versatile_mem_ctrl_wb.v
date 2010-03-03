module versatile_mem_ctrl_wb (
    // wishbone side
    wb_adr_i, wb_dat_i, wb_dat_o,
    wb_stb_i, wb_cyc_i, wb_ack_o,
    wb_clk, wb_rst,
    // SDRAM controller interface
    sdram_dat_o, sdram_fifo_empty, sdram_fifo_rd,
    sdram_dat_i, sdram_fifo_wr,
    sdram_clk, sdram_rst

);

parameter nr_of_wb_ports = 3;
    
input  [0:nr_of_wb_ports-1] wb_adr_i[35:0];
input  [0:nr_of_wb_ports-1] wb_dat_i[35:0];
input  [0:nr_of_wb_ports-1] wb_stb_i;
input  [0:nr_of_wb_ports-1] wb_cyc_i;
output [0:nr_of_wb_ports-1] wb_dat_o[31:0];
output [0:nr_of_wb_ports-1] wb_ack_o;
input                       wb_clk;
input                       wb_rst;

output [0:nr_of_wb_ports-1] sdram_dat_o[35:0];
output [0:nr_of_wb_ports-1] sdram_fifo_empty;
input  [0:nr_of_wb_ports-1] sdram_fifo_rd;
input  [0:nr_of_wb_ports-1] sdram_dat_i[31:0];
input  [0:nr_of_wb_ports-1] sdram_fifo_wr;
input                       sdram_clk;
input                       sdram_rst;

parameter linear_burst = 2'b00;
parameter wrap4        = 2'b01;
parameter wrap8        = 2'b10;
parameter wrap16       = 2'b11;
parameter classic      = 3'b000;
parameter endofburst   = 3'b111;

`define CTI_I 2:0
`define BTE_I 4:3
`define WE_I  5

parameter idle = 2'b00;
parameter rd   = 2'b01;
parameter wr   = 2'b10;
reg [0:nr_of_wb_ports-1] wb_state[1:0];

wire [0:nr_of_wb_ports-1] wb_wr_ack, wb_rd_ack;

reg  [35:0]               egress_fifo_di, egress_fifo_di_tmp;
reg  [7:0]                egress_fifo_ai, egress_fifo_ai_tmp; 
wire [0:nr_of_wb_ports-1] egress_fifo_wadr_bin[3:0];
wire [0:nr_of_wb_ports-1] egress_fifo_wadr_gray[3:0];
wire [0:nr_of_wb_ports-1] egress_fifo_radr_bin[3:0];
wire [0:nr_of_wb_ports-1] egress_fifo_radr_gray[3:0];
wire [0:nr_of_wb_ports-1] egress_fifo_full;
wire [0:nr_of_wb_ports-1] ingress_fifo_wadr_bin[3:0];
wire [0:nr_of_wb_ports-1] ingress_fifo_wadr_gray[3:0];
wire [0:nr_of_wb_ports-1] ingress_fifo_radr_bin[3:0];
wire [0:nr_of_wb_ports-1] ingress_fifo_radr_gray[3:0];
wire [0:nr_of_wb_ports-1] ingress_fifo_empty;

function [3:0] onehot2bin;
input [0:nr_of_wb_ports-1] a;
integer i;
begin
    onehot2bin = 0;
    for (i=1;i<nr_of_wb_ports;i=i+1) begin
        if (a[i])
            onehot2bin <= i;
    end
end
endfunction

genvar i;

// wr_ack
generate
    assign wb_wr_ack[0] = ((wb_state[0]==idle | wb_state[0]==wr) & wb_cyc_i[0] & wb_stb_i[0] & !egress_fifo_full[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin
        assign wb_wr_ack[i] = (|(wb_wr_ack[1:i-1])) ? 1'b0 : ((wb_state[i]==idle | wb_state[i]==wr) & wb_cyc_i[i] & wb_stb_i[i] & !egress_fifo_full[i]);
    end
endgenerate

// rd_ack
generate
    assign wb_rd_ack[0] = ((wb_state[0]==rd) & wb_cyc_i[0] & wb_stb_i[0] & !ingress_fifo_empty[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin
        assign wb_rd_ack[i] = (|(wb_rd_ack[1:i-1])) ? 1'b0 : ((wb_state[i]==rd) & wb_cyc_i[i] & wb_stb_i[i] & !ingress_fifo_empty[i]);
    end
endgenerate

// trafic state machines
generate
    for (i=1;i<=nr_of_wb_ports;i=i+1) begin
        always @ (posedge wb_clk or posedge wb_rst)
        if (wb_rst)
            wb_state[i] <= idle;
        else
            case (wb_state[i])
            idle:
                if (wb_wr_ack[i] & wb_adr_i[i][`WE_I])
                    wb_state[i] <= wr;
                else if (wb_wr_ack[i])
                    wb_state[i] <= rd;
            rd:
                if ((wb_adr_i[`CTI_I]==classic | wb_adr_i[`CTI_I]==endofburst) & wb_ack_o[i])
                    wb_state[i] <= idle;
            wr:
                if ((wb_adr_i[`CTI_I]==classic | wb_adr_i[`CTI_I]==endofburst) & wb_ack_o[i])
                    wb_state[i] <= idle;
            default: null;
            endcase
    end
endgenerate

generate
    for (i=1;i<=nr_of_wb_ports;i=i+1) begin
        always @ (posedge wb_clk or posedge wb_rst)
        if (wb_rst)
            wb_ack_o[i] <= 1'b0;
        else
            case (wb_state[i])
            idle:
                wb_ack_o[i] <= 1'b0;
            wr:
                wb_ack_o[i] <= wb_wr_ack[i];
            rd:
                wb_ack_o[i] <= wb_rd_ack[i];
            default: null;
            endcase
    end
endgenerate

generate
    for (i=1;i<=nr_of_wb_ports;i=i+1) begin
    
        // egress queue
        fifo_adr_counter egress_wadrcnt (
            .cke(wb_wr_ack[i]),
            .q(egress_fifo_wadr_gray[i]),
            .q_bin(egress_fifo_wadr_bin[i]),
            .rst(wb_rst),
            .clk(wb_clk));
        
        fifo_adr_counter egress_radrcnt (
            .cke(sdram_fifo_rd[i]),
            .q(egress_fifo_radr_gray[i]),
            .q_bin(egress_fifo_radr_bin[i]),
            .rst(sdram_rst),
            .clk(sdram_clk));
        
	versatile_fifo_async_cmp
            #(.ADDR_WIDTH(4))
            egresscmp ( 
                .wptr(egress_fifo_wadr_gray[i]), 
		.rptr(egress_fifo_radr_gray[i]), 
		.fifo_empty(), 
		.fifo_full(egress_fifo_full[i]), 
		.wclk(wb_clk), 
		.rclk(sdram_clk), 
		.rst(wb_rst));
                
        // ingress queue
        fifo_adr_counter ingress_wadrcnt (
            .cke(sdram_fifo_wr[i]),
            .q(ingress_fifo_wadr_gray[i]),
            .q_bin(ingress_fifo_wadr_bin[i]),
            .rst(wb_rst),
            .clk(wb_clk));
        
        fifo_adr_counter ingress_radrcnt (
            .cke(wb_rd_ack[i]),
            .q(ingress_fifo_wadr_gray[i]),
            .q_bin(ingress_fifo_wadr_bin[i]),
            .rst(wb_rst),
            .clk(wb_clk));
        
	versatile_fifo_async_cmp
            #(.ADDR_WIDTH(4))
            ingresscmp ( 
                .wptr(ingress_fifo_wadr_gray[i]), 
		.rptr(ingress_fifo_radr_gray[i]), 
		.fifo_empty(ingress_fifo_empty[i]), 
		.fifo_full(), 
		.wclk(wb_clk), 
		.rclk(sdram_clk), 
		.rst(wb_rst));
        
    end    
endgenerate
    
vfifo_dual_port_ram_dc_sw # ( .DATA_WIDTH(36), .ADDR_WIDTH(8))
    egress_dpram (
    .d_a(wb_dat_i[onehot2bin(wb_wr_ack)]),
    .adr_a({onehot2bin(wb_wr_ack),egress_fifo_wadr_bin[onehot2bin(wb_wr_ack)]}), 
    .we_a(|(wr_ack)),
    .clk_a(wb_clk),
    .q_b(sdram_dat_o),
    .adr_b(egress_fifo_radr_bin),
    .clk_b(sdram_clk) );

vfifo_dual_port_ram_dc_sw # ( .DATA_WIDTH(32), .ADDR_WIDTH(8))
    ingress_dpram (
    .d_a(egress_fifo_di),
    .adr_a(egress_fifo_wadr_bin[i]), 
    .we_a(|(wr_ack)),
    .clk_a(wb_clk),
    .q_b(sdram_dat_o),
    .adr_b(egress_fifo_radr_bin),
    .clk_b(sdram_clk) );
   















  generate

      for (i = 0; i < 8; i = i + 1) begin : fifocntr
	 if (i < nr_of_queues)
	   begin
	      fifo_adr_counter wptr_cnt
		(
		 .q(`WB_WPTR),
		 .q_bin(`WB_WADR),
		 .cke(wb_we_i & (wb_wrfifo_sel_i==i)),
		 .clk(wb_clk),
		 .rst(wb_rst)
		 );

	      fifo_adr_counter rptr_cnt
		(
		 .q(`MEM_RPTR),
		 .q_bin(`MEM_RADR),
		 .cke(mem_re_i & (mem_rdfifo_sel_i==i)),
		 .clk(mem_clk),
		 .rst(mem_rst)
		 );

	      versatile_fifo_async_cmp
		#(.ADDR_WIDTH(5))
	      cmp
		( 
		  .wptr(`WB_WPTR), 
		  .rptr(`MEM_RPTR), 
		  .fifo_empty(mem_fifo_empty_o[i]), 
		  .fifo_full(wb_fifo_full_o[i]), 
		  .wclk(wb_clk), 
		  .rclk(mem_clk), 
		  .rst(wb_rst)
		  );
	   end
	 else
	   begin
	      assign `WB_WADR = 5'h0;
	      assign `WB_WPTR = 5'h0;
	      assign `WB_RADR = 5'h0;
	      assign `WB_WPTR = 5'h0;	      
	   end
	 
      end      
   endgenerate

assign dpram1_wb  
  = 
    {wb_wrfifo_sel_i,
     {wb_wadr4[wb_wrfifo_sel_i],
      wb_wadr3[wb_wrfifo_sel_i],
      wb_wadr2[wb_wrfifo_sel_i],
      wb_wadr1[wb_wrfifo_sel_i],
      wb_wadr0[wb_wrfifo_sel_i]}};

assign dpram1_mem 
  = 
    {mem_rdfifo_sel_i,
     {mem_radr4[mem_rdfifo_sel_i], 
      mem_radr3[mem_rdfifo_sel_i], 
      mem_radr2[mem_rdfifo_sel_i], 
      mem_radr1[mem_rdfifo_sel_i], 
      mem_radr0[mem_rdfifo_sel_i]}};

assign dpram2_wb  
  = 
    {wb_rdfifo_sel_i,
     {wb_radr4[wb_rdfifo_sel_i], 
      wb_radr3[wb_rdfifo_sel_i], 
      wb_radr2[wb_rdfifo_sel_i], 
      wb_radr1[wb_rdfifo_sel_i], 
      wb_radr0[wb_rdfifo_sel_i]}};

assign dpram2_mem 
  = 
    {mem_wrfifo_sel_i,
     {mem_wadr4[mem_wrfifo_sel_i], 
      mem_wadr3[mem_wrfifo_sel_i], 
      mem_wadr2[mem_wrfifo_sel_i], 
      mem_wadr1[mem_wrfifo_sel_i], 
      mem_wadr0[mem_wrfifo_sel_i]}};
      
`ifdef ACTEL
   TwoPortRAM_256x36 dpram
     (
      .WD(a_dat_i),
      .RD(b_dat_o),
      .WEN(a_we_i),
      //.REN(b_re_i),
      .REN(1'b1),
      .WADDR(dpram_a_a),
      .RADDR(dpram_a_b),
      .WCLK(a_clk),
      .RCLK(b_clk)
      );   
`else		        
   vfifo_dual_port_ram_dc_dw
/*     #
     (
      .ADDR_WIDTH(8),
      .DATA_WIDTH(36)
      )*/
     dpram1
     (
      .d_a(wb_dat_i),
      .q_a(),
      .adr_a(dpram1_wb), 
      .we_a(wb_we_i),
      .clk_a(wb_clk),
      .q_b(mem_dat_o),
      .adr_b(dpram1_mem),
      .d_b(36'h0), 
      .we_b(1'b0),
      .clk_b(mem_clk)
      );
   vfifo_dual_port_ram_dc_dw
/*     #
     (
      .ADDR_WIDTH(8),
      .DATA_WIDTH(36)
      )*/
     dpram2
     (
      .d_a(36'h0),
      .q_a(wb_dat_o),
      .adr_a(dpram2_wb), 
      .we_a(1'b0),
      .clk_a(wb_clk),
      .q_b(),
      .adr_b(dpram2_mem),
      .d_b(mem_dat_i), 
      .we_b(mem_we_i),
      .clk_b(mem_clk)
      );
`endif
endmodule