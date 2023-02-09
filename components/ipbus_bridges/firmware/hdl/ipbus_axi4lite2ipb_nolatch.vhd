-- ipbus_axi4lite2ipb
--
-- This block bridges axi4lite to ipbus, acting as an AXI4 slave and an ipbus master.
-- It will only respond to fully-aligned 32b data accesses
-- AXI byte addresses are converted to ipbus word addresses internally
--
-- Dave Newbold, 30/10/22

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_axi4lite_decl.all;

entity ipbus_axi4lite2ipb is
	generic(
        IPB_ADDR_MASK: std_logic_vector(31 downto 0) := X"ffffffff";
        IPB_ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000"
	);
	port(
		axi_clk: in std_logic;
		axi_rstn: in std_logic;
		axi_in: in ipb_axi4lite_mosi;
		axi_out: out ipb_axi4lite_miso;
		ipb_out: out ipb_wbus;
		ipb_in: in ipb_rbus;
		ipb_rst: out std_logic
	);
	
end ipbus_axi4lite2ipb;

architecture rtl of ipbus_axi4lite2ipb is

    signal ack, iack, wrdy, rrdy, rwait, l_ack, l_err: std_logic;
    signal addr, l_rdata: std_logic_vector(31 downto 0);
	
begin

-- AW / W busses

    axi_out.awready <= iack and wrdy;
    axi_out.wready <= iack and wrdy;
    wrdy <= '1' when axi_in.awvalid = '1' and axi_in.wvalid = '1' and axi_in.wstrb = "1111" else '0';

-- AR bus

    axi_out.arready <= iack and rrdy and not wrdy;
    rrdy <= axi_in.arvalid;

-- ipbus output

    addr <= axi_in.awaddr when wrdy = '1' else axi_in.araddr;
    ipb_out.ipb_addr <= (("00" & addr(31 downto 2)) and IPB_ADDR_MASK) or IPB_ADDR_BASE; -- axi byte address to ipbus word address
    ipb_out.ipb_wdata <= axi_in.wdata;
    ipb_out.ipb_write <= wrdy;
    ipb_out.ipb_strobe <= (wrdy or rrdy) and not rwait;

-- ipbus input

    process(axi_clk)
    begin
        if rising_edge(axi_clk) and rwait = '0' then
            l_rdata <= ipb_in.ipb_rdata;
            l_ack <= ipb_in.ipb_ack;
            l_err <= ipb_in.ipb_err;
        end if;
    end process;

    ack <= (l_ack or l_err) and axi_rstn;
    rwait <= ack and not ((wrdy and axi_in.bready) or (not wrdy and axi_in.rready));
    iack <= ack and not rwait;

-- B bus

	axi_out.bresp <= "00" when l_ack = '1' else "10";
	axi_out.bvalid <= ack and wrdy;

-- R bus

    axi_out.rdata <= l_rdata;
    axi_out.rresp <= "00" when l_ack = '1' else "10";
	axi_out.rvalid <= ack and not wrdy;

-- ipbus reset

	ipb_rst <= not axi_rstn;

end rtl;
