-- ipbus_ipb2axi4lite
--
-- This block bridges ipbus to axi4lite, acting as an ipbus slave and an axi4lite master.
-- It always produces 32b aligned accesses on the axi4lite bus.
--
-- Dave Newbold, 29/10/22

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ipbus;
use work.ipbus.all;
use work.ipbus_axi4lite_decl.all;

entity ipbus_ipb2axi4lite is
	generic(
        ADDR_MASK: std_logic_vector(31 downto 0) := X"11111111";
        ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000"
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
	signal axi_w_done, axi_r_done, new_cyc: std_logic;

begin

-- Address conversion

	addr <= ipb_in.ipb_addr and ADDR_MASK or ADDR_BASE;

-- ipbus handshaking

	axi_w_done <= (axi_in.bvalid and ipb_in.ipb_write and ipb_in.ipb_strobe);
	axi_r_done <= (axi_in.rvalid and not ipb_in.ipb_write and ipb_in.ipb_strobe);
	new_cyc <= axi_w_done or axi_r_done or not ipb_in.ipb_strobe;

	ipb_out.ack <= '1' when (axi_w_done = '1' and axi_in.bresp = "00") or (axi_r_done = '1' and axi_in.rresp = "00") else '0';
	ipb_out.err <= '1' when (axi_w_done = '1' and axi_in.bresp /= "00") or (axi_r_done = '1' and axi_in.rresp /= "00") else '0';

-- AW bus

	axi_out.awaddr <= addr; -- Doesn't change during bus cycle
	axi_out.awprot <= "00";

	process(ipb_clk)
	begin
		if rising_edge(ipb_clk) then
			if ipb_rst = '1' then
				axi_out.awvalid <= '0';
			elsif new_cyc = '1' then
				axi_out.awvalid <= ipb_in.ipb_strobe and ipb_in.ipb_write;
			elsif s_axi_awready = '1' then
				axi_out.awvalid <= '0';
			end if;
		end if;
	end process;

-- W bus

	axi_out.wdata <= ipb_in.ipb_wdata; -- Doesn't change during cycle
	axi_out.wstrb <= "1111";

	process(ipb_clk)
	begin
		if rising_edge(ipb_clk) then
			if ipb_rst = '1' then
				axi_out.wvalid <= '0';
			elsif new_cyc = '1' then
				axi_out.wvalid <= ipb_in.ipb_strobe and ipb_in.ipb_write;
			elsif s_axi_wready = '1' then
				axi_out.wvalid <= '0';
			end if;
		end if;
	end process;

-- B bus

	axi_out.bready <= '1';

-- AR bus

	axi_out.araddr <= addr;
	axi_out.arprot <= "00";

	process(ipb_clk)
	begin
		if rising_edge(ipb_clk) then
			if ipb_rst = '1' then
				axi_out.arvalid <= '0';
			elsif new_cyc = '1' then
				axi_out.arvalid <= ipb_in.ipb_strobe and not ipb_in.ipb_write;
			elsif s_axi_arready = '1' then
				axi_out.arvalid <= '0';
			end if;
		end if;
	end process;

-- R bus

	axi_out.rready <= '1';
	ipb_out.ipb_rdata <= axi_in.rdata;

-- axi reset

	axi_out.rstn <= not ipb_rst;

end rtl;
