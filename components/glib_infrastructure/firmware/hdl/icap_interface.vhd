--=================================================================================================--
--==================================== Module information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	08/12/2011     																			--
-- Project Name:				icap_interface																            --
-- Module Name:   		 	icap_interface     			 										               --
-- 																																--
-- Language:					VHDL'93																						--
--																																	--
-- Target Devices: 			Virtex 6																						--
-- Tool versions: 			iSE 13.2																						--
--																																	--
-- Revision:		 			1.0 																							--
--																																	--
-- Additional Comments: 																									--
--																																	--
--=================================================================================================--
--=================================================================================================--
--
-- Timing diagram:
-- 
--            +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +-
--            |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
--  CLK_I   --+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+ 
--
-- 
--          --+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+ 
--            |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
--  INV_CLK_I +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +-
--
--            +--+--+                             +--+--+--+--+--+--+--+--+
--            |     |                             |                       |
--  WRITE_I --+     +--+--+--+--+--+--+--+--+--+--+                       +--+--+--+--+--+--+-
-- 
--            +--+--+                             +--+--+--+--+--+--+--+--+
--            |     |                             |                       |
--  CS_I    --+     +--+--+--+--+--+--+--+--+--+--+                       +--+--+--+--+--+--+-
--
--          xx\/----\/xxxxxxxxxxxxxxxxxxxxxxxxxxxx\/----\/----\/----\/----\/xxxxxxxxxxxxxxxxxx
--  DATA_I  xx/\-D0-/\xxxxxxxxxxxxxxxxxxxxxxxxxxxx/\-D0-/\-D1-/\-D2-/\-D3-/\xxxxxxxxxxxxxxxxxx
--
--
--
--          --+--+--+	    	        +--+--+--+--+                                   +--+--+-
--                  |                 |           |                                   |
--  RDWRB           +--+--+--+--+--+--+           +--+--+--+--+--+--+--+--+--+--+--+--+       
--          --+--+--+--+--+     +--+--+--+--+--+--+--+--+                       +--+--+--+--+-
-- 		                 |     |                       |                       |
--  CSB                   +--+--+                       +--+--+--+--+--+--+--+--+
--
--          xxxxxxxxxxxxx\/----\/xxxxxxxxxxxxxxxxxxxxxx\/----\/----\/----\/----\/xxxxxxxxxxxxx
--  I       xxxxxxxxxxxxx/\-D0-/\xxxxxxxxxxxxxxxxxxxxxx/\-D0-/\-D1-/\-D2-/\-D3-/\xxxxxxxxxxxxx
--
--
-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;
-- User libraries and packages:
use work.icap_package.all;
--=================================================================================================--
--======================================= Module Body =============================================-- 
--=================================================================================================--
entity icap_interface is
	port (	
		-- Control:
		RESET_I										: in  std_logic;
		CLK_I											: in  std_logic;
		INV_CLK_I									: in  std_logic;
		-- Logic fabric:				
		CS_I											: in  std_logic;
		WRITE_I										: in  std_logic;
		DATA_I										: in  std_logic_vector(31 downto 0);   	
		DATA_O										: out std_logic_vector(31 downto 0);  		
		ACK_O											: out std_logic	
	);
end icap_interface;
architecture structural of icap_interface is
	--======================== Signal Declarations ========================--
	attribute keep : string;
	signal data_i_ord								: std_logic_vector(31 downto 0); 
	attribute keep of data_i_ord				: signal is "true";
	signal cs_b_from_fsm							: std_logic;
	signal write_b_from_fsm	 					: std_logic;	
	signal data_from_icap						: std_logic_vector(31 downto 0);
	signal data_from_icap_ord					: std_logic_vector(31 downto 0);
	signal busy_from_icap 						: std_logic;	
	attribute keep of busy_from_icap			: signal is "true";
	--=====================================================================--
--========================================================================--
-----		  --===================================================--
begin		--================== Architecture Body ==================-- 
-----		  --===================================================--
--========================================================================--		
	--============================ User Logic =============================--
	-- Combinatorial logic:
	selectMAPdataOrdering_generate: for i in 0 to 7 generate
		-- Input:
		data_i_ord(7-i)							<=	DATA_I(i);
		data_i_ord(15-i)							<=	DATA_I(8+i);
		data_i_ord(23-i)							<=	DATA_I(16+i);
		data_i_ord(31-i)							<=	DATA_I(24+i);	
		-- Output:
		data_from_icap_ord(7-i)					<=	data_from_icap(i);
		data_from_icap_ord(15-i)				<=	data_from_icap(8+i);
		data_from_icap_ord(23-i)				<=	data_from_icap(16+i);
		data_from_icap_ord(31-i)				<=	data_from_icap(24+i);	
	end generate;	
	-- Secuential logic:
	main_process: process(RESET_I, CLK_I)
		variable startWrite			         : boolean;
		variable startRead 			         : boolean;
		variable counter 						   : natural range 0 to IPBUSDELAY - 1;
		variable c_state							: c_stateT;
		variable w_state							: w_stateT;
		variable r_state							: r_stateT;		
		variable writeDone_from_fsm			: std_logic;
		variable readDone_from_fsm				: std_logic;	
	begin
		if RESET_I = '1' then	
			startWrite								:= false;			
			startRead 								:= false;			
			counter 									:= 0;
			c_state									:= c_s0;
			w_state									:= w_s0;
			r_state									:= r_s0;					
			writeDone_from_fsm					:= '0';
			readDone_from_fsm						:= '0';			
			cs_b_from_fsm							<= '1';					
			write_b_from_fsm						<= '1';
			ACK_O										<= '0';
			DATA_O									<=	(others => '0');
		elsif rising_edge(CLK_I) then		
			-- Control FSM:
			case c_state is 						
				when c_s0 => 			
					if CS_I = '1' then
						if WRITE_I = '1' then
							startWrite 				:= true;
						else
							startRead 				:= true;
						end if;
						c_state						:= c_s1;
					end if;
				when c_s1 =>
					if writeDone_from_fsm = '1' or readDone_from_fsm = '1'  then
						c_state						:= c_s0;
					end if;					
			end case;
			-- Write FSM:
			case w_state is				
				when w_s0 =>
					writeDone_from_fsm			:= '0';	
					if startWrite = true then
						w_state						:= w_s1;
						write_b_from_fsm			<= '0';						
					end if;					
				when w_s1 =>		
					w_state							:= w_s2;					
					cs_b_from_fsm					<= '0';	
				when w_s2 =>		
					w_state							:= w_s3;					
					cs_b_from_fsm					<= '1';				
				when w_s3 =>		
					w_state							:= w_s4;					
					write_b_from_fsm				<= '1';			
				when w_s4 =>		
					w_state							:= w_s5;					
					ACK_O								<= '1';					
				when w_s5 =>										
					ACK_O								<= '0';					
					if counter = IPBUSDELAY - 1 then 
						w_state						:= w_s0;
						counter 						:= 0;
						startWrite 					:= false;
						writeDone_from_fsm		:= '1'; 
					else
						counter 						:= counter + 1;
					end if;		
			end case;			
			-- Read FSM:
			case r_state is
				when r_s0 =>
					readDone_from_fsm				:= '0';	
					if startRead = true then
						r_state						:= r_s1;
						cs_b_from_fsm				<= '0';				
					end if;
				when r_s1 =>						
					if busy_from_icap = '0' then 							
						r_state						:= r_s2;						
						cs_b_from_fsm				<= '1'; 	
						DATA_O						<= data_from_icap_ord;					
					end if;							
				when r_s2 =>								
					r_state							:= r_s3;		
					ACK_O								<= '1';		
				when r_s3 =>								
					ACK_O								<= '0';					
					if counter = IPBUSDELAY - 1 then 
						r_state						:= r_s0;
						counter 						:= 0;
						startRead 					:= false;
						readDone_from_fsm			:= '1'; 
					else
						counter 						:= counter + 1;
					end if;		
			end case;			
		end if;	
	end process;	
	--=====================================================================--		
	--===================== Component instantiations ======================--		
	-- ICAP: 
	icap: ICAP_VIRTEX6
		generic map (
			DEVICE_ID 				=> x"0424A093",   -- Refer UG360.pdf page number 86 in Table 6-13 (XC6VLX130T = 0x0424A093)
			ICAP_WIDTH 				=> "X32",      	-- Input and output data width to be used with the ICAP_VIRTEX6.
			SIM_CFG_FILE_NAME 	=> "NONE")			-- Raw Bitstream (RBT) file to be parsed by the simulation model				
		port map (			
			BUSY 						=> busy_from_icap,			
			O 							=> data_from_icap,			
			CLK 						=> INV_CLK_I,  		-- (100MHz max)(Inverted clock)		
			CSB 						=> cs_b_from_fsm,  		
			I 							=> data_i_ord,  
			RDWRB 					=> write_b_from_fsm  	
		);			
	--=====================================================================--	
end structural;
--=================================================================================================--
--=================================================================================================--