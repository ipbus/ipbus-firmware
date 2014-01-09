--=================================================================================================--
--==================================== Module information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	08/12/2011    																		   	--
-- Project Name:				flash_interface																			--
-- Module Name:   		 	flash_interface      			 														--
-- 																																--
-- Language:					VHDL'93																						--
--																																	--
-- Target Devices: 			GLIB (Virtex 6)																			--
-- Tool versions: 			ISE 13.2																						--
--																																	--
-- Revision:		 			1.0 																							--
--																																	--
-- Additional Comments: 																									--
--																																	--
--=================================================================================================--
--=================================================================================================--
-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;
-- User libraries and packages:
use work.flash_package.all;
--=================================================================================================--
--======================================= Module Body =============================================-- 
--=================================================================================================--
entity flash_interface is
	port (			
		-- Control:
		RESET_I												: in  std_logic;
		CLK_I													: in  std_logic;
		-- Logic Fabric:	
		CS_I													: in  std_logic;
		WRITE_I  											: in  std_logic;
		ADDR_I												: in  std_logic_vector(22 downto 0);
		DATA_I												: in  std_logic_vector(15 downto 0);	
		DATA_O												: out std_logic_vector(15 downto 0);	
		DONE_O												: out std_logic;
		-- Platform Flash:			
		FLASH_I												: in  rFlashR;
		FLASH_O												: out wFlashR	
	);
end flash_interface;
architecture structural of flash_interface is
	--======================== Signal Declarations ========================--	
	attribute keep : string;
	-- Data out:
	signal dataOut											: std_logic_vector(15 downto 0);
	attribute keep of dataOut							: signal is "true";
	-- Write FSM:
	signal writeDone_from_fsm							: std_logic;
	-- Read FSM (Asynchronous Random Access Read):	
	signal dataValid_from_fsm							: std_logic;	
	--=====================================================================--			
--========================================================================--
-----		  --===================================================--
begin		--================== Architecture Body ==================-- 
-----		  --===================================================--
--========================================================================--
	--========================= Port Assignments ==========================--
	FLASH_O.addr											<= ADDR_I;
	DATA_O													<= dataOut;
	DONE_O													<= writeDone_from_fsm or
																	dataValid_from_fsm;
	--=====================================================================--	
	--============================ User Logic =============================--
	main_process: process(RESET_I, CLK_I)				
		-- Control FSM:
		variable c_state									: c_stateT;
		variable startWrite 								: boolean;
		variable startRead 								: boolean;
		-- Write FSM:
		variable w_state									: w_stateT;		
		-- Read FSM (Asynchronous Random Access Read):	
		variable r_state									: r_stateT;
		-- Common variables:
		variable counter									: natural range 0 to DATAVALIDDELAY - 1;		
	begin
		if RESET_I = '1' then
			-- Control FSM:
			c_state											:= c_s0;
			startWrite 										:= false;
			startRead 										:= false;
			-- Write FSM:				
			w_state											:= w_s0;
			writeDone_from_fsm							<= '0';				
			FLASH_O.data									<= (others => '0');
			-- Read FSM (Asynchronous Random Access Read):		
			r_state											:= r_s0;			
			dataValid_from_fsm							<= '0';	
			dataOut											<= (others => '0');
			-- Common signals and variables:
			counter											:= 0;
			FLASH_O.l_b										<= '1';
			FLASH_O.e_b										<= '1';
			FLASH_O.g_b										<= '1';
		   FLASH_O.w_b										<= '1';
			FLASH_O.tristate								<= '1';	-- 'Z'			
		elsif rising_edge(CLK_I) then	
			-- Control FSM:
			case c_state is 
				when c_s0 => 
					if counter = IPBUSDELAY - 1 then 
						c_state								:= c_s1;
						counter 								:= 0;
					else
						counter 								:= counter + 1;
					end if;				
				when c_s1 => 			
					if CS_I = '1' then
						if WRITE_I = '1' then
							startWrite 						:= true;
						else
							startRead 						:= true;
						end if;
						c_state								:= c_s2;
					end if;
				when c_s2 =>
					if writeDone_from_fsm = '1' or dataValid_from_fsm = '1'  then
						c_state								:= c_s0;
					end if;					
			end case;
			-- Write FSM:
			case w_state is				
				when w_s0 =>
					writeDone_from_fsm					<= '0';	
					if startWrite = true then
						w_state								:= w_s1;
						dataOut								<= (others => '0');
						FLASH_O.l_b							<= '0'; 
						FLASH_O.e_b							<= '0'; 
						FLASH_O.g_b							<= '1'; 
						FLASH_O.w_b							<= '0';
						FLASH_O.tristate					<= '0';
						FLASH_O.data						<= DATA_I;	-- Data to flash is latched	
					end if;					
				when w_s1 =>							
						if counter = ADDRLATCHDELAY - 1 then	-- 10ns min from L <= '0' 
							w_state							:= w_s2;
							counter	 						:= 0;
							FLASH_O.l_b						<= '1'; 
						else
							counter							:= counter + 1;
						end if;
				when w_s2 =>	
						if counter = WRITEDISABLEDELAY - 1 then	-- 50ns min from E <= '0'
							w_state							:= w_s3;							
							counter	 						:= 0;
							FLASH_O.e_b						<= '1'; 							
							FLASH_O.w_b						<= '1';
							FLASH_O.tristate				<= '1';
							FLASH_O.data					<= (others => '0'); 		
						else
							counter							:= counter + 1;
						end if;	
				when w_s3 =>
					if counter = NEWWRITEDELAY - 1 then	-- 25ns min before a new write					
						w_state								:= w_s0;
						counter	 							:= 0;
						startWrite							:= false;									
						writeDone_from_fsm				<= '1';	-- Write Done Flag
					else
						counter								:= counter + 1;
					end if;	
				when others =>
					w_state									:= w_s0;
					startWrite								:= false;
			end case;					
			-- Read FSM (Asynchronous Random Access Read):
			case r_state is
				when r_s0 =>
					dataValid_from_fsm					<= '0';	
					if startRead = true then
						r_state								:= r_s1;
						FLASH_O.l_b							<= '0'; 
						FLASH_O.e_b							<= '0'; 
						FLASH_O.g_b							<= '0'; 
						FLASH_O.w_b							<= '1';
						FLASH_O.tristate					<= '1';				
					end if;
				when r_s1 =>					
					if counter = ADDRLATCHDELAY - 1 then	-- 10ns min from L <= '0' 
						r_state								:= r_s2;
						counter	 							:= 0;
						FLASH_O.l_b							<= '1'; 							
					else
						counter								:= counter + 1;
					end if;
				when r_s2 =>
					if counter = DATAVALIDDELAY - 1 then	-- 85ns min until data valid 
						r_state								:= r_s0;
						counter	 							:= 0;
						startRead							:= false;
						dataValid_from_fsm				<= '1';	-- Data Valid Flag
						dataOut								<= FLASH_I.data; -- Data from flash is latched 
						FLASH_O.e_b							<= '1'; 
						FLASH_O.g_b							<= '1'; 
					else
						counter								:= counter + 1;
					end if;						
				when others =>
					r_state									:= r_s0;
					startRead								:= false;
			end case;
		end if;
	end process;
	--=====================================================================--	
end structural;
--=================================================================================================--
--=================================================================================================--