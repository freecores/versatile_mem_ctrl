module versatile_mem_ctrl_ddr (
  // DDR2 SDRAM side
  ck_o, ck_n_o, 
  dq_io, dqs_io, dqs_n_io, 
  dm_rdqs_io,
  //rdqs_n_i, odt_o, 
  // Memory controller side
  tx_dat_i, rx_dat_o,
  dq_en, dqm_en,
  rst, clk_0, clk_90, clk_180, clk_270
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
  output [31:0] rx_dat_o;
  input         dq_en;
  input         dqm_en;
  input         rst;
  input         clk_0;
  input         clk_90;
  input         clk_180;
  input         clk_270;

  reg    [31:0] dq_rx_reg;
  wire   [31:0] dq_rx;
  wire    [1:0] dqs_o, dqs_n_o, dqm_o;
  wire   [15:0] dq_o;
  wire    [1:0] dqs_delayed, dqs_n_delayed;

  wire   [15:0] dq_iobuf;
  wire    [1:0] dqs_iobuf, dqs_n_iobuf;

  genvar        i;

///////////////////////////////////////////////////////////////////////////////
// Common for both Xilinx and Altera
///////////////////////////////////////////////////////////////////////////////

  // Generate clock with equal delay as data
  ddr_ff_out ddr_ff_out_ck (
    .Q(ck_o),
    .C0(clk_0),
    .C1(clk_180),
    .CE(1'b1),
    .D0(1'b1),
    .D1(1'b0),
    .R(1'b0),
    .S(1'b0));

  ddr_ff_out ddr_ff_out_ck_n (
    .Q(ck_n_o),
    .C0(clk_0),
    .C1(clk_180),
    .CE(1'b1),
    .D0(1'b0),
    .D1(1'b1),
    .R(rst),
    .S(1'b0));

  // Generate strobe with equal delay as data
  generate
    for (i=0; i<2; i=i+1) begin:dqs_oddr
      ddr_ff_out ddr_ff_out_dqs (
        .Q(dqs_o[i]),
        .C0(clk_0),
        .C1(clk_180),
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
        .C0(clk_0),
        .C1(clk_180),
        .CE(1'b1),
        .D0(1'b0),
        .D1(1'b1),
        .R(rst),
        .S(1'b0));
    end
  endgenerate



///////////////////////////////////////////////////////////////////////////////
// Xilinx
///////////////////////////////////////////////////////////////////////////////

`ifdef XILINX   

  reg  [15:0] dq_tx_reg;
  wire [15:0] dq_tx;
  reg   [3:0] dqm_tx_reg;
  wire  [3:0] dqm_tx;

  // IO BUFFER
  // DDR data to/from DDR2 SDRAM
  generate
    for (i=0; i<16; i=i+1) begin:iobuf_dq
      IOBUF u_iobuf_dq (
        .I(dq_o[i]),
        .T(!dq_en),
        .IO(dq_io[i]),
        .O(dq_iobuf[i]));
    end
  endgenerate

  // DQS strobe to/from DDR2 SDRAM
  generate
    for (i=0; i<2; i=i+1) begin:iobuf_dqs
      IOBUF u_iobuf_dqs (
        .I(dqs_o[i]),
        .T(!dq_en),
        .IO(dqs_io[i]),
        .O(dqs_iobuf[i]));
    end
  endgenerate

  // DQS strobe to/from DDR2 SDRAM
  generate
    for (i=0; i<2; i=i+1) begin:iobuf_dqs_n
      IOBUF u_iobuf_dqs_n (
        .I(dqs_n_o[i]),
        .T(!dq_en),
        .IO(dqs_n_io[i]),
        .O(dqs_n_iobuf[i]));
    end
  endgenerate


  // Data from Tx FIFO
  always @ (posedge clk_270 or posedge rst)
    if (rst)
      dq_tx_reg[15:0] <= 16'h0;
    else
      if (dqm_en)
        dq_tx_reg[15:0] <= tx_dat_i[19:4];
      else
        dq_tx_reg[15:0] <= tx_dat_i[19:4];

  assign dq_tx[15:0] = tx_dat_i[35:20];

  // Output Data DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:data_out_oddr
      ddr_ff_out ddr_ff_out_inst_0 (
        .Q(dq_o[i]),
        .C0(clk_270),
        .C1(clk_90),
        .CE(dq_en),
        .D0(dq_tx[i]),
        .D1(dq_tx_reg[i]),
        .R(rst),
        .S(1'b0));
    end
  endgenerate

  // Data mask from Tx FIFO
  always @ (posedge clk_270 or posedge rst)
    if (rst)
      dqm_tx_reg[1:0] <= 2'b00;
    else
      if (dqm_en)
        dqm_tx_reg[1:0] <= 2'b00;
      else
        dqm_tx_reg[1:0] <= tx_dat_i[1:0];

  always @ (posedge clk_180 or posedge rst)
    if (rst)
      dqm_tx_reg[3:2] <= 2'b00;
    else
      if (dqm_en)
        dqm_tx_reg[3:2] <= 2'b00;
      else
        dqm_tx_reg[3:2] <= tx_dat_i[3:2];

  assign dqm_tx[1:0] = (dqm_en) ? 2'b00 : tx_dat_i[3:2];

  // Mask output DDR flip-flops
  generate
    for (i=0; i<2; i=i+1) begin:data_mask_oddr
      ddr_ff_out ddr_ff_out_inst_1 (
        .Q(dqm_o[i]),
        .C0(clk_270),
        .C1(clk_90),
        .CE(dq_en),
        .D0(!dqm_tx[i]),
        .D1(!dqm_tx_reg[i]),
        .R(rst),
        .S(1'b0));
    end
  endgenerate

  // Data mask to DDR2 SDRAM
  generate
    for (i=0; i<2; i=i+1) begin:iobuf_dqm
      IOBUF u_iobuf_dqm (
        .I(dqm_o[i]),
        .T(!dq_en),
        .IO(dm_rdqs_io[i]),
        .O());
    end
  endgenerate

    
`ifdef INT_CLOCKED_DATA_CAPTURE
  // Data in
  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:iddr2gen
      ddr_ff_in ddr_ff_in_inst_0 (
        .Q0(dq_rx[i]), 
        .Q1(dq_rx[i+16]), 
        .C0(clk_270), 
        .C1(clk_90),
        .CE(1'b1), 
        .D(dq_io[i]),   
        .R(rst),  
        .S(1'b0));
    end
  endgenerate

  // Data to Rx FIFO
  always @ (posedge clk_0 or posedge rst)
    if (rst)
      dq_rx_reg[31:16] <= 16'h0;
    else
      dq_rx_reg[31:16] <= dq_rx[31:16];

  always @ (posedge clk_180 or posedge rst)
    if (rst)
      dq_rx_reg[15:0] <= 16'h0;
    else
      dq_rx_reg[15:0] <= dq_rx[15:0];

  assign rx_dat_o = dq_rx_reg;
`endif   // INT_CLOCKED_DATA_CAPTURE


`ifdef DQS_DATA_CAPTURE

  wire  [1:0] dqs_iodelay, dqs_n_iodelay;

  // Delay DQS
  assign # 2 dqs_iodelay   = dqs_iobuf;
  assign # 2 dqs_n_iodelay = dqs_n_iobuf;

  // IDDR FF
  generate
    for (i=0; i<16; i=i+1) begin:iddr_dq
      ddr_ff_in ddr_ff_in_inst_0 (
        .Q0(dq_rx[i]), 
        .Q1(dq_rx[i+16]), 
        .C0(dqs_iodelay[0]), 
        .C1(dqs_n_iodelay[0]), 
        .CE(1'b1), 
        .D(dq_iobuf[i]),
        .R(rst),  
        .S(1'b0));
    end
  endgenerate

  // Data to Rx FIFO
  always @ (posedge clk_0 or posedge rst)
    if (rst)
      dq_rx_reg[31:16] <= 16'h0;
    else
      dq_rx_reg[31:16] <= dq_rx[31:16];

  always @ (posedge clk_0 or posedge rst)
    if (rst)
      dq_rx_reg[15:0] <= 16'h0;
    else
      dq_rx_reg[15:0] <= dq_rx[15:0];

  assign rx_dat_o = dq_rx_reg;
  
`endif   // DQS_DATA_CAPTURE

`endif   // XILINX


///////////////////////////////////////////////////////////////////////////////
// Altera
///////////////////////////////////////////////////////////////////////////////

`ifdef ALTERA

  wire  [3:0] dqm_tx;

  // Data out
  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:data_out_oddr
      ddr_ff_out ddr_ff_out_inst_0 (
        .Q(dq_o[i]),
        .C0(clk_270),
        .C1(clk_90),
        .CE(dq_en),
        .D0(tx_dat_i[i+16+4]),
        .D1(tx_dat_i[i+4]),
        .R(rst),
        .S(1'b0));
    end
  endgenerate

  // Assign outport
  assign dq_io = dq_en ? dq_o : {16{1'bz}};

  // DQS strobe
  assign dqs_io   = dq_en ? dqs_o   : {2{1'bz}};
  assign dqs_n_io = dq_en ? dqs_n_o : {2{1'bz}};
  

  // Data mask
  // Data mask from Tx FIFO
  assign dqm_tx = dqm_en ? {4{1'b0}} : tx_dat_i[3:0];

  // DDR flip-flops
  generate
    for (i=0; i<2; i=i+1) begin:data_mask_oddr
      ddr_ff_out ddr_ff_out_inst_1 (
        .Q(dqm_o[i]),
        .C0(clk_270),
        .C1(clk_90),
        .CE(dq_en),
        .D0(!dqm_tx[i+2]),
        .D1(!dqm_tx[i]),
        .R(rst),
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
        .C0(clk_270), 
        .C1(clk_90),
        .CE(1'b1), 
        .D(dq_io[i]),   
        .R(rst),  
        .S(1'b0));
    end
  endgenerate

  // Data to Rx FIFO
  always @ (posedge clk_180 or posedge rst)
    if (rst)
      dq_rx_reg <= 32'h0;
    else
      dq_rx_reg <= dq_rx;

  assign rx_dat_o = dq_rx_reg;
`endif   // INT_CLOCKED_DATA_CAPTURE

   
`ifdef DQS_DATA_CAPTURE

  wire  [1:0] dqs_iodelay, dqs_n_iodelay;

  // Delay DQS
  assign # 2 dqs_iodelay   = dqs_io;
  assign # 2 dqs_n_iodelay = dqs_n_io;

  // IDDR FF
  generate
    for (i=0; i<16; i=i+1) begin:iddr_dq
      ddr_ff_in ddr_ff_in_inst_0 (
        .Q0(dq_rx[i]), 
        .Q1(dq_rx[i+16]), 
        .C0(dqs_n_iodelay[0]), 
        .C1(dqs_iodelay[0]), 
        .CE(1'b1), 
        .D(dq_io[i]),
        .R(rst),  
        .S(1'b0));
    end
  endgenerate

  // Data to Rx FIFO
  always @ (posedge clk_180 or posedge rst)
    if (rst)
      dq_rx_reg <= 32'h0;
    else
      dq_rx_reg <= dq_rx;

  assign rx_dat_o = dq_rx_reg;

`endif   // DQS_DATA_CAPTURE

`endif   // ALTERA

endmodule   // versatile_mem_ctrl_ddr


