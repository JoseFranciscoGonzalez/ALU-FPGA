library  ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package zeros is


	
    -- count the  zeros starting from left
    function count_l_zeros (signal s_vector: std_logic_vector) return std_logic_vector;
    
   
end zeros;

package body zeros is
    
   
	function count_l_zeros (signal s_vector: std_logic_vector) return std_logic_vector is
		variable v_count : std_logic_vector(5 downto 0);	
	begin
		v_count := "000000";
		for i in s_vector'range loop
			case s_vector(i) is
				when '0' => v_count := v_count + "000001";
				when others => exit;
			end case;
		end loop;
		return v_count;	
	end count_l_zeros;



		
end zeros;
