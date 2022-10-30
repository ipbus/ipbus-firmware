library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ipbus;
use work.ipbus.all;

entity ipbus_axi4lite2ipb is
	generic(
		C_S_AXI_DATA_WIDTH: integer	:= 32;
		C_S_AXI_ADDR_WIDTH: integer	:= 32;
        IPB_ADDR_MASK: std_logic_vector(31 downto 0) := X"11111111"; -- do this
        IPB_ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000" -- do this
	);
	port(
		s_axi_aclk: in std_logic;
		s_axi_aresetn: in std_logic;
		s_axi_awaddr: in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0); 
		s_axi_awprot: in std_logic_vector(2 downto 0);
		s_axi_awvalid: in std_logic;
		s_axi_awready: out std_logic;
		s_axi_wdata: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_wstrb: in std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
		s_axi_wvalid: in std_logic;
		s_axi_wready: out std_logic;
		s_axi_bresp: out std_logic_vector(1 downto 0);
		s_axi_bvalid: out std_logic;
		s_axi_bready: in std_logic;
		s_axi_araddr: in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_arprot: in std_logic_vector(2 downto 0);
		s_axi_arvalid: in std_logic;
		s_axi_arready: out std_logic;
		s_axi_rdata: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_rresp: out std_logic_vector(1 downto 0);
		s_axi_rvalid: out std_logic;
		s_axi_rready: in std_logic;
		ipb_out: out ipb_wbus;
		ipb_in: in ipb_rbus
	);
end ipbus_axi4lite2ipb;

architecture rtl of ipbus_axi4lite2ipb is

	signal waddr, wdata, raddr: std_logic_vector(31 downto 0);
	signal wstrb: std_logic_vector(3 downto 0);
	signal aw_en, w_en, ar_en, w_v, r_v: std_logic;
	signal new_cyc, bwait, rwait: std_logic;

begin

	new_cyc <= XXX?

-- AW bus

	process(s_axi_aclk)
	begin
		if rising_edge(s_axi_clk) then
			if s_axi_aresetn = '0' or new_cyc = '1' then
				aw_en <= '1';
			elsif s_axi_awvalid = '1' then
				aw_en <= '0';
			end if;
		end if;
	end process;

	s_axi_awready <= aw_en;

	process(s_axi_awaddr, aw_en) -- Yes, it's a latch. Move on, nothing to see here.
	begin
		if aw_en = '1' then
			waddr <= s_axi_awaddr;
		end if;
	end process;

-- W bus

	process(s_axi_aclk)
	begin
		if rising_edge(s_axi_clk) then
			if s_axi_aresetn = '0' or new_cyc = '1' then
				w_en <= '1';
			elsif s_axi_awvalid = '1' then
				w_en <= '0';
			end if;
		end if;
	end process;

	s_axi_wready <= w_en;

	process(s_axi_wdata, w_en) -- Yes, it's a latch. Move on, nothing to see here.
	begin
		if aw_en = '1' then
			wdata <= s_axi_wdata;
			if s_axi_wstrb = "1111" then
				wstrb_ok <= '1';
			else
				wstrb_ok <= '0';
			end if;
		end if;
	end process;

	w_v <= (s_axi_awvalid or not aw_en) and wstrb_ok and (s_axi_awvalid or not aw_en); -- Need address and data valid to proceed

-- AR bus

	process(s_axi_aclk)
	begin
		if rising_edge(s_axi_clk) then
			if s_axi_aresetn = '0' or new_cyc = '1' then
				ar_en <= '1';
			elsif s_axi_arvalid = '1' then
				ar_en <= '0';
			end if;
		end if;
	end process;

	s_axi_arready <= ar_en;

	process(s_axi_awaddr, ar_en) -- Yes, it's a latch. Move on, nothing to see here.
	begin
		if ar_en = '1' then
			raddr <= s_axi_araddr;
		end if;
	end process;

	r_v <= s_axi_arvalid or not ar_en;

-- RW arbitration

	stb <= w_v or r_v;

	process(w_v, new_cyc)
	begin
		if new_cyc = '1' then
			write <= w_v; -- Write takes priority
		end if;
	end process;

-- ipbus handshaking

	ipb_out.ipb_addr <= waddr when write = '1' else raddr;
	ipb_out.ipb_write <= write;
	ipb_out.ipb_wdata <= wdata;
	ipb_out.ipb_strobe <= stb and not (bwait or rwait);

	ack <= (ipb_in.ipb_ack or ipb_in.ipb_err);
	new_cyc <= ack or not stb;

	process(ipb_in.ipb_rdata, )

-- B bus

	s_axi_bresp <= "00" when ipb_in.ipb_ack = '1' else "10";
	s_axi_bvalid <= ack;
	bwait <= (bwait or ack) and not s_axi_bready and s_axi_aresetn when rising_edge(s_axi_aclk);


-- ipbus reset

	ipb_rst <= not s_axi_aresetn;

end rtl;
