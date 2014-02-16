-- ipbus_freq_ctr
--
-- Simple clock monitor (inspired by Greg's version)
-- Counts number of pulses on a number of incoming clocks in 64k cycles of ipbus clock
-- i.e. for ~32MHz ipb clock, deals with up to 500MHz.
-- Will not deal with very slow clocks (<10MHz) reliably.
--
-- Dave Newbold, June 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_freq_ctr is
	generic(addr_width: natural := 0);
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clkin: in std_logic_vector(2 ** addr_width - 1 downto 0)
	);
	
end ipbus_freq_ctr;

architecture rtl of ipbus_freq_ctr is

	constant n_clk: natural := 2 ** addr_width;
	signal ctr_s: unsigned(15 downto 0) := X"0000";
	type ctr_array is array(n_clk - 1 downto 0) of unsigned(23 downto 0);
	signal ctr: ctr_array := (others => X"000000");
	signal samp, samp_i: ctr_array;
	signal go: std_logic;
	signal go_s, go_s2, go_s3: std_logic_vector(n_clk - 1 downto 0);
	signal sel: integer := 0;
	
	attribute KEEP: string;
	attribute KEEP of go_s: signal is "TRUE"; -- Synchroniser not to be optimised into shreg

begin

	process(clk)
	begin
		if rising_edge(clk) then
			ctr_s <= ctr_s + 1;
			if ctr_s = X"0010" then
				samp_i <= samp; -- Samp has long settling time to avoid domain crossing problems
			end if;
		end if;
	end process;
	
	go <= '1' when ctr_s = X"0000" else '0';

	sel <= to_integer(unsigned(ipb_in.ipb_addr(addr_width - 1 downto 0))) when addr_width > 0 else 0;	
	ipb_out.ipb_rdata <= X"00" & std_logic_vector(samp_i(sel));
	ipb_out.ipb_ack <= ipb_in.ipb_strobe and not ipb_in.ipb_write;
	ipb_out.ipb_err <= '0';

	c_gen: for i in n_clk - 1 downto 0 generate
		process(clkin(i))
		begin
			if rising_edge(clkin(i)) then
				go_s(i) <= go;
				go_s2(i) <= go_s(i);
				go_s3(i) <= go_s2(i);
				ctr(i) <= ctr(i) + 1;
				if go_s2(i) = '1' and go_s3(i) = '0' then
					samp(i) <= ctr(i);
					ctr(i) <= X"000000";
				else
					ctr(i) <= ctr(i) + 1;
				end if;
			end if;
		end process;
	end generate;

end rtl;
