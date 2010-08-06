
module wb1 (
  output reg [31:0] adr,
  output reg [1:0] bte,
  output reg [2:0] cti,
  output reg cyc,
  output reg [31:0] dat,
  output reg [3:0] sel,
  output reg stb,
  output reg we,
  input wire ack,
  input wire clk,
  input wire [31:0] dat_i,
  input wire reset 
);
  
  
  

  // state bits
  parameter 
  state0 = 4'b0000, 
  state1 = 4'b0001, 
  state2 = 4'b0010, 
  state3 = 4'b0011, 
  state4 = 4'b0100, 
  state5 = 4'b0101, 
  state6 = 4'b0110, 
  state7 = 4'b0111, 
  state8 = 4'b1000; 
  
  reg [3:0] state;
  reg [3:0] nextstate;
  
  // comb always block
  always @* begin
    nextstate = state; // default to hold value because implied_loopback is set
    adr[31:0] = 32'h0; // default
    bte[1:0] = 2'b00; // default
    cti[2:0] = 3'b000; // default
    cyc = 1'b0; // default
    dat[31:0] = 32'h0; // default
    sel[3:0] = 4'b1111; // default
    stb = 1'b0; // default
    we = 1'b0; // default
    case (state)
      state0: begin
        begin
          nextstate = state1;
        end
      end
      state1: begin
        adr[31:0] = 32'h1000;
        cyc = 1'b1;
        dat[31:0] = 32'h12345678;
        stb = 1'b1;
        we = 1'b1;
        if (ack) begin
          nextstate = state2;
        end
      end
      state2: begin
        adr[31:0] = 32'h1000;
        cyc = 1'b1;
        stb = 1'b1;
        if (ack) begin
          nextstate = state3;
        end
      end
      state3: begin
        begin
          nextstate = state4;
        end
      end
      state4: begin
        adr[31:0] = 32'h1000;
        bte[1:0] = 2'b01;
        cti[2:0] = 3'b010;
        cyc = 1'b1;
        stb = 1'b1;
        if (ack) begin
          nextstate = state5;
        end
      end
      state5: begin
        bte[1:0] = 2'b01;
        cti[2:0] = 3'b010;
        cyc = 1'b1;
        stb = 1'b1;
        if (ack) begin
          nextstate = state6;
        end
      end
      state6: begin
        bte[1:0] = 2'b01;
        cti[2:0] = 3'b010;
        cyc = 1'b1;
        stb = 1'b1;
        if (ack) begin
          nextstate = state7;
        end
      end
      state7: begin
        bte[1:0] = 2'b01;
        cti[2:0] = 3'b111;
        cyc = 1'b1;
        stb = 1'b1;
        if (ack) begin
          nextstate = state8;
        end
      end
      state8: begin
      end
    endcase
  end
  
  // Assign reg'd outputs to state bits
  
  // sequential always block
  always @(posedge clk or posedge reset) begin
    if (reset)
      state <= state0;
    else
      state <= nextstate;
  end
  
  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [47:0] statename;
  always @* begin
    case (state)
      state0:
        statename = "state0";
      state1:
        statename = "state1";
      state2:
        statename = "state2";
      state3:
        statename = "state3";
      state4:
        statename = "state4";
      state5:
        statename = "state5";
      state6:
        statename = "state6";
      state7:
        statename = "state7";
      state8:
        statename = "state8";
      default:
        statename = "XXXXXX";
    endcase
  end
  `endif

  
endmodule

