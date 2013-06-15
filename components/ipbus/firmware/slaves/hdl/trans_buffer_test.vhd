-- trans_buffer_test
--
-- Slave for testing of trans_buffer out of band access to transactor
--
-- Loc 0: data to be written or read to or from buffer
-- Loc 1: b0: write
--        b1: read
--        b2: req
--        b3: done
--
-- Clock domain crossing is not really done properly here (it's just
-- for testing), so only ever change one control bit at a time:
-- 	To write, set the data first, then assert b0.
-- 	To read, assert b1, then read the data.
--
-- Dave Newbold, March 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity trans_buffer_test is
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		clk_t: in std_logic;
		t_wdata: out std_logic_vector(15 downto 0);
		t_we: out std_logic;
		t_rdata: in std_logic_vector(15 downto 0);
		t_re: out std_logic;
		t_req: out std_logic;
		t_done: in std_logic
	);
	
end trans_buffer_test;

architecture rtl of trans_buffer_test is

	signal d, wdata_s, q, q_s: std_logic_vector(15 downto 0);
	signal cd, ctrl_s, ctrl, ctrl_d: std_logic_vector(2 downto 0);
	signal cq, cq_s: std_logic;
	
	attribute KEEP: string;
	attribute KEEP of wdata_s: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	attribute KEEP of q_s: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	attribute KEEP of ctrl_s: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	attribute KEEP of cq_s: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	
begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				d <= (others => '0');
				cd <= (others => '0');
			else
				if ipbus_in.ipb_strobe = '1' and ipbus_in.ipb_write = '1' then
					if ipbus_in.ipb_addr(0) = '0' then
						d <= ipbus_in.ipb_wdata(15 downto 0);
					else
						cd <= ipbus_in.ipb_wdata(2 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;
	
	ipbus_out.ipb_rdata <= X"0000" & q when ipbus_in.ipb_addr(0) = '0' else X"0000000" & cq & cd;
	ipbus_out.ipb_ack <= ipbus_in.ipb_strobe;
	ipbus_out.ipb_err <= '0';
	
	process(clk_t)
	begin
		if rising_edge(clk_t) then
			ctrl_s <= cd;
			ctrl <= ctrl_s;
			ctrl_d <= ctrl;
			wdata_s <= d;
			t_wdata <= wdata_s;
		end if;
	end process;
	
	t_we <= ctrl(0) and not ctrl_d(0);
	t_re <= ctrl(1) and not ctrl_d(1);
	t_req <= ctrl(2);
	
	process(clk)
	begin
		if rising_edge(clk) then
			cq_s <= t_done;
			cq <= cq_s;
			q_s <= t_rdata;
			q <= q_s;
		end if;
	end process;

end rtl;

