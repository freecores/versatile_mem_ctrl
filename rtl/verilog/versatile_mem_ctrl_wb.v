`timescale 1ns/1ns
module versatile_mem_ctrl_wb (
    // wishbone side
    wb_adr_i_v, wb_dat_i_v, wb_dat_o_v,
    wb_stb_i, wb_cyc_i, wb_ack_o,
    wb_clk, wb_rst,
    // SDRAM controller interface
    sdram_dat_o, sdram_fifo_empty, sdram_fifo_rd,
    sdram_dat_i, sdram_fifo_wr,
    sdram_clk, sdram_rst

);

parameter nr_of_wb_ports = 3;
    
input  [36*nr_of_wb_ports-1:0]  wb_adr_i_v;
input  [36*nr_of_wb_ports-1:0]  wb_dat_i_v;
input  [0:nr_of_wb_ports-1]     wb_stb_i;
input  [0:nr_of_wb_ports-1]     wb_cyc_i;
output [32*nr_of_wb_ports-1:0]  wb_dat_o_v;
output [0:nr_of_wb_ports-1]     wb_ack_o;
input                           wb_clk;
input                           wb_rst;

output [35:0]               sdram_dat_o;
output [0:nr_of_wb_ports-1] sdram_fifo_empty;
input  [0:nr_of_wb_ports-1] sdram_fifo_rd;
input  [31:0]               sdram_dat_i;
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
reg [1:0] wb_state[0:nr_of_wb_ports-1];

wire [35:0] wb_adr_i[0:nr_of_wb_ports-1];
wire [35:0] wb_dat_i[0:nr_of_wb_ports-1];
wire [35:0] egress_fifo_di[0:nr_of_wb_ports-1];
wire [31:0] wb_dat_o;

wire [0:nr_of_wb_ports-1] wb_wr_ack, wb_rd_ack, wr_adr;
reg  [0:nr_of_wb_ports-1] wb_rd_ack_dly;
wire [3:0]  egress_fifo_wadr_bin[0:nr_of_wb_ports-1];
wire [3:0]  egress_fifo_wadr_gray[0:nr_of_wb_ports-1];
wire [3:0]  egress_fifo_radr_bin[0:nr_of_wb_ports-1];
wire [3:0]  egress_fifo_radr_gray[0:nr_of_wb_ports-1];
wire [3:0]  egress_fifo_full;
wire [3:0]  ingress_fifo_wadr_bin[0:nr_of_wb_ports-1];
wire [3:0]  ingress_fifo_wadr_gray[0:nr_of_wb_ports-1];
wire [3:0]  ingress_fifo_radr_bin[0:nr_of_wb_ports-1];
wire [3:0]  ingress_fifo_radr_gray[0:nr_of_wb_ports-1];
wire [3:0]  ingress_fifo_empty;

function [3:0] onehot2bin;
input [0:nr_of_wb_ports-1] a;
integer i;
begin
    onehot2bin = 0;
    for (i=1;i<nr_of_wb_ports;i=i+1) begin
        if (a[i])
            onehot2bin = i;
    end
end
endfunction

genvar i;

generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : vector2array
        assign wb_adr_i[i] = wb_adr_i_v[(nr_of_wb_ports-i)*36-1:(nr_of_wb_ports-1-i)*36];
        assign wb_dat_i[i] = wb_dat_i_v[(nr_of_wb_ports-i)*36-1:(nr_of_wb_ports-1-i)*36];
        assign egress_fifo_di[i] = (wb_state[i]==idle) ? wb_adr_i[i] : wb_dat_i[i];
    end
endgenerate
/*
// fifo write adr
generate
    assign wr_adr[0] = ((wb_state[0]==idle) & wb_cyc_i[0] & wb_stb_i[0] & !egress_fifo_full[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin : fifo_wr_adr
        assign wr_adr[i] = (|(wr_adr[0:i-1])) ? 1'b0 : ((wb_state[i]==idle) & wb_cyc_i[i] & wb_stb_i[i] & !egress_fifo_full[i]);
    end
endgenerate
*/
// wr_ack
generate
    assign wb_wr_ack[0] = ((wb_state[0]==idle | wb_state[0]==wr) & wb_cyc_i[0] & wb_stb_i[0] & !egress_fifo_full[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin : wr_ack
        assign wb_wr_ack[i] = (|(wb_wr_ack[0:i-1])) ? 1'b0 : ((wb_state[i]==idle | wb_state[i]==wr) & wb_cyc_i[i] & wb_stb_i[i] & !egress_fifo_full[i]);
    end
endgenerate

// rd_ack
generate
    assign wb_rd_ack[0] = ((wb_state[0]==rd) & wb_cyc_i[0] & wb_stb_i[0] & !ingress_fifo_empty[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin : rd_ack
        assign wb_rd_ack[i] = (|(wb_rd_ack[0:i-1])) ? 1'b0 : ((wb_state[i]==rd) & wb_cyc_i[i] & wb_stb_i[i] & !ingress_fifo_empty[i]);
    end
endgenerate

always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_rd_ack_dly <= {nr_of_wb_ports{1'b0}};
    else
        wb_rd_ack_dly <= wb_rd_ack;
        
generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : wb_ack
        assign wb_ack_o[i] = (wb_state[i]==wr & wb_wr_ack[i]) | wb_rd_ack_dly[i];
    end
endgenerate

// trafic state machines
generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : fsm
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
                if ((wb_adr_i[i][`CTI_I]==classic | wb_adr_i[i][`CTI_I]==endofburst) & wb_ack_o[i])
                    wb_state[i] <= idle;
            wr:
                if ((wb_adr_i[i][`CTI_I]==classic | wb_adr_i[i][`CTI_I]==endofburst) & wb_ack_o[i])
                    wb_state[i] <= idle;
            default: ;
            endcase
    end
endgenerate

/*
generate

    for (i=0;i<nr_of_wb_ports;i=i+1) begin : ack
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
            default: ;
            endcase
    end
    
endgenerate
*/
generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : fifo_adr
    
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
		.fifo_empty(sdram_fifo_empty[i]), 
		.fifo_full(egress_fifo_full[i]), 
		.wclk(wb_clk), 
		.rclk(sdram_clk), 
		.rst(wb_rst));
                
        // ingress queue
        fifo_adr_counter ingress_wadrcnt (
            .cke(sdram_fifo_wr[i]),
            .q(ingress_fifo_wadr_gray[i]),
            .q_bin(ingress_fifo_wadr_bin[i]),
            .rst(sdram_rst),
            .clk(sdram_clk));
        
        fifo_adr_counter ingress_radrcnt (
            .cke(wb_rd_ack[i]),
            .q(ingress_fifo_radr_gray[i]),
            .q_bin(ingress_fifo_radr_bin[i]),
            .rst(wb_rst),
            .clk(wb_clk));
        
	versatile_fifo_async_cmp
            #(.ADDR_WIDTH(4))
            ingresscmp ( 
                .wptr(ingress_fifo_wadr_gray[i]), 
		.rptr(ingress_fifo_radr_gray[i]), 
		.fifo_empty(ingress_fifo_empty[i]), 
		.fifo_full(), 
		.wclk(sdram_clk), 
		.rclk(wb_clk), 
		.rst(wb_rst));
        
    end    
endgenerate
    
vfifo_dual_port_ram_dc_sw # ( .DATA_WIDTH(36), .ADDR_WIDTH(8))
    egress_dpram (
    .d_a(egress_fifo_di[onehot2bin(wb_wr_ack)]),
    .adr_a({onehot2bin(wb_wr_ack),egress_fifo_wadr_bin[onehot2bin(wb_wr_ack)]}), 
    .we_a(|(wb_wr_ack)),
    .clk_a(wb_clk),
    .q_b(sdram_dat_o),
    .adr_b({onehot2bin(sdram_fifo_rd),egress_fifo_radr_bin[onehot2bin(sdram_fifo_rd)]}),
    .clk_b(sdram_clk) );

vfifo_dual_port_ram_dc_sw # ( .DATA_WIDTH(32), .ADDR_WIDTH(8))
    ingress_dpram (
    .d_a(sdram_dat_i),
    .adr_a({onehot2bin(sdram_fifo_wr),ingress_fifo_wadr_bin[onehot2bin(sdram_fifo_wr)]}), 
    .we_a(|(sdram_fifo_wr)),
    .clk_a(sdram_clk),
    .q_b(wb_dat_o),
    .adr_b({onehot2bin(wb_rd_ack),ingress_fifo_radr_bin[onehot2bin(wb_rd_ack)]}),
    .clk_b(wb_clk) );
    
assign wb_dat_o_v = {nr_of_wb_ports{wb_dat_o}};

endmodule