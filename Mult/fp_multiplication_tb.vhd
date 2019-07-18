------------------------------------------------------------------------
-- fp_multiplication_tb.vhd
--
-- DESCRIPCIÓN: 
-- 
-- Universidad de Buenos Aires - Facultad de Ingeniería
-- José Francisco González
-- 14-09-18 
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Bilbiotecas
------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

-- Paquetes con definiciones y tipos propios
use work.Common.all;

--------------------------------------------------------
-- Entidad de prueba
--------------------------------------------------------
entity test is
    generic(BITS: natural := 8);
end;

--------------------------------------------------------
-- Arquitectura de prueba
--------------------------------------------------------
architecture test_arc of test is

    -- Declaraciones

    signal a_t: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(1074237638,32));      
    signal b_t: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(1098656147,32));                      
    signal result_t: std_logic_vector(31downto 0); 
                 

begin
    
    -- Descripción de la prueba
    DUT: entity WORK.fp_mult
    generic map
    (
        WORD_SIZE => 32,
        MANTISSA_SIZE => 23,
        EXP_SIZE => 8
    )    
    port map
    (
        a => a_t,
        b => b_t,
        c => result_t
    );

end;