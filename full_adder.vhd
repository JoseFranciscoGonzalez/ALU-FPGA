------------------------------------------------------------------------
-- full_adder.vhd
--
-- Sumador Completo
-- 
-- Universidad de Buenos Aires - Facultad de Ingeniería
-- Sistemas Digitales 66-17
-- José Francisco González
-- 09-09-18 
------------------------------------------------------------------------

--------------------------------------------------------
-- Bibliotecas
--------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;

--------------------------------------------------------
-- Entidad
--------------------------------------------------------
entity full_adder is
port
(
    a: 				in std_logic; 	-- Puerto de entrada
    b: 				in std_logic; 	-- Puerto de entrada
    carrie_in: 		in std_logic; 	-- Carrie de un proceso anterior
    carrie_out: 	out std_logic; 	-- Puerto de salida de carrie
    sum:    		out std_logic	-- Puerto de salida de suma
);
end;

--------------------------------------------------------
-- Arquitectura
--------------------------------------------------------
architecture full_adder_architecture of full_adder is

	signal sum_1:    std_logic;		-- Suma del primer semisumador
	signal carrie_1: std_logic;		-- Carrie del primer semisumador
	signal carrie_2: std_logic;		-- Carrie del segundo semisumador

begin
	
-- Impletación con dos semisumadores
first_half_adder: entity WORK.half_adder port map(a,b,sum_1,carrie_1);
second_half_adder: entity WORK.half_adder port map(sum_1,carrie_in,sum,carrie_2);

carrie_out <= carrie_1 or carrie_2;

end;

