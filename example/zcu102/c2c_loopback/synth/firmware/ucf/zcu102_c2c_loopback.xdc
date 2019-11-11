set_property PACKAGE_PIN H1  [get_ports "c2c_s_gt_rxn" ] ;# "FMC_HPC0_DP0_M2C_N"]        ;# Bank 229 - MGTHRXN2_229
set_property PACKAGE_PIN H2  [get_ports "c2c_s_gt_rxp" ] ;# "FMC_HPC0_DP0_M2C_P"]        ;# Bank 229 - MGTHRXP2_229
set_property PACKAGE_PIN G3  [get_ports "c2c_s_gt_txn" ] ;# "FMC_HPC0_DP0_C2M_N"]        ;# Bank 229 - MGTHTXN2_229
set_property PACKAGE_PIN G4  [get_ports "c2c_s_gt_txp" ] ;# "FMC_HPC0_DP0_C2M_P"]        ;# Bank 229 - MGTHTXP2_229
set_property PACKAGE_PIN C7  [get_ports "c2c_s_gt_clkn"] ;# "USER_MGT_SI570_CLOCK2_C_N"] ;# Bank 230 - MGTREFCLK0N_230
set_property PACKAGE_PIN C8  [get_ports "c2c_s_gt_clkp"] ;# "USER_MGT_SI570_CLOCK2_C_P"] ;# Bank 230 - MGTREFCLK0P_230
create_clock -period 6.4 -name c2c_s_gt_clk [get_ports "c2c_s_gt_clkp"]

set_property PACKAGE_PIN M34 [get_ports "c2c_m_gt_rxn" ] ;# "SMA_MGT_RX_C_N"]            ;# Bank 128 - MGTHRXN3_128
set_property PACKAGE_PIN M33 [get_ports "c2c_m_gt_rxp" ] ;# "SMA_MGT_RX_C_P"]            ;# Bank 128 - MGTHRXP3_128
set_property PACKAGE_PIN M30 [get_ports "c2c_m_gt_txn" ] ;# "SMA_MGT_TX_N"]              ;# Bank 128 - MGTHTXN3_128
set_property PACKAGE_PIN M29 [get_ports "c2c_m_gt_txp" ] ;# "SMA_MGT_TX_P"]              ;# Bank 128 - MGTHTXP3_128
set_property PACKAGE_PIN L28 [get_ports "c2c_m_gt_clkn"] ;# "USER_MGT_SI570_CLOCK1_C_N"] ;# Bank 129 - MGTREFCLK0N_129
set_property PACKAGE_PIN L27 [get_ports "c2c_m_gt_clkp"] ;# "USER_MGT_SI570_CLOCK1_C_P"] ;# Bank 129 - MGTREFCLK0P_129
create_clock -period 6.4 -name c2c_m_gt_clk [get_ports "c2c_m_gt_clkp"]

set_clock_groups -asynch \
  -group [get_clocks -include_generated_clocks clk_pl_0]     \ 
  -group [get_clocks -include_generated_clocks clk_pl_1]     \
  -group [get_clocks -include_generated_clocks clk_pl_2]     \
  -group [get_clocks -include_generated_clocks c2c_m_gt_clk] \
  -group [get_clocks -include_generated_clocks c2c_s_gt_clk] \
  -group [get_clocks -include_generated_clocks remote_infra_inst/bd_inst/c2c_s_ipb_inst/clk_wiz_0/inst/clk_in1 ] 
    
set_property PACKAGE_PIN AG14     [get_ports "leds[0]"] ;# Bank  44 VCCO - VCC3V3   - IO_L10P_AD2P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "leds[0]"] ;# Bank  44 VCCO - VCC3V3   - IO_L10P_AD2P_44
set_property PACKAGE_PIN AF13     [get_ports "leds[1]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9N_AD3N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "leds[1]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9N_AD3N_44
set_property PACKAGE_PIN AE13     [get_ports "leds[2]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9P_AD3P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "leds[2]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9P_AD3P_44
set_property PACKAGE_PIN AJ14     [get_ports "leds[3]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "leds[3]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_44
set_property PACKAGE_PIN AJ15     [get_ports "leds[4]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "leds[4]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_44
set_property PACKAGE_PIN AH13     [get_ports "leds[5]"] ;# Bank  44 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "leds[5]"] ;# Bank  44 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_44
set_property PACKAGE_PIN AH14     [get_ports "leds[6]"] ;# Bank  44 VCCO - VCC3V3   - IO_L7P_HDGC_AD5P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "leds[6]"] ;# Bank  44 VCCO - VCC3V3   - IO_L7P_HDGC_AD5P_44
set_property PACKAGE_PIN AL12     [get_ports "leds[7]"] ;# Bank  44 VCCO - VCC3V3   - IO_L6N_HDGC_AD6N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "leds[7]"] ;# Bank  44 VCCO - VCC3V3   - IO_L6N_HDGC_AD6N_44

set_property PACKAGE_PIN AK13     [get_ports "dipsw[7]"] ;# Bank  44 VCCO - VCC3V3   - IO_L6P_HDGC_AD6P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "dipsw[7]"] ;# Bank  44 VCCO - VCC3V3   - IO_L6P_HDGC_AD6P_44
set_property PACKAGE_PIN AL13     [get_ports "dipsw[6]"] ;# Bank  44 VCCO - VCC3V3   - IO_L4P_AD8P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "dipsw[6]"] ;# Bank  44 VCCO - VCC3V3   - IO_L4P_AD8P_44
set_property PACKAGE_PIN AP12     [get_ports "dipsw[5]"] ;# Bank  44 VCCO - VCC3V3   - IO_L3N_AD9N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "dipsw[5]"] ;# Bank  44 VCCO - VCC3V3   - IO_L3N_AD9N_44
set_property PACKAGE_PIN AN12     [get_ports "dipsw[4]"] ;# Bank  44 VCCO - VCC3V3   - IO_L3P_AD9P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "dipsw[4]"] ;# Bank  44 VCCO - VCC3V3   - IO_L3P_AD9P_44
set_property PACKAGE_PIN AN13     [get_ports "dipsw[3]"] ;# Bank  44 VCCO - VCC3V3   - IO_L2N_AD10N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "dipsw[3]"] ;# Bank  44 VCCO - VCC3V3   - IO_L2N_AD10N_44
set_property PACKAGE_PIN AM14     [get_ports "dipsw[2]"] ;# Bank  44 VCCO - VCC3V3   - IO_L2P_AD10P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "dipsw[2]"] ;# Bank  44 VCCO - VCC3V3   - IO_L2P_AD10P_44
set_property PACKAGE_PIN AP14     [get_ports "dipsw[1]"] ;# Bank  44 VCCO - VCC3V3   - IO_L1N_AD11N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "dipsw[1]"] ;# Bank  44 VCCO - VCC3V3   - IO_L1N_AD11N_44
set_property PACKAGE_PIN AN14     [get_ports "dipsw[0]"] ;# Bank  44 VCCO - VCC3V3   - IO_L1P_AD11P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "dipsw[0]"] ;# Bank  44 VCCO - VCC3V3   - IO_L1P_AD11P_44
