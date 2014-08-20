-- big_fifo_72
--
-- Parametrised depth single-clock FIFO based on 7-series FIFO36E1 in 72bit mode
--
-- Dave Newbold, August 2014

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.VComponents.all;

entity big_fifo_72 is
	generic(
		N_FIFO: positive
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		d: in std_logic_vector(71 downto 0);
		wen: in std_logic;
		full: out std_logic;
		half_full: out std_logic;
		ren: in std_logic;
		q: out std_logic_vector(71 downto 0);
		valid: out std_logic_vector
	);

end big_fifo_72;

architecture rtl of big_fifo_72 is

	signal full, afull, empty, en: std_logic_vector(N_FIFO downto 0);
	type fifo_d_t is array(N_FIFO downto 0) of std_logic_vector(71 downto 0);
	signal fifo_d: fifo_d_t;

begin

	fifo_d(0) <= d;
	en(0) <= wen;
	en(N_FIFO) <= ren;

	fifo_gen: for i in N_FIFO - 1 downto 0 generate
	
	begin
	
		fifo: FIFO36E1
			generic map(
				ALMOST_FULL_OFFSET => 13'h0fff,
				DATA_WIDTH => 72,
				FIFO_MODE => "FIFO36_72",
				FIRST_WORD_FALL_THROUGH => true
			)
			port map(
				almostfull => afull(i),
				di => fifo_d(i)(63 downto 0),
				dip => fifo_d(i)(71 downto 64),
				do => fifo_d(i + 1)(63 downto 0),
				dop => fifo_d(i + 1)(71 downto 64),
				empty => empty(i),
				full => full(i),
				rdclk => clk,
				rden => en(i + 1),
				regce => '1',
				rst => rst,
				rstreg => rst,
				wrclk => clk,
				wren => en(i)
			);
		
	end generate;
	
	en(N_FIFO - 1 downto 1) <= not full(N_FIFO - 1 downto 1) and not empty(N_FIFO - 2 downto 0);
	
	q <= fifo_d(N_FIFO - 1);
	valid <= not empty(N_FIFO - 1);
	full <= full(0);
	half_full <= full(N_FIFO / 2 - 1) when N_FIFO mod 2 = 0 else afull((N_FIFO - 1) / 2);
	
end rtl;

