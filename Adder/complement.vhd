------------------------------------------------------------------------
-- fp_adder.vhd
--
-- 
-- Universidad de Buenos Aires - Facultad de Ingeniería
-- Sistemas Digitales 66-17
-- José Francisco González
-- 18-10-18 
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Bilbiotecas
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
	
------------------------------------------------------------------------
-- Entidades
------------------------------------------------------------------------
entity complement is
    generic
    (
        NBITS: natural
    );
    
	port(
			
			A : in unsigned (NBITS-1 downto 0);
			B : out std_logic_vector(NBITS downto 0)
			);
end complement;


------------------------------------------------------------------------
-- Arquitectura
------------------------------------------------------------------------
architecture complement of complement is

constant ONE:   UNSIGNED(B'RANGE) := (0 => '1', others => '0');
begin
    B <= std_logic_vector(unsigned (not A) + ONE);
end complement;