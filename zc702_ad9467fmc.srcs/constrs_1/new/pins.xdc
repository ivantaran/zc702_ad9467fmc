
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports adc_clk_clk_p]
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports adc_or_p]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {adc_data_p[0]}]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {adc_data_p[1]}]
set_property -dict {PACKAGE_PIN L21 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {adc_data_p[2]}]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {adc_data_p[3]}]
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {adc_data_p[4]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {adc_data_p[5]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {adc_data_p[6]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {adc_data_p[7]}]

#set_property -dict {PACKAGE_PIN A19     IOSTANDARD LVCMOS25} [get_ports spi_csn_adc]                        ; ## FMC1_LPC_LA33_N
#set_property -dict {PACKAGE_PIN A18     IOSTANDARD LVCMOS25} [get_ports spi_csn_clk]                        ; ## FMC1_LPC_LA33_P
#set_property -dict {PACKAGE_PIN B22     IOSTANDARD LVCMOS25} [get_ports spi_clk]                            ; ## FMC1_LPC_LA32_N
#set_property -dict {PACKAGE_PIN B21     IOSTANDARD LVCMOS25} [get_ports spi_sdio]                           ; ## FMC1_LPC_LA32_P

set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS25} [get_ports {spi_tri_io[3]}]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS25} [get_ports {spi_tri_io[2]}]
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS25} [get_ports {spi_tri_io[1]}]
set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS25} [get_ports {spi_tri_io[0]}]

set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS25} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS25} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS25} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS25} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS25} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS25} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS25} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS25} [get_ports {led[7]}]

create_clock -period 4.0 -name adc_clk [get_ports adc_clk_clk_p]
set_max_delay -from [get_clocks adc_clk] -to [get_clocks clk_fpga_0] 20.0
set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks adc_clk]

#set_max_delay -from [get_clocks adc_clk] -to [get_clocks clk_fpga_1] 4.0
#set_max_delay -from [get_clocks clk_fpga_1] -to [get_clocks adc_clk] 4.0
#set_max_delay -from [get_clocks clk_fpga_0] -to [get_clocks clk_fpga_2] 5.0

#set_max_delay -from [get_clocks adc_clk_design_1_clk_wiz_0_0] -to [get_clocks clk_fpga_0] 20.0
#set_max_delay -from [get_clocks adc_clk_design_1_clk_wiz_0_0] -to [get_clocks clk_fpga_1] 4.0
#set_max_delay -from [get_clocks clk_fpga_1] -to [get_clocks adc_clk_design_1_clk_wiz_0_0] 8.0
#set_max_delay -from [get_clocks clk_fpga_0] -to [get_clocks clk_fpga_2] 5.0

#set_max_delay -from [get_clocks adc_clk_design_1_clk_wiz_0_0] -to [get_clocks clk_fpga_0] 20.0
#set_max_delay -from [get_clocks adc_clk_design_1_clk_wiz_0_0] -to [get_clocks axi_clk_design_1_clk_wiz_0_0] 4.0
#set_max_delay -from [get_clocks axi_clk_design_1_clk_wiz_0_0] -to [get_clocks adc_clk_design_1_clk_wiz_0_0] 4.0
#set_max_delay -from [get_clocks clk_fpga_0] -to [get_clocks clk_fpga_2] 5.0

#set_input_delay -clock adc_clk 1.7 adc_data_p[*]
#set_input_delay -clock adc_clk 1.0 adc_data_n[*]
