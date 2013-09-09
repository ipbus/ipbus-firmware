library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ipbus_reg_types is

	type ipb_reg_v is array(natural range <>) of std_logic_vector(31 downto 0);

-- Useful functions - compile-time only

	function calc_width(n: integer) return integer;
	function integer_max(left, right: integer) return integer;

end package ipbus_reg_types;

package body ipbus_reg_types is

	function calc_width(n: integer) return integer is
	begin
		for i in 0 to 31 loop
			if(2 ** i >= n) then
				return(i);
			end if;
		end loop;
		return(0);
	end function calc_width;

	function integer_max(left, right: integer) return integer is
  begin
    if left > right then
    	return left;
    else
    	return right;
    end if;
  end function integer_max;
	
end package body ipbus_reg_types;

