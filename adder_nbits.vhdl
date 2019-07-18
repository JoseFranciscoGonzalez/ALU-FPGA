------------------------------------------------------------------------
-- adder_nbits.vhd
--
-- Sumador de N_bits pasados por parametro.
-- 
-- Universidad de Buenos Aires - Facultad de Ingeniería
-- Sistemas Digitales 66-17
-- José Francisco González
-- 14-09-18 
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Bilbiotecas
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


------------------------------------------------------------------------
-- Entidades
------------------------------------------------------------------------
entity adder_nbits is

generic
(
    N_BITS: natural
);

port
(
    a:            in std_logic_vector(N_BITS-1 downto 0);
    b:            in std_logic_vector(N_BITS-1 downto 0);
    carrie_in:    in std_logic;
    sum:          out std_logic_vector(N_BITS-1 downto 0);
    carrie_out:   out std_logic := '0'
);
	
end;

------------------------------------------------------------------------
-- Arquitectura
------------------------------------------------------------------------
architecture adder_nbits_arq of adder_nbits is

	signal c_aux: std_logic_vector(N_BITS downto 0);
	
begin
	
	c_aux(0) <= carrie_in;
	carrie_out <= c_aux(N_BITS);
	
	sumGen: for i in 0 to N_BITS-1 generate
		sum1b_i: entity work.full_adder
			port map(
				a => a(i),
				b => b(i),
				carrie_in => c_aux(i),
				carrie_out => c_aux(i+1),
				sum => sum(i)
			);
	end generate;

end;

