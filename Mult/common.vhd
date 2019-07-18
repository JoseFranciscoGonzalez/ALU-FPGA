------------------------------------------------------------------------
-- common.vhd
--
-- DESCRIPCIÓN: Definiciones de tipos de punto flotante.
-- 
-- Universidad de Buenos Aires - Facultad de Ingeniería
-- José Francisco González
-- 21-09-18 
------------------------------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

package Common is    

   constant BIAS:           std_logic_vector(7 downto 0):= "01111111";
   constant WORD_SIZE:      integer := 32;
   constant MANTISSA_SIZE:  integer := 24;
   constant EXP_SIZE:       integer := 8;

   type exponent is array(EXP_SIZE-1 downto 0) of std_logic;
   type mantissa is array(MANTISSA_SIZE-1 downto 0) of std_logic;
   type fp_number is array(WORD_SIZE downto 0) of std_logic;
   type sign is array(0 downto 0) of std_logic;

end Common;

package body Common is
end Common;