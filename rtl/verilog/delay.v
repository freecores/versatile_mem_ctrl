`timescale 1ns/1ns
module delay
  (
   input  [3:0] d,
   output [3:0] q,
   input        clk,
   input 	rst
   );

   parameter depth = 3;
   reg [3:0] dffs [1:depth];

   integer i;
   
   always @ (posedge clk or posedge rst)
     if (rst)
       for ( i=1; i <= depth; i=i+1)
	 dffs[i] <= 4'h0;
     else
       begin
	  dffs[1] <= d;
	  for ( i=2; i <= depth; i=i+1 )
	    dffs[i] <= dffs[i-1];
       end

   assign q = dffs[depth];   
   
endmodule //delay

   