`timescale 1ns/1ns
module versatile_mem_ctrl_wb (
    // wishbone side
    wb_adr_i_v, wb_dat_i_v, wb_dat_o_v,
    wb_stb_i, wb_cyc_i, wb_ack_o,
    wb_clk, wb_rst,
    // SDRAM controller interface
    sdram_dat_o, sdram_fifo_empty, sdram_fifo_rd_adr, sdram_fifo_rd_data, sdram_fifo_re,
    sdram_dat_i, sdram_fifo_wr, sdram_fifo_we,
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
input                       sdram_fifo_rd_adr, sdram_fifo_rd_data;
input  [0:nr_of_wb_ports-1] sdram_fifo_re;
input  [31:0]               sdram_dat_i;
input                       sdram_fifo_wr;
input  [0:nr_of_wb_ports-1] sdram_fifo_we;
input                       sdram_clk;
input                       sdram_rst;

parameter linear       = 2'b00;
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
parameter fe   = 2'b11;

reg [1:0] wb_state[0:nr_of_wb_ports-1];

wire [35:0] wb_adr_i[0:nr_of_wb_ports-1];
wire [35:0] wb_dat_i[0:nr_of_wb_ports-1];
wire [36*nr_of_wb_ports-1:0] egress_fifo_di;
wire [31:0] wb_dat_o;

wire [0:nr_of_wb_ports-1] wb_wr_ack, wb_rd_ack, wr_adr;
reg  [0:nr_of_wb_ports-1] wb_rd_ack_dly;
wire [0:nr_of_wb_ports-1] wb_ack_o_int;
wire [0:nr_of_wb_ports-1] egress_fifo_full;
wire [0:nr_of_wb_ports-1] ingress_fifo_empty;

genvar i;

`define INDEX (nr_of_wb_ports-i)*36-1:(nr_of_wb_ports-1-i)*36 
generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : vector2array
        assign wb_adr_i[i] = wb_adr_i_v[`INDEX];
        assign wb_dat_i[i] = wb_dat_i_v[`INDEX];
        assign egress_fifo_di[`INDEX] = (wb_state[i]==idle) ? wb_adr_i[i] : wb_dat_i[i];
    end
endgenerate

// wr_ack
generate
    assign wb_wr_ack[0] = ((wb_state[0]==idle | wb_state[0]==wr) & wb_cyc_i[0] & wb_stb_i[0] & !egress_fifo_full[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin : wr_ack
        assign wb_wr_ack[i] = (|(wb_wr_ack[0:i-1])) ? 1'b0 : ((wb_state[i]==idle | wb_state[i]==wr) & wb_cyc_i[i] & wb_stb_i[i] & !egress_fifo_full[i]);
    end
endgenerate

// rd_ack
generate
    assign wb_rd_ack[0] = ((wb_state[0]==rd) & wb_cyc_i[0] & wb_stb_i[0] & !ingress_fifo_empty[0]) | (wb_state[0]==fe & !ingress_fifo_empty[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin : rd_ack
        assign wb_rd_ack[i] = (|(wb_rd_ack[0:i-1])) ? 1'b0 : ((wb_state[i]==rd) & wb_cyc_i[i] & wb_stb_i[i] & !ingress_fifo_empty[i]) | (wb_state[i]==fe & !ingress_fifo_empty[i]);
    end
endgenerate

always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_rd_ack_dly <= {nr_of_wb_ports{1'b0}};
    else
        wb_rd_ack_dly <= wb_rd_ack;
        
generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : wb_ack
        assign wb_ack_o_int[i] = (wb_state[i]==wr & wb_wr_ack[i]) | wb_rd_ack_dly[i];
        assign wb_ack_o[i] = (wb_state[i]==fe) ? 1'b0 : wb_ack_o_int[i];
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
                if (wb_adr_i[i][`CTI_I]==endofburst & !ingress_fifo_empty[i])
                    wb_state[i] <= fe;
                else if ((wb_adr_i[i][`CTI_I]==classic | wb_adr_i[i][`CTI_I]==endofburst | wb_adr_i[i][`BTE_I]==linear) & wb_ack_o_int[i])
                    wb_state[i] <= idle;
            wr:
                if ((wb_adr_i[i][`CTI_I]==classic | wb_adr_i[i][`CTI_I]==endofburst | wb_adr_i[i][`BTE_I]==linear) & wb_ack_o_int[i])
                    wb_state[i] <= idle;
            fe:
                if (ingress_fifo_empty[i])
                    wb_state[i] <= idle;
            default: ;
            endcase
    end
endgenerate

egress_fifo # (.a_hi_size(4),.a_lo_size(4),.nr_of_queues(nr_of_wb_ports),.data_width(36))
egress_FIFO(
    .d(egress_fifo_di), .fifo_full(egress_fifo_full), .write(|(wb_wr_ack)), .write_enable(wb_wr_ack),
    .q(sdram_dat_o), .fifo_empty(sdram_fifo_empty), .read_adr(sdram_fifo_rd_adr), .read_data(sdram_fifo_rd_data), .read_enable(sdram_fifo_re),
    .clk1(wb_clk), .rst1(wb_rst), .clk2(sdram_clk), .rst2(sdram_rst)
);

async_fifo_mq # (.a_hi_size(4),.a_lo_size(4),.nr_of_queues(nr_of_wb_ports),.data_width(32))
ingress_FIFO(
    .d(sdram_dat_i), .fifo_full(), .write(sdram_fifo_wr), .write_enable(sdram_fifo_we),
    .q(wb_dat_o), .fifo_empty(ingress_fifo_empty), .read(|(wb_rd_ack)), .read_enable(wb_rd_ack),
    .clk1(sdram_clk), .rst1(sdram_rst), .clk2(wb_clk), .rst2(wb_rst)
);

assign wb_dat_o_v = {nr_of_wb_ports{wb_dat_o}};

endmodule