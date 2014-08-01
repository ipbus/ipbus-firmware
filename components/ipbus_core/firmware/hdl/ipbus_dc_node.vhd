-- ipbus_dc_node
--
-- Bridge from daisy-chain style ipbus implementation to ipbus slave
--
-- Dave Newbold, July 2014

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.ALL;

entity ipbus_dc_node is
  generic(
  	I_SLV: integer;
  	SEL_WIDTH: integer := 5
   );
  port(
  	clk: in std_logic;
  	rst: in std_logic;
    ipb_out: out ipb_wbus;
    ipb_in: in ipb_rbus;
    ipbdc_in: in ipbdc_bus;
    ipbdc_out: out ipbdc_bus
   );

end ipbus_dc_node;

architecture rtl of ipbus_dc_node is

	signal resp, sel, stb: std_logic;
	
begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				sel <= '0';
			elsif ipbdc_in.phase = "00" and ipbdc_in.flag = '1' then
				if ipbdc_in.ad(SEL_WIDTH - 1 downto 0) = std_logic_vector(to_unsigned(I_SLV, SEL_WIDTH)) then
					sel <= '1';
				else
					sel <= '0';
				end if;
			elsif ipbdc_in.phase = "01" then
				ipb_out.ipb_addr <= ipbdc_in.ad;
				ipb_out.ipb_write <= ipbdc_in.flag;
			end if;
		end if;
	end process;

	ipb_out.ipb_wdata <= ipbdc_in.ad;
	
	resp <= ipb_in.ipb_ack or ipb_in.ipb_err;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if resp = '1' or sel = '0' then
				stb <= '0';
			elsif ipbdc_in.phase = "10" then
				stb <= '1';
			end if;
		end if;
	end process;
	
	ipb_out.ipb_strobe <= stb;

	process(clk)
	begin
		if rising_edge(clk) then
			if resp = '1' and sel = '1' then
				ipbdc_out.phase <= "11";
				ipbdc_out.ad <= ipb_in.ipb_rdata;
				ipbdc_out.flag <= ipb_in.ipb_ack;
			else
				ipbdc_out.phase <= ipbdc_in.phase;
				ipbdc_out.ad <= ipbdc_in.ad;
				ipbdc_out.flag <= ipbdc_in.flag;
			end if;
		end if;
	end process;
  
end rtl;

