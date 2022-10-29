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

entity ipbus_ipb2axi4lite is
	generic(
		C_S_AXI_DATA_WIDTH: integer	:= 32;
		C_S_AXI_ADDR_WIDTH: integer	:= 32;
        AXI_ADDR_MASK: std_logic_vector(31 downto 0) := X"11111111";
        AXI_ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000"
	);
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus
		s_axi_aresetn: out std_logic;
		s_axi_awaddr: out std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_awprot: out std_logic_vector(2 downto 0);
		s_axi_awvalid: out std_logic;
		s_axi_awready: in std_logic;
		s_axi_wdata: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_wstrb: out std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
		s_axi_wvalid: out std_logic;
		s_axi_wready: in std_logic;
		s_axi_bresp: in std_logic_vector(1 downto 0);
		s_axi_bvalid: in std_logic;
		s_axi_bready: out std_logic;
		s_axi_araddr: out std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_arprot: out std_logic_vector(2 downto 0);
		s_axi_arvalid: out std_logic;
		s_axi_arready: in std_logic;
		s_axi_rdata: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_rresp: in std_logic_vector(1 downto 0);
		s_axi_rvalid: in std_logic;
		s_axi_rready: out std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus
	);
	
end ipbus_ipb2axi4lite;

architecture rtl of ipbus_ipb2axi4lite is

	signal addr: std_logic_vector(31 downto 0);
	signal axi_w_done, axi_r_done, new_cyc: std_logic;

begin

-- Address conversion

	addr <= ipb_in.ipb_addr and ADDR_MASK or ADDR_BASE;

-- ipbus handshaking

	axi_w_done <= (s_axi_bvalid and ipb_in.ipb_write and ipb_in.ipb_strobe);
	axi_r_done <= (s_axi_rvalid and not ipb_in.ipb_write and ipb_in.ipb_strobe);
	new_cyc <= axi_w_done or axi_r_done or not ipb_in.ipb_strobe;

	ipb_out.ack <= '1' when (axi_w_done = '1' and s_axi_bresp = "00") or (axi_r_done = '1' and s_axi_rresp = "00") else '0';
	ipb_out.err <= '1' when (axi_w_done = '1' and s_axi_bresp /= "00") or (axi_r_done = '1' and s_axi_rresp /= "00") else '0';

-- AW bus

	s_axi_awaddr <= addr; -- Doesn't change during bus cycle
	s_axi_awprot <= "00";

	process(ipb_clk)
	begin
		if rising_edge(ipb_clk) then
			if ipb_rst = '1' then
				s_axi_awvalid <= '0';
			elsif new_cyc = '1' then
				s_axi_awvalid <= ipb_in.ipb_strobe and ipb_in.ipb_write;
			elsif s_axi_awready = '1' then
				s_axi_awvalid <= '0';
			end if;
		end if;
	end process;

-- W bus

	s_axi_wdata	<= ipb_in.ipb_wdata; -- Doesn't change during cycle
	s_axi_wstrb <= "1111";

	process(ipb_clk)
	begin
		if rising_edge(ipb_clk) then
			if ipb_rst = '1' then
				s_axi_wvalid <= '0';
			elsif new_cyc = '1' then
				s_axi_wvalid <= ipb_in.ipb_strobe and ipb_in.ipb_write;
			elsif s_axi_wready = '1' then
				s_axi_wvalid <= '0';
			end if;
		end if;
	end process;

-- B bus

	s_axi_bready <= '1';

-- AR bus

	s_axi_araddr <= addr;
	s_axi_arprot <= "00";

	process(ipb_clk)
	begin
		if rising_edge(ipb_clk) then
			if ipb_rst = '1' then
				s_axi_arvalid <= '0';
			elsif new_cyc = '1' then
				s_axi_arvalid <= ipb_in.ipb_strobe and not ipb_in.ipb_write;
			elsif s_axi_arready = '1' then
				s_axi_arvalid <= '0';
			end if;
		end if;
	end process;

-- R bus

	s_axi_rready <= '1';
	ipb_out.ipb_rdata <= s_axi_rdata;

-- axi reset

	s_axi_aresetn <= ipb_rst;

end rtl;
