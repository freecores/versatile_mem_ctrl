module dff_sr (aclr, aset, clock, data, q);

  input	 aclr;
  input	 aset;
  input	 clock;
  input	 data;
  output q;

  wire  data_in = data;
  wire  data_out;
  wire  q = data_out;

`ifdef XILINX
  FDCP FDCP_inst (
    .Q(data_out),
    .C(clock),
    .CLR(aclr),
    .D(data_in),
    .PRE(aset));
  defparam
    FDCP_inst.INIT = 1'b0;
`endif   // XILINX

`ifdef ALTERA
  lpm_ff lpm_ff_inst (
    .aclr(aclr),
    .clock(clock),
    .data(data_in),
    .aset(aset),
    .aload(),
    .enable(),
    .sclr(),
    .sload(),
    .sset(),
    .q(data_out));
  defparam
    lpm_ff_inst.lpm_fftype = "DFF",
    lpm_ff_inst.lpm_type = "LPM_FF",
    lpm_ff_inst.lpm_width = 1;
`endif   // ALTERA

endmodule

