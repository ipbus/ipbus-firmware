---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


--=================================================================================================--
--=================================== Package Information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	08/12/2011		 																			--
-- Module Name:				flash_interface																	      --
-- Package Name:   		 	flash_package																				--
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
--=================================================================================================--
--====================================== Package Body =============================================-- 
--=================================================================================================--
package flash_package is   
	--======================== Type Declarations ==========================--
	type c_stateT is (c_s0, c_s1, c_s2);
	type w_stateT is (w_s0, w_s1, w_s2, w_s3);
	type r_stateT is (r_s0, r_s1, r_s2);
	--=====================================================================--	
	--======================= Record Declarations =========================--
	type rFlashR is 
		record 
			data							: std_logic_vector(15 downto 0);		
		end record;
	type wFlashR is 
		record 
			l_b							: std_logic;		
		   e_b							: std_logic;		
		   g_b							: std_logic;		
		   w_b							: std_logic;		
		   tristate						: std_logic;
			addr							: std_logic_vector(22 downto 0);	
			data							: std_logic_vector(15 downto 0);		
		end record;	
	--=====================================================================--
	--===================== Constant Declarations =========================--	
	constant IPBUSDELAY				: integer := 2;  -- Minimum latency achievable (2 Cycles)
	constant ADDRLATCHDELAY			: integer := 1;  -- 16ns@62.5MHz (10ns min)					
	constant WRITEDISABLEDELAY		: integer := 4;  -- 64ns@62.5MHz (50ns min)
	constant NEWWRITEDELAY			: integer := 2;  -- 32ns@62.5MHz (25ns min)	
	constant DATAVALIDDELAY			: integer := 6;  -- 96ns@62.5MHz (85ns min)
	--=====================================================================--
end flash_package;
--=================================================================================================--
package body flash_package is
end flash_package;
--=================================================================================================--
--=================================================================================================--