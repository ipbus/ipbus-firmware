create_clock -name "clk"    -period "100 MHz"    [get_ports "clk"]
create_clock -name "refclk" -period "156.25 MHz" [get_ports "refclk"]

derive_clock_uncertainty