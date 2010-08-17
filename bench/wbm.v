module wbm (
  output [31:0] adr_o,
  output [1:0] bte_o,
  output [2:0] cti_o,
  output [31:0] dat_o,
  output [3:0] sel_o,
  output we_o,
  output cyc_o,
  output stb_o,
  input wire [31:0] dat_i,
  input wire ack_i,
  input wire clk,
  input wire reset,
  output reg OK
);

	parameter [1:0] linear = 2'b00,
               		beat4  = 2'b01,
               		beat8  = 2'b10,
               		beat16 = 2'b11;
                		
    parameter [2:0] classic = 3'b000,
                    inc     = 3'b010,
                    eob		= 3'b111;

	parameter instructions = 32; 
	
	parameter [32+2+3+32+4+1+1+1:1] inst_rom [0:instructions-1]= {
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0},
		{32'h0,linear,classic,32'h0,4'b1111,1'b0,1'b0,1'b0}};
		
	parameter [31:0] dat [0:instructions-1] = {
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0};
  	
//	parameter idle   = 1'b0;
//	parameter active = 1'b1;
//	
//	reg state;
	
  	integer i;
                
	assign {adr_o,bte_o,cti_o,dat_o,sel_o,we_o,cyc_o,stb_o} = inst_rom[i];
	
	always @ (posedge clk or posedge reset)
	if (reset)
		i = 0;
	else
		if ((!stb_o | ack_i) & i < instructions)
			i = i + 1;

	always @ (posedge clk or posedge reset)
	if (reset)
		OK <= 1'b1;
	else
		if (ack_i & !we_o & (dat_i != dat[i]))
			OK <= 1'b0;
			//assert "Read error";
				
//	always @ (posedge clk or posedge reset)
//	if (reset)
//		state <= idle;
//	else
//		if (state==idle & cyc_o)
//			state <= active;
//		else if ((cti_o==3'b000 | cti_o==3'b111) & cyc_o & stb_o & ack_i)
//			state <= idle;
  
endmodule
