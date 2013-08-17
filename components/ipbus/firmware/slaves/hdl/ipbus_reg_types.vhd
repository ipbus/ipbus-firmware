library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ipbus_reg_types is

	type ipb_reg_v is array(natural range <>) of std_logic_vector(31 downto 0);

-- Useful function - compile-time only
	
	function calc_width(maxval: integer) return integer is
	begin
		for i in 1 to 32 loop
			if(2 ** i > maxval) then
				return(i);
			end if;
		end loop;
		return(0);
	end;

	function integer_max(LEFT, RIGHT: INTEGER) return INTEGER is
  begin
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end integer_max;
	
end ipbus_reg_types;

