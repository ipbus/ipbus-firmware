-- New-style rx buffer (with AXI4-style interface)
--
-- This is destined to go away in ipbus v2.0
--
-- Dave Newbold, July 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library work;
use work.ipbus.all;
use work.ipbus_bus_decl.all;

entity tx_buffer is
	port(
		clk: in std_logic;
		rst: in std_logic;
		packet_txd: in std_logic_vector(7 downto 0);
		packet_addr: in pbuf_a;
		packet_we: in std_logic;
		packet_done: in std_logic;
		packet_len: in pbuf_a;
		tx_data: out std_logic_vector(7 downto 0);
		tx_valid: out std_logic;
		tx_last: out std_logic;
		tx_error: out std_logic;
		tx_ready: in std_logic
	);

end tx_buffer;

architecture rtl of tx_buffer is

	COMPONENT sdpram_8x11
	  PORT (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 clkb : IN STD_LOGIC;
		 addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		 doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	END COMPONENT;

	type state_type is (ST_WAIT, ST_TX);
	signal state: state_type;
	signal raddr, len: pbuf_a_us;
	signal tx_valid_i, tx_last_i, re, pdone_d, done, clkn: std_logic;
	signal buf_data: std_logic_vector(7 downto 0);

begin

	done <= packet_done and not pdone_d;

	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				state <= ST_WAIT;
			else
				case state is
				when ST_WAIT =>
					if done = '1' then
						state <= ST_TX;
					else
						len <= unsigned(packet_len);
						state <= ST_WAIT;
					end if;
				when ST_TX =>
					if raddr = len then
						state <= ST_WAIT;
					else
						state <= ST_TX;
					end if;
				end case;
			end if;
		end if;
	end process;

	tx_valid_i <= '1' when state = ST_TX else '0';
	tx_last_i <= '1' when state = ST_TX and raddr = len else '0';
	tx_error <= '0';
	
	re <= (tx_valid_i and tx_ready) or done;

	process(clk)
	begin
		if rising_edge(clk) then
			pdone_d <= packet_done;
			tx_valid <= tx_valid_i;
			tx_last <= tx_last_i;
			if re = '1' then
				tx_data <= buf_data; -- Register after RAM to improve timing
				raddr <= raddr + 1;
			elsif tx_valid_i = '0' then
				raddr <= (others => '0');
			end if;
		end if;
	end process;

	clkn <= not clk;

	buf: sdpram_8x11 port map(
		clka => clk,
		wea(0) => packet_we,
		addra => packet_addr,
		dina => packet_txd,
		clkb => clkn, -- Nota bene
		addrb => std_logic_vector(raddr),
		doutb => buf_data
	);

end rtl;