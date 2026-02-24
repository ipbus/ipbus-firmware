set_global_assignment -name LAST_QUARTUS_VERSION "24.3.1 Pro Edition"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name FAMILY "Agilex 7"
set_global_assignment -name DEVICE AGIC040R39A2E2VR0
set_global_assignment -name BOARD "Agilex 7 FPGA I-Series Transceiver Development Kit 6x F-Tile DK-SI-AGI040FES"
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE LTC3888
set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 62
set_global_assignment -name PWRMGT_SLAVE_DEVICE1_ADDRESS 00
set_global_assignment -name PWRMGT_SLAVE_DEVICE2_ADDRESS 00
set_global_assignment -name ACTIVE_SERIAL_CLOCK AS_FREQ_100MHZ
set_global_assignment -name USE_PWRMGT_SCL SDM_IO0
set_global_assignment -name USE_PWRMGT_SDA SDM_IO12
set_global_assignment -name USE_CONF_DONE SDM_IO16
set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ
set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE ON