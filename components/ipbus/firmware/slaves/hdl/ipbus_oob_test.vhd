-- Block for testing of transactor OOB interface

-- Dave Newbold, July 2011
--
-- $Id$

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
use work.ipbus.all;
use work.bus_arb_decl.all;

entity ipbus_oob_test is
	port(
		clk: in STD_LOGIC;
		reset: in STD_LOGIC;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		moti: out trans_moti;
		tomi: in trans_tomi);
	
end ipbus_oob_test;

architecture rtl of ipbus_oob_test is

	COMPONENT dpram_32x10b_32x10b PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
	END COMPONENT;

	signal d_req, d_resp, ram_d: std_logic_vector(31 downto 0);
	signal we_req, we_resp, web_resp: std_logic_vector(0 downto 0); -- Coping with nonsense from Xilinx coregen
	signal reg_en, ack: std_logic;
	
begin

  ipbus_out.ipb_rdata <= ram_d when reg_en = '0' else (0 => tomi.done, others => '0');
  ram_d <= d_req when ipbus_in.ipb_addr(10) = '0' else d_resp;
  we_req(0) <= ipbus_in.ipb_write and ipbus_in.ipb_strobe and not ipbus_in.ipb_addr(10);
  we_resp(0) <= ipbus_in.ipb_write and ipbus_in.ipb_strobe and ipbus_in.ipb_addr(10);
  
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        moti.ready <= '0';
      else
        ack <= ipbus_in.ipb_strobe and not ack;
        if ipbus_in.ipb_strobe = '1' and ipbus_in.ipb_write = '1' and reg_en = '1' then
          moti.ready <= ipbus_in.ipb_wdata(0);
        end if;
      end if;
    end if;
  end process;
  
  ipbus_out.ipb_ack <= ack;
  ipbus_out.ipb_err <= '0';
  
  moti.addr_rst <= '1';

  reg_en <= '1' when ipbus_in.ipb_addr(9 downto 0) = (9 downto 0 => '1') else '0';
  
	req_ram: dpram_32x10b_32x10b port map(
		clka => clk,
		wea => we_req,
		addra => ipbus_in.ipb_addr(9 downto 0),
		dina => ipbus_in.ipb_wdata,
		douta => d_req,
		clkb => clk,
		web => (0 => '0'),
		addrb => tomi.raddr,
		dinb => (31 downto 0 => '0'),
		doutb => moti.rdata
	);
	
	resp_ram: dpram_32x10b_32x10b port map(
		clka => clk,
		wea => we_resp,
		addra => ipbus_in.ipb_addr(9 downto 0),
		dina => ipbus_in.ipb_wdata,
		douta => d_resp,
		clkb => clk,
		web => web_resp,
		addrb => tomi.waddr,
		dinb => tomi.wdata,
		doutb => open
	);

  web_resp(0) <= tomi.we;

end rtl;
