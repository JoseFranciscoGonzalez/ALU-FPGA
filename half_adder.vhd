--------------------------------------------------------
-- half_adder.vhd
-- Descripción de un semisumador.
-- José Francisco González
-- 09/09/18
-- 1.0
--------------------------------------------------------

--------------------------------------------------------
-- Bibliotecas
--------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;

--------------------------------------------------------
-- Entidad
--------------------------------------------------------
entity half_adder is
	port
	(
		a: 		in std_logic; 	-- Puerto de entrada
		b: 		in std_logic; 	-- Puerto de entrada
		sum:    out std_logic; 	-- Puerto de salida de suma
		carrie: out std_logic 	--Puerto de salida de carrie
	);
end;

--------------------------------------------------------
-- Arquitectura
--------------------------------------------------------
architecture half_adder_architecture of half_adder is
begin
	carrie <= a and b;		-- Asigna el carrie
	sum <= a xor b;			-- Asigna la suma
end;

