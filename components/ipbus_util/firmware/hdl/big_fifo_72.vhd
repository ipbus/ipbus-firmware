-- big_fifo_72
--
-- Parametrised depth single-clock FIFO based on 7-series FIFO36E1 in 72bit mode
--
-- Dave Newbold, August 2014

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus_reg_types.all;

library unisim;
use unisim.VComponents.all;

entity big_fifo_72 is
	generic(
		N_FIFO: positive;
		WARN_HWM: integer; -- assert warning at high watermark
		WARN_LWM: integer -- deassert warning at low watermark
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		d: in std_logic_vector(71 downto 0);
		wen: in std_logic;
		full: out std_logic;
		empty: out std_logic;
		warn: out std_logic;
		ren: in std_logic;
		q: out std_logic_vector(71 downto 0);
		valid: out std_logic
	);

end big_fifo_72;

architecture rtl of big_fifo_72 is

	signal en: std_logic_vector(N_FIFO  downto 0);
	signal ifull, iempty: std_logic_vector(N_FIFO- 1  downto 0);
	signal rsti, warn_i: std_logic;
	type fifo_d_t is array(N_FIFO downto 0) of std_logic_vector(71 downto 0);
	signal fifo_d: fifo_d_t;
	signal rst_ctr: unsigned(2 downto 0);
	signal ctr: unsigned(calc_width(N_FIFO) + 8 downto 0);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				rst_ctr <= "000";
			elsif rsti = '1' then
				rst_ctr <= rst_ctr + 1;
			end if;
		end if;
	end process;
	
	rsti <= '0' when rst_ctr = "111" else '1';

	fifo_d(0) <= d;
	en(0) <= wen and not rsti;
	en(N_FIFO) <= ren and not rsti;

	fifo_gen: for i in N_FIFO - 1 downto 0 generate
	
	begin
	
		fifo: FIFO36E1
			generic map(
				DATA_WIDTH => 72,
				FIFO_MODE => "FIFO36_72",
				FIRST_WORD_FALL_THROUGH => true
			)
			port map(
				di => fifo_d(i)(63 downto 0),
				dip => fifo_d(i)(71 downto 64),
				do => fifo_d(i + 1)(63 downto 0),
				dop => fifo_d(i + 1)(71 downto 64),
				empty => iempty(i),
				full => ifull(i),
				injectdbiterr => '0',
				injectsbiterr => '0',
				rdclk => clk,
				rden => en(i + 1),
				regce => '1',
				rst => rsti,
				rstreg => '0',
				wrclk => clk,
				wren => en(i)
			);
		
	end generate;
	
	en(N_FIFO - 1 downto 1) <= not ifull(N_FIFO - 1 downto 1) and not iempty(N_FIFO - 2 downto 0) and not (N_FIFO - 2 downto 0 => rsti);
	
	q <= fifo_d(N_FIFO);
	valid <= not iempty(N_FIFO - 1);
	full <= ifull(0);
	empty <= iempty(N_FIFO - 1);

	process(clk)
	begin
		if rising_edge(clk) then
			if rsti = '1' then
				ctr <= (others => '0');
			elsif en(0) = '1' and en(N_FIFO) = '0' then
				ctr <= ctr + 1;
			elsif en(0) = '0' and en(N_FIFO) = '1' then
				ctr <= ctr - 1;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if rsti = '1' then
				warn_i <= '0';
			elsif warn_i = '0' and ctr > to_unsigned(WARN_HWM, ctr'length) then
				warn_i <= '1';
			elsif warn_i = '1' and ctr < to_unsigned(WARN_LWM, ctr'length) then
				warn_i <= '0';
			end if;
		end if;
	end process;
	
	warn <= warn_i;
	
end rtl;
