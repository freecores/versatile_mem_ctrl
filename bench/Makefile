wb:
	perl fizzim.pl < wb0.fzm > wb0.v
	perl fizzim.pl < wb1.fzm > wb1.v
	perl fizzim.pl < wb4.fzm > wb4.v
	perl fizzim.pl < wb0_ddr.fzm > wb0_ddr.v
	perl fizzim.pl < wb1_ddr.fzm > wb1_ddr.v
	perl fizzim.pl < wb4_ddr.fzm > wb4_ddr.v

tb:
	vppreproc --simple tb.v > tb_top.v

all:    wb tb
