module versatile_mem_ctrl_ddr (
  // DDR2 SDRAM side
  ck_o, ck_n_o, 
  dq_io, dqs_io, dqs_n_io, 
  dm_rdqs_io,
  //rdqs_n_i, odt_o, 
  // Memory controller side
  tx_dat_i, rx_dat_o,
  dq_en, dqm_en,
  wb_rst, sdram_clk_0, sdram_clk_90, sdram_clk_180, sdram_clk_270
  );

  output        ck_o;
  output        ck_n_o;
  inout  [15:0] dq_io;
  inout   [1:0] dqs_io;
  inout   [1:0] dqs_n_io;
  inout   [1:0] dm_rdqs_io;
  //input   [1:0] rdqs_n_i;
  //output        odt_o;
  input  [35:0] tx_dat_i;
  output [35:0] rx_dat_o;
  input         dq_en;
  input         dqm_en;
  input         wb_rst;
  input         sdram_clk_0;
  input         sdram_clk_90;
  input         sdram_clk_180;
  input         sdram_clk_270;

  reg    [31:0] dq_rx_reg;
  wire   [31:0] dq_rx;
  wire    [1:0] dqs_o, dqs_n_o, dqm_o;
  wire   [15:0] dq_o;
  wire    [1:0] dqs_delayed;
  wire    [1:0] dqs_n_delayed;

  genvar        i;

  // Generate clock with equal delay as data
  ddr_ff_out ddr_ff_out_ck (
    .Q(ck_o),
    .C0(sdram_clk_0),
    .C1(sdram_clk_180),
    .CE(1'b1),
    .D0(1'b1),
    .D1(1'b0),
    .R(1'b0),
    .S(1'b0));

  ddr_ff_out ddr_ff_out_ck_n (
    .Q(ck_n_o),
    .C0(sdram_clk_0),
    .C1(sdram_clk_180),
    .CE(1'b1),
    .D0(1'b0),
    .D1(1'b1),
    .R(wb_rst),
    .S(1'b0));

  // Generate strobe with equal delay as data
  generate
    for (i=0; i<2; i=i+1) begin:dqs_oddr
      ddr_ff_out ddr_ff_out_dqs (
        .Q(dqs_o[i]),
        .C0(sdram_clk_0),
        .C1(sdram_clk_180),
        .CE(1'b1),
        .D0(1'b1),
        .D1(1'b0),
        .R(1'b0),
        .S(1'b0));
    end
  endgenerate

  generate
    for (i=0; i<2; i=i+1) begin:dqs_n_oddr
      ddr_ff_out ddr_ff_out_dqs_n (
        .Q(dqs_n_o[i]),
        .C0(sdram_clk_0),
        .C1(sdram_clk_180),
        .CE(1'b1),
        .D0(1'b0),
        .D1(1'b1),
        .R(wb_rst),
        .S(1'b0));
    end
  endgenerate

  // Assign outports
  assign dqs_io   = dq_en ? dqs_o : 2'bz;
  assign dqs_n_io = dq_en ? dqs_n_o : 2'bz;


`ifdef XILINX   

  reg  [15:0] dq_tx_reg;
  wire [15:0] dq_tx;
  reg   [3:0] dqm_tx_reg;
  wire  [3:0] dqm_tx;

  // Data out
  // Data from Tx FIFO
  always @ (posedge sdram_clk_270 or posedge wb_rst)
    if (wb_rst)
      dq_tx_reg[15:0] <= 16'h0;
    else
      if (dqm_en)
        dq_tx_reg[15:0] <= tx_dat_i[19:4];
      else
        dq_tx_reg[15:0] <= tx_dat_i[19:4];

  assign dq_tx[15:0] = tx_dat_i[35:20];

  // DDR flip-flops
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
        .S(1'b0));
    end
  endgenerate

  // Assign outports
  assign dq_io = dq_en ? dq_o : {16{1'bz}};

  // Data mask
  // Data mask from Tx FIFO
  always @ (posedge sdram_clk_270 or posedge wb_rst)
    if (wb_rst)
      dqm_tx_reg[1:0] <= 2'b00;
    else
      if (dqm_en)
        dqm_tx_reg[1:0] <= 2'b00;
      else
        dqm_tx_reg[1:0] <= tx_dat_i[1:0];

  always @ (posedge sdram_clk_180 or posedge wb_rst)
    if (wb_rst)
      dqm_tx_reg[3:2]  <= 2'b00;
    else
      if (dqm_en)
        dqm_tx_reg[3:2]  <= 2'b00;
      else
        dqm_tx_reg[3:2]  <= tx_dat_i[3:2];

  assign dqm_tx[1:0] = (dqm_en) ? 2'b00 : tx_dat_i[3:2];

  // DDR flip-flops
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
        .S(1'b0));
    end
  endgenerate

  // Assign outport
  assign dm_rdqs_io = dq_en ? dqm_o : 2'bzz;
    
  // Data in
  `ifdef INT_CLOCKED_DATA_CAPTURE
  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:iddr2gen
      ddr_ff_in ddr_ff_in_inst_0 (
        .Q0(dq_rx[i]), 
        .Q1(dq_rx[i+16]), 
        .C0(sdram_clk_270), 
        .C1(sdram_clk_90),
        .CE(1'b1), 
        .D(dq_io[i]),   
        .R(wb_rst),  
        .S(1'b0));
    end
  endgenerate

  // Data to Rx FIFO
  always @ (posedge sdram_clk_0 or posedge wb_rst)
    if (wb_rst)
      dq_rx_reg[31:16] <= 16'h0;
    else
      dq_rx_reg[31:16] <= dq_rx[31:16];

  always @ (posedge sdram_clk_180 or posedge wb_rst)
    if (wb_rst)
      dq_rx_reg[15:0] <= 16'h0;
    else
      dq_rx_reg[15:0] <= dq_rx[15:0];

  assign rx_dat_o = {dq_rx_reg, 4'h0};
  `endif   // INT_CLOCKED_DATA_CAPTURE

  `ifdef DEL_DQS_DATA_CAPTURE_1
   // Delay DQS
   // DDR FF
  `endif   // DEL_DQS_DATA_CAPTURE_1

  `ifdef DEL_DQS_DATA_CAPTURE_2
   // DDR data to IOBUF
   // Delay data (?)
   // IDDR FF
   // Rise & fall clocked FF
   // Fall sync FF
   // Mux
   // DDR DQS to IODUFDS
   // Delay DQS
   // BUFIO (?)
  `endif   // DEL_DQS_DATA_CAPTURE_2

`endif   // XILINX

`ifdef ALTERA

  wire  [3:0] dqm_tx;

  // Data out
  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:data_out_oddr
      ddr_ff_out ddr_ff_out_inst_0 (
        .Q(dq_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(tx_dat_i[i+16+4]),
        .D1(tx_dat_i[i+4]),
        .R(wb_rst),
        .S(1'b0));
    end
  endgenerate

  // Assign outport
  assign dq_io = dq_en ? dq_o : {16{1'bz}};

  // Data mask
  // Data mask from Tx FIFO
  assign dqm_tx = dqm_en ? {4{1'b0}} : tx_dat_i[3:0];

  // DDR flip-flops
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
        .S(1'b0));
    end
  endgenerate

  // Assign outport
  assign dm_rdqs_io = dq_en ? dqm_o : 2'bzz;


  // Data in
  `ifdef INT_CLOCKED_DATA_CAPTURE
  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:iddr2gen
      ddr_ff_in ddr_ff_in_inst_0 (
        .Q0(dq_rx[i]), 
        .Q1(dq_rx[i+16]), 
        .C0(sdram_clk_270), 
        .C1(sdram_clk_90),
        .CE(1'b1), 
        .D(dq_io[i]),   
        .R(wb_rst),  
        .S(1'b0));
    end
  endgenerate

  // Data to Rx FIFO
  always @ (posedge sdram_clk_180 or posedge wb_rst)
    if (wb_rst)
      dq_rx_reg <= 32'h0;
    else
      dq_rx_reg <= dq_rx;

  assign rx_dat_o = {dq_rx_reg, 4'h0};
  `endif   // INT_CLOCKED_DATA_CAPTURE

  `ifdef DEL_DQS_DATA_CAPTURE_1
   // Delay DQS
   // DDR FF
  `endif   // DEL_DQS_DATA_CAPTURE_1

  `ifdef DEL_DQS_DATA_CAPTURE_2
   // DDR data to IOBUFFER
   // Delay data (?)
   // DDR FF
   // Rise & fall clocked FF
   // Fall sync FF
   // Mux
   // DDR DQS to IODUFDS
   // Delay DQS
   // BUFIO (?)
  `endif   // DEL_DQS_DATA_CAPTURE_2

`endif   // ALTERA


endmodule   // versatile_mem_ctrl_ddr


