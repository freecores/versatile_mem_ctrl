all:    wb0.v wb1.v wb4.v wb0_ddr.v wb1_ddr.v wb4_ddr.v tb_top.v

wb0.v: wb0.fzm
	perl fizzim.pl < wb0.fzm > wb0.v

wb1.v: wb1.fzm
	perl fizzim.pl < wb1.fzm > wb1.v

wb4.v: wb4.fzm
	perl fizzim.pl < wb4.fzm > wb4.v

wb0_ddr.v: wb0_ddr.fzm
	perl fizzim.pl < wb0_ddr.fzm > wb0_ddr.v

wb1_ddr.v: wb1_ddr.fzm
	perl fizzim.pl < wb1_ddr.fzm > wb1_ddr.v

wb4_ddr.v: wb4_ddr.fzm
	perl fizzim.pl < wb4_ddr.fzm > wb4_ddr.v

tb_top.v: tb.v ../rtl/verilog/versatile_mem_ctrl_defines.v
	vppreproc --simple tb.v > tb_top.v

clean:
	rm -rf wb*.v tb_top.v
