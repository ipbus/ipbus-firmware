-- UDP_master_fifo
--  Dave Sankey Oct 2015
-- derived from http://www.deathbylogic.com/2015/01/vhdl-first_macclk-word-fall-through-fifo/
-- modified to have additional port master_tx_pause driven high when half full
-- (as a consequence of which FIFO depth needs to be a power of 2, hence recast as BUFWIDTH)
-- and to drive AXI stream interface of Xilinx MAC
--
-- FIFO needs to be deep enough that remote end reacts to master_tx_pause before FIFO either fills or empties

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
entity UDP_master_fifo is
	Generic (
		constant BUFWIDTH: positive := 4
	);
	Port ( 
		mac_clk		: in  STD_LOGIC;
		rst_macclk	: in  STD_LOGIC;
		FIFO_WriteEn	: in  STD_LOGIC;
		FIFO_Data	: in  STD_LOGIC_VECTOR (9 downto 0);
		FIFO_Full	: out STD_LOGIC;
		master_tx_pause	: out STD_LOGIC;
		mac_tx_ready	: in  STD_LOGIC;
		mac_tx_data	: out STD_LOGIC_VECTOR (7 downto 0);
		mac_tx_error	: out STD_LOGIC;
		mac_tx_last	: out STD_LOGIC;
		mac_tx_valid	: out STD_LOGIC
	);
end UDP_master_fifo;
 
architecture Behavioral of UDP_master_fifo is
 
begin
 
	-- Memory Pointer Process
	fifo_proc : process (mac_clk)
		type FIFO_Memory is array (0 to 2**BUFWIDTH - 1) of STD_LOGIC_VECTOR (9 downto 0);
		variable Memory : FIFO_Memory;
		variable DataOut: STD_LOGIC_VECTOR (9 downto 0);
		variable Head : natural range 0 to 2**BUFWIDTH - 1;
		variable Tail : natural range 0 to 2**BUFWIDTH - 1;
		variable FillLevel : unsigned(BUFWIDTH downto 0);
		
		variable Looped : boolean;
		variable Running : STD_LOGIC;
	begin
		if rising_edge(mac_clk) then
			if rst_macclk = '1' then
				Head := 0;
				Tail := 0;
				DataOut := (Others => '0');
				Looped := false;
			else
				if (mac_tx_ready = '1') then
					if ((Looped = true) or (Head /= Tail)) then
						-- Update Tail pointer as needed
						if (Tail = 2**BUFWIDTH - 1) then
							Tail := 0;
							Looped := false;
						else
							Tail := Tail + 1;
						end if;
					end if;
				end if;
				
				if (FIFO_WriteEn = '1') then
					if ((Looped = false) or (Head /= Tail)) then
						-- Write Data to Memory
						Memory(Head) := FIFO_Data;
						
						-- Increment Head pointer as needed
						if (Head = 2**BUFWIDTH - 1) then
							Head := 0;
							Looped := true;
						else
							Head := Head + 1;
						end if;
					end if;
				end if;
				
				-- Update data to be output
				DataOut := Memory(Tail);
			end if;

			if Looped then
				FillLevel := to_unsigned(2**BUFWIDTH + Head - Tail, BUFWIDTH + 1);
			else
				FillLevel := to_unsigned(Head - Tail, BUFWIDTH + 1);
			end if;

			-- Start running when FIFO is half full
			if FillLevel(BUFWIDTH - 1) = '1' then
				Running := '1';
			end if;

			FIFO_Full <= FillLevel(BUFWIDTH);  -- bad things are happening...
			master_tx_pause <= FillLevel(BUFWIDTH - 1);
			mac_tx_valid <= Running;
			mac_tx_data <= DataOut(9 downto 2);
			mac_tx_error <= DataOut(1);
			mac_tx_last <= DataOut(0);

			-- and stop running at EOF or buffer empty
			if (Head = Tail) or (DataOut(0) = '1') then
				Running := '0';
			end if;

		end if;
	end process fifo_proc;
	
end Behavioral;
