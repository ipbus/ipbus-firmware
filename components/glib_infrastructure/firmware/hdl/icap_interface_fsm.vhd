--=================================================================================================--
--==================================== Module information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	13/01/2012     																			--
-- Project Name:				icap_interface																            --
-- Module Name:   		 	icap_interface_fsm  			 										               --
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
entity icap_interface_fsm is
	port (		
		RESET_I	 									: in  std_logic;		
		CLK_I											: in  std_logic;	
		CONF_TRIGG_I								: in  std_logic;
		FSM_CONF_PAGE_I							: in  std_logic_vector(1 downto 0);
		FMS_SELECT_O								: out std_logic;
		CS_O											: out std_logic;
		WRITE_O  		 							: out std_logic;
		DATA_O   									: out std_logic_vector(31 downto 0);
		ACK_I											: in  std_logic
	);
end icap_interface_fsm;
architecture structural of icap_interface_fsm is
	--======================== Signal Declarations ========================--
	signal command									: iprog_commandT;
	--=====================================================================--
--========================================================================--
-----		  --===================================================--
begin		--================== Architecture Body ==================-- 
-----		  --===================================================--
--========================================================================--		
	--============================ User Logic =============================--
	-- Address setup:
	addr_setup_generate: for i in 0 to 4 generate	
		command(i) 									<= COMMAND_1(i);
		command(5)									<= COMMAND_2 & '0' & FSM_CONF_PAGE_I & '0' & x"00000";
		command(6+i)								<= COMMAND_3(i);  
	end generate;
	-- FSM:
	main_process: process(RESET_I, CLK_I)
		variable i 						   		: natural range 0 to command'length - 1;
		variable state								: stateT;
	begin
		if RESET_I = '1' then	
			state										:= s0;					
			i 											:= 0;			
			FMS_SELECT_O							<= '0';	
			CS_O										<= '0';			
			WRITE_O  								<= '0';		     
			DATA_O									<=	(others => '0');
		elsif rising_edge(CLK_I) then		
			-- Control FSM:
			case state is 						
				when s0 =>
					if CONF_TRIGG_I = '1' then
						state 						:= s1;
					end if;
				when s1 =>	
					state 							:= s2;					
					FMS_SELECT_O					<= '1';
				when s2 =>	
					state 							:= s3;					
					WRITE_O							<= '1';					
					CS_O								<= '1';	
					DATA_O							<= command(i);	
				when s3 =>		
					if ACK_I = '1' then
						state 						:= s4;						
						CS_O							<= '0';				
					end if;				
				when s4 =>				
					if i = command'length - 1 then
						state 						:= s0;
						i								:= 0;
						FMS_SELECT_O				<= '0';
						WRITE_O						<= '0';
						DATA_O						<=	(others => '0');												
					else
						state 						:= s2;
						i								:= i + 1;	
					end if;				
			end case;			
		end if;	
	end process;	
	--=====================================================================--	
end structural;
--=================================================================================================--
--=================================================================================================--