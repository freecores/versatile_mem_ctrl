versatile_library.v:
    
async_fifo_dw_simplex_actel.v:
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/async_fifo_dw_simplex_actel.v

VERSATILE_COUNTER_PROJECT_FILES =versatile_counter_generator.php
VERSATILE_COUNTER_PROJECT_FILES +=CSV.class.php

versatile_counter_generator.php:
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/ $(VERSATILE_COUNTER_PROJECT_FILES)

ref_counter.v: versatile_counter_generator.php
	excel2csv ref_counter.xls -S ,
	./versatile_counter_generator.php ref_counter.csv > ref_counter.v

sdr_sdram_16_ctrl_actel.v:
	vppreproc --noline --noblank +define+RFR_LENGTH+10 +define+RFR_WRAP_VALUE+1001 +define+ACTEL sdr_sdram_16_ctrl.v > sdr_sdram_16_ctrl_actel.v

export:
	svn export http://opencores.org/ocsvn/versatile_library/versatile_library/trunk/rtl/verilog/versatile_library.v
    
# the single all rule
all: sdr_sdram_16_ctrl_actel.v

clean:
	rm -rf $(VERSATILE_FIFO_PROJECT_FILES) $(VERSATILE_COUNTER_PROJECT_FILES)
	rm -rf fifo_fill.v sdr_16.v ddr_16.v
	rm -f versatile_fifo_dual_port_ram_dc_dw.v ddr_16_generated.v
	rm -rf *_counter.v
	rm -rf *.csv
	rm -rf *~
	rm -rf sdr_sdram_16_ctrl_actel.v
