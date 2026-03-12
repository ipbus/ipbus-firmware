# Pin & Location Assignments
# ==========================
set_location_assignment PIN_DM22 -to clk              -comment IOBANK_2C
set_location_assignment PIN_BF54 -to refclk           -comment IOBANK_12C
set_location_assignment PIN_AE65 -to rx_serial_data   -comment IOBANK_12C
set_location_assignment PIN_AD64 -to rx_serial_data_n -comment IOBANK_12C
set_location_assignment PIN_AF62 -to tx_serial_data   -comment IOBANK_12C
set_location_assignment PIN_AG61 -to tx_serial_data_n -comment IOBANK_12C

# Fitter Assignments
# ==================
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to clk              -entity top
# set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK"              -to clk              -entity top
set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)"    -to refclk           -entity top
# set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK"              -to refclk           -entity top

set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to rx_serial_data   -entity top
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to rx_serial_data_n -entity top
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to tx_serial_data   -entity top
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to tx_serial_data_n -entity top