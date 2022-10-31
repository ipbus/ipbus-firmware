-- ipbus_ipb2axi4lite
--
-- This block bridges ipbus to axi4lite, acting as an ipbus slave and an axi4lite master.
-- It always produces 32b fully-aligned accesses on the axi4lite bus.
-- Ipbus word addresses are converted to AXI byte addresses internally
--
-- Dave Newbold, 29/10/22

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_axi4lite_decl.all;

entity ipbus_ipb2axi4lite is
	generic(
        AXI_ADDR_MASK: std_logic_vector(31 downto 0) := X"11111111";
        AXI_ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000"
	);
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		axi_out: out ipb_axi4lite_mosi;
		axi_in: in ipb_axi4lite_miso;
		axi_rstn: out std_logic
	);

end ipbus_ipb2axi4lite;

architecture rtl of ipbus_ipb2axi4lite is

	signal addr: std_logic_vector(31 downto 0);
	signal axi_w_done, axi_r_done, strobe_d, new_cyc: std_logic;
	signal awkill, wkill, arkill: std_logic;

begin

-- Address conversion

	addr <= ((ipb_in.ipb_addr(29 downto 0) & "00") and AXI_ADDR_MASK) or AXI_ADDR_BASE; -- ipbus word address to axi byte address

-- ipbus handshaking

	axi_w_done <= (axi_in.bvalid and ipb_in.ipb_write and ipb_in.ipb_strobe);
	axi_r_done <= (axi_in.rvalid and not ipb_in.ipb_write and ipb_in.ipb_strobe);
	strobe_d <= ipb_in.ipb_strobe when rising_edge(ipb_clk);
	new_cyc <= axi_w_done or axi_r_done or not strobe_d;

	ipb_out.ipb_ack <= '1' when (axi_w_done = '1' and axi_in.bresp = "00") or (axi_r_done = '1' and axi_in.rresp = "00") else '0';
	ipb_out.ipb_err <= '1' when (axi_w_done = '1' and axi_in.bresp /= "00") or (axi_r_done = '1' and axi_in.rresp /= "00") else '0';

-- AW bus

	axi_out.awaddr <= addr; -- Doesn't change during bus cycle
	axi_out.awprot <= "000";
	axi_out.awvalid <= ipb_in.ipb_strobe and ipb_in.ipb_write and not awkill;
	awkill <= axi_in.awready and not new_cyc when rising_edge(ipb_clk);

-- W bus

	axi_out.wdata <= ipb_in.ipb_wdata; -- Doesn't change during cycle
	axi_out.wstrb <= "1111";
	axi_out.wvalid <= ipb_in.ipb_strobe and ipb_in.ipb_write and not wkill;
	wkill <= axi_in.wready and not new_cyc when rising_edge(ipb_clk);

-- B bus

	axi_out.bready <= '1';

-- AR bus

	axi_out.araddr <= addr; -- Doesn't change during bus cycle
	axi_out.arprot <= "000";
	axi_out.arvalid <= ipb_in.ipb_strobe and not ipb_in.ipb_write and not arkill;
	arkill <= axi_in.arready and not new_cyc when rising_edge(ipb_clk);

-- R bus

	axi_out.rready <= '1';
	ipb_out.ipb_rdata <= axi_in.rdata;

-- axi reset

	axi_rstn <= not ipb_rst;

end rtl;
