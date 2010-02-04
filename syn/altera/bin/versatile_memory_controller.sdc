#**************************************************************
# Time Information
#**************************************************************



#**************************************************************
# Create Clock
#**************************************************************

# Clock frequency
set wb_clk_period 20.000
set sdram_clk_period 8.000

# Clocks
create_clock -name {wb_clk} -period $wb_clk_period 
create_clock -name {sdram_clk} -period $sdram_clk_period 

# Virtual clocks
create_clock -name {v_wb_clk_in} -period $wb_clk_period 
create_clock -name {v_wb_clk_out} -period $wb_clk_period 
create_clock -name {v_sdram_clk_in} -period $sdram_clk_period 
create_clock -name {v_sdram_clk_out} -period $sdram_clk_period 

# Base clock for the PLL input clock port
create_clock -name pll_base_clock -period $sdram_clk_period [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|inclk[0]}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {sdram_clk_0} -phase 0 -source [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|inclk[0]}]  [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[0]}]

create_generated_clock -name {sdram_clk_180} -phase 180 -source [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|inclk[0]}]  [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[2]}]

create_generated_clock -name {sdram_clk_270} -phase 270 -source [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|inclk[0]}]  [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[3]}]

#derive_pll_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************

set ddr2_input_delay_min 0
set ddr2_input_delay_max 0

set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_min [get_ports {ck_fb_pad_i}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_min [get_ports {dm_rdqs_pad_io[*]}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_min [get_ports {dq_pad_io[*]}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_min [get_ports {dqs_pad_io[*]}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_min [get_ports {dqs_n_pad_io[*]}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_min [get_ports {rdqs_n_pad_i[*]}]

set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_max [get_ports {ck_fb_pad_i}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_max [get_ports {dm_rdqs_pad_io[*]}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_max [get_ports {dq_pad_io[*]}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_max [get_ports {dqs_pad_io[*]}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_max [get_ports {dqs_n_pad_io[*]}]
set_input_delay -add_delay -clock { v_sdram_clk_in } $ddr2_input_delay_max [get_ports {rdqs_n_pad_i[*]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set ddr2_output_delay_min 0
set ddr2_output_delay_max 0

set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {ck_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {ck_n_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {cke_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {ck_fb_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {cs_n_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {ras_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {cas_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {we_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {dm_rdqs_pad_io[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {ba_pad_o[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {addr_pad_o[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {dq_pad_io[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {dqs_pad_io[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {dqs_oe}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {dqs_n_pad_io[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_min [get_ports {odt_pad_o}]

set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {ck_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {ck_n_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {cke_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {ck_fb_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {cs_n_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {ras_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {cas_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {we_pad_o}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {dm_rdqs_pad_io[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {ba_pad_o[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {addr_pad_o[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {dq_pad_io[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {dqs_pad_io[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {dqs_oe}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {dqs_n_pad_io[*]}]
set_output_delay -add_delay -clock { v_sdram_clk_out } $ddr2_output_delay_max [get_ports {odt_pad_o}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {wb_rst}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

