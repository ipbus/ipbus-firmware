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

entity rx_buffer is
	port(
		clk: in std_logic;
		rst: in std_logic;
		rx_data: in std_logic_vector(7 downto 0);
		rx_valid: in std_logic;
		rx_last: in std_logic;
		rx_error: in std_logic;
		packet_rxd: out std_logic_vector(7 downto 0);
		packet_rxa: in pbuf_a;
		packet_len: out pbuf_a;
		packet_rxready: out std_logic;
		packet_rxdone: in std_logic
	);

end rx_buffer;

architecture rtl of rx_buffer is

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

	type state_type is (ST_WAIT, ST_RX, ST_FULL);
	signal state: state_type;
	signal buf_wen: std_logic;
	signal buf_wen_v: std_logic_vector(0 downto 0);
	signal waddr: pbuf_a_us;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				state <= ST_WAIT;
			else
				case state is
				when ST_WAIT =>
					if rx_valid = '1' then
						state <= ST_RX;
					else
						state <= ST_WAIT;
					end if;
				when ST_RX =>
					if rx_last = '1' then
						if rx_error = '1' then
							state <= ST_WAIT;
						else
							state <= ST_FULL;
						end if;
					else
						state <= ST_RX;
					end if;
				when ST_FULL =>
					if packet_rxdone = '1' then
						state <= ST_WAIT;
					else
						state <= ST_FULL;
					end if;
				end case;
			end if;
		end if;
	end process;

	buf_wen <= '0' when state = ST_FULL else '1';
	buf_wen_v(0) <= buf_wen;
	packet_rxready <= '1' when state=ST_FULL else '0';
	packet_len <= std_logic_vector(waddr);

	process(clk)
	begin
		if rising_edge(clk) then
			if state = ST_WAIT then
				waddr <= to_unsigned(1, waddr'length);
			elsif rx_valid = '1' and buf_wen = '1' then
				waddr <= waddr + 1;
			end if;				
		end if;
	end process;

	buf: sdpram_8x11 port map(
		clka => clk,
		wea(0) => buf_wen,
		addra => std_logic_vector(waddr),
		dina => rx_data,
		clkb => clk,
		addrb => packet_rxa,
		doutb => packet_rxd
	);

end rtl;