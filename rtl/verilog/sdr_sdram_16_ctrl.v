`timescale 1ns/1ns
//`sinclude "type_definitions.struct"
//`include "sdr_16_defines.v"
`ifdef ACTEL
`define SYN /*synthesis syn_useioff=1 syn_allow_retiming=0 */
`else
`define SYN
`endif
module sdr_sdram_16_ctrl (
    // wisbone i/f
    dat_i, adr_i, sel_i, cti_i, bte_i, we_i, cyc_i, stb_i, dat_o, ack_o,
    // SDR SDRAM
    ba, a, cmd, cke, cs_n, dqm, dq_i, dq_o, dq_oe,
    // system
    clk, rst);

    parameter ba_size = 2;   
    parameter row_size = 13;
    parameter col_size = 9;
    parameter cl = 2;   

    // LMR
    // [12:10] reserved
    // [9]     WB, write burst; 0 - programmed burst length, 1 - single location
    // [8:7]   OP Mode, 2'b00
    // [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
    // [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
    // [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
    parameter init_wb = 1'b0;
    parameter init_cl = 3'b010;
    parameter init_bt = 1'b0;
    parameter init_bl = 3'b001;
	
    input [31:0] dat_i;
    input [ba_size+col_size+row_size:1] adr_i;
    input [3:0] sel_i;
    input [2:0] cti_i;
    input [1:0] bte_i;
    input we_i, cyc_i, stb_i;
    output reg [31:0] dat_o;
    output ack_o;

    output reg [1:0]    ba `SYN;
    output reg [12:0]   a `SYN;
    output reg [2:0]    cmd `SYN;
    output cke, cs_n;
    output reg [1:0]    dqm `SYN;
    output reg [15:0]   dq_o `SYN;
    output reg          dq_oe;
    input  [15:0]       dq_i;

    input clk, rst;

    wire [ba_size-1:0] 	bank;
    wire [row_size-1:0] row;
    wire [col_size-1:0] col;
    wire [12:0]         col_a10_fix;
    reg [4:0]		col_reg;
    wire [0:31] 	shreg; 
    reg			count0;
    wire 		stall; // active if write burst need data
    reg 		ref_cnt_zero, refresh_req; 
    reg			wb_flag;

    reg [1:6] ack_rd;
    wire ack_wr;

   // to keep track of open rows per bank
   reg [row_size-1:0] 	open_row[0:3];
   reg [0:3] 		open_ba;
   reg 			current_bank_closed, current_row_open;  
   
`ifndef RFR_WRAP_VALUE
    parameter rfr_length = 10;
    parameter rfr_wrap_value = 1010;
`else
    parameter rfr_length = `RFR_LENGTH;
    parameter rfr_wrap_value = `RFR_WRAP_VALUE;	
`endif
	
    parameter [1:0] linear = 2'b00,
                    beat4  = 2'b01,
                    beat8  = 2'b10,
                    beat16 = 2'b11;

    parameter [2:0] cmd_nop = 3'b111,
                    cmd_act = 3'b011,
                    cmd_rd  = 3'b101,
                    cmd_wr  = 3'b100,
                    cmd_pch = 3'b010,
                    cmd_rfr = 3'b001,
                    cmd_lmr = 3'b000;

// ctrl FSM
`define FSM_INIT 3'b000
`define FSM_IDLE 3'b001
`define FSM_RFR  3'b010
`define FSM_ADR  3'b011
`define FSM_PCH  3'b100
`define FSM_ACT  3'b101
//`define FSM_W4D  3'b110
`define FSM_RW   3'b111

    assign cke = 1'b1;
    assign cs_n = 1'b0;
	   
    reg [2:0] state, next;

    function [12:0] a10_fix;
        input [col_size-1:0] a;
        integer i;
    begin
	for (i=0;i<13;i=i+1) begin
            if (i<10)
              if (i<col_size)
                a10_fix[i] = a[i];
              else
                a10_fix[i] = 1'b0;
            else if (i==10)
              a10_fix[i] = 1'b0;
            else
              if (i<col_size)
                a10_fix[i] = a[i-1];
              else
                a10_fix[i] = 1'b0;
	end
    end
    endfunction

    assign {bank,row,col} = adr_i;

    always @ (posedge clk or posedge rst)
    if (rst)
       state <= `FSM_INIT;
    else
       state <= next;
   
    always @*
    begin
	next = 3'bx;
	case (state)
	`FSM_INIT:
            if (shreg[31]) next = `FSM_IDLE;
            else next = `FSM_INIT;
        `FSM_IDLE:   
	    if (refresh_req) next = `FSM_RFR;
            else if (cyc_i & stb_i & !(|ack_rd)) next = `FSM_ADR;
            else next = `FSM_IDLE;
        `FSM_RFR: 
            if (shreg[8]) next = `FSM_IDLE; // tRFC=60ns, AREF@2
            else  next = `FSM_RFR;
	`FSM_ADR:
            if (current_bank_closed) next = `FSM_ACT;
	    else if (current_row_open) next = `FSM_RW;
	    else next = `FSM_PCH;
	`FSM_PCH: 
            if (shreg[1]) next = `FSM_ACT;
            else next = `FSM_PCH;
	`FSM_ACT:
            if (shreg[2]) next = `FSM_RW;
            else next = `FSM_ACT;
	`FSM_RW:     
            if (bte_i==linear & shreg[1]) next = `FSM_IDLE;
            else if (bte_i==beat4 & shreg[7]) next = `FSM_IDLE;
`ifdef BEAT8
            else if (bte_i==beat8 & shreg[15]) next = `FSM_IDLE;
`endif
`ifdef BEAT16
            else if (bte_i==beat16 & shreg[31]) next = `FSM_IDLE;
`endif
            else next = `FSM_RW;
	endcase
    end

    // active if write burst need data
    assign stall = state==`FSM_RW & next==`FSM_RW & ~stb_i & count0 & we_i;
   
    // flag indicates active wb cycle
    always @ (posedge clk or posedge rst)
    if (rst)
        wb_flag <= 1'b0;
    else
        if (state==`FSM_ADR)
            wb_flag <= 1'b1;
   	else if ((cti_i==3'b000 | cti_i==3'b111) & ack_o)
            wb_flag <= 1'b0;

    // counter    
    cnt_shreg_ce_clear # ( .length(32))
        cnt0 (
            .cke(!stall),
            .clear(!(state==next)),
            .q(shreg),
            .rst(rst),
            .clk(clk));
    
    dff_ce_clear
        dff_count0 (
            .d(!count0),
            .ce(!stall),
            .clear(!(state==next)),
            .q(count0),
            .rst(rst),
            .clk(clk));

    // ba, a, cmd
    // col_reg_a10 has bit [10] set to zero to disable auto precharge
    assign col_a10_fix = a10_fix({col[col_size-1:5],col_reg});

    // outputs dependent on state vector
    always @ (posedge clk or posedge rst)
    begin
	if (rst) begin
           {ba,a,cmd} <= {2'b00,13'd0,cmd_nop};
           dqm <= 2'b11;
           dq_oe <= 1'b0;
           col_reg <= 5'b000;
           {open_ba,open_row[0],open_row[1],open_row[2],open_row[3]} <= {4'b0000,{row_size*4{1'b0}}};
	end else begin
   	    {ba,a,cmd} <= {2'b00,13'd0,cmd_nop};
            dqm <= 2'b11;
            dq_oe <= 1'b0;
            case (state)
            `FSM_INIT:
                if (shreg[3]) begin
                    {ba,a,cmd} <= {2'b00, 13'b0010000000000, cmd_pch};
                    open_ba[bank] <= 1'b0;
                end else if (shreg[7] | shreg[19])
                    {ba,a,cmd} <= {2'b00, 13'd0, cmd_rfr};
                else if (shreg[31])
                    {ba,a,cmd} <= {2'b00,3'b000,init_wb,2'b00,init_cl,init_bt,init_bl,cmd_lmr};
            `FSM_RFR:
        	if (shreg[0]) begin
            	{ba,a,cmd} <= {2'b00, 13'b0010000000000, cmd_pch};
            	open_ba <= 4'b0000;
        	end else if (shreg[2])
            	{ba,a,cmd} <= {2'b00, 13'd0, cmd_rfr};
	    `FSM_IDLE:
		col_reg <= col[4:0];
	    `FSM_PCH:
        	if (shreg[0]) begin
                    {ba,a,cmd} <= {ba,13'd0,cmd_pch};
                    open_ba[bank] <= 1'b0;
                end
            `FSM_ACT:
                if (shreg[0]) begin
                    {ba,a,cmd} <= {bank,(13'd0 | row),cmd_act};
                    {open_ba[bank],open_row[bank]} <= {1'b1,row};
                end
            `FSM_RW:
                begin
                    if (we_i & !count0)
                        cmd <= cmd_wr;
                    else if (!count0)
                        cmd <= cmd_rd;
                    else
                        cmd <= cmd_nop;
                    if (we_i & !count0)
                        dqm <= ~sel_i[3:2];
                    else if (we_i & count0)
                        dqm <= ~sel_i[1:0];
                    else
                        dqm <= 2'b00;
                    if (we_i)
                        dq_oe <= 1'b1;
                    if (~stall)
                        case (bte_i)
                        linear: {ba,a} <= {bank,col_a10_fix};
                        beat4:  {ba,a,col_reg[2:0]} <= {bank,col_a10_fix, col_reg[2:0] + 3'd1};
`ifdef BEAT8    
                        beat8:  {ba,a,col_reg[3:0]} <= {bank,col_a10_fix, col_reg[3:0] + 4'd1};
`endif
`ifdef BEAT16   
                        beat16: {ba,a,col_reg[4:0]} <= {bank,col_a10_fix, col_reg[4:0] + 5'd1};
`endif
                        endcase
                end
            endcase
        end
    end

    // bank and row open ?
    always @ (posedge clk or posedge rst)
    if (rst)
       {current_bank_closed, current_row_open} <= {1'b1, 1'b0};
    else
       //if (state==adr & counter[1:0]==2'b10)
       {current_bank_closed, current_row_open} <= {!(open_ba[bank]), open_row[bank]==row};

    // refresh counter
    cnt_lfsr_zq # ( .length(rfr_length), .wrap_value (rfr_wrap_value)) ref_counter0( .zq(ref_cnt_zero), .rst(rst), .clk(clk));
        
    always @ (posedge clk or posedge rst)
    if (rst)
    	refresh_req <= 1'b0;
    else
    	if (ref_cnt_zero)
            refresh_req <= 1'b1;
       	else if (state==`FSM_RFR)
            refresh_req <= 1'b0;
	

    dff # ( .width(32)) wb_dat_dff ( .d({dat_o[15:0],dq_i}), .q(dat_o), .clk(clk), .rst(rst));
    
    assign ack_wr = (state==`FSM_RW & count0 & we_i);
    
    always @ (posedge clk or posedge rst)
    if (rst)
        ack_rd <= {6{1'b0}};
    else
        ack_rd <= {state==`FSM_RW & count0 & !we_i,ack_rd[2:5]};
	
    assign ack_o = (cl==2) ? ack_rd[5] | ack_wr :
                   (cl==3) ? ack_rd[6] | ack_wr :
                   1'b0;

    // output dq_o mux and dffs
    always @ (posedge clk or posedge rst)
    if (rst)
    	dq_o <= 16'h0000;
    else
        if (~count0)
            dq_o <= dat_i[31:16];
        else
            dq_o <= dat_i[15:0];

endmodule
