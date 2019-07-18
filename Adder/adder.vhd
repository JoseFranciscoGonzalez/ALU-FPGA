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

library work;
use work.zeros.all;
	
------------------------------------------------------------------------
-- Entidades
------------------------------------------------------------------------
entity adder is
    generic
    (
        WORD_SIZE: natural;
        EXP_SIZE: natural;
        MANT_SIZE: natural
    );
    
	port(
			clk 			  : in std_logic;
			
			a                 : in std_logic_vector(WORD_SIZE-1 downto 0);
			b                 : in std_logic_vector(WORD_SIZE-1 downto 0);
			
			mant_a		      : in std_logic_vector(MANT_SIZE-1 downto 0);
			mant_b		      : in std_logic_vector(MANT_SIZE-1 downto 0);
			mant_c			  : out std_logic_vector(MANT_SIZE downto 0);
			
			exp_a		      : in std_logic_vector(EXP_SIZE-1 downto 0);
			exp_b		      : in std_logic_vector(EXP_SIZE-1 downto 0);
			exp_c		      : out std_logic_vector(EXP_SIZE-1 downto 0);
			
			sgn_a 		      : in std_logic;
            sgn_b             : in std_logic;
			sgn_c 			  : out std_logic
			);
end adder;


------------------------------------------------------------------------
-- Arquitectura
------------------------------------------------------------------------
architecture adder_arq of adder is


signal a_aux                            : std_logic_vector(WORD_SIZE-1 downto 0);
signal b_aux                            : std_logic_vector(WORD_SIZE-1 downto 0);

signal shift                            : integer;
signal counter                          : integer:= 0;

signal mant_a_aux:                       std_logic_vector(MANT_SIZE downto 0);
signal mant_b_aux                        : std_logic_vector(MANT_SIZE downto 0);
signal mant_b2_aux                       : std_logic_vector(MANT_SIZE downto 0);
signal mant_b3_aux                       : std_logic_vector(MANT_SIZE downto 0);

signal g_bit                             :std_logic;

signal mant_c_aux                        : std_logic_vector(MANT_SIZE downto 0);
signal mant_c1_aux                        : std_logic_vector(MANT_SIZE downto 0);
signal mant_c2_aux                       : std_logic_vector(MANT_SIZE downto 0); 
signal mant_c2b_aux                       : std_logic_vector(MANT_SIZE downto 0); 
signal mant_c3_aux                       : std_logic_vector(MANT_SIZE downto 0);
signal mant_c_aux_complement             : std_logic_vector(MANT_SIZE+1 downto 0);
signal mant_inf                          : std_logic_vector(MANT_SIZE downto 0);
signal mant_zero                         : std_logic_vector(MANT_SIZE downto 0);

signal zero_mask                         : std_logic_vector(MANT_SIZE downto 0);
signal exp_mask                          : std_logic_vector(EXP_SIZE-1 downto 0);
signal exp_inf                           :std_logic_vector(EXP_SIZE-1 downto 0);

signal exp_a_aux                         : std_logic_vector(EXP_SIZE-1 downto 0);
signal exp_b_aux                         : std_logic_vector(EXP_SIZE-1 downto 0);
signal exp_c_aux                         : std_logic_vector(EXP_SIZE-1 downto 0);

signal mant_b_aux_complement             : std_logic_vector(MANT_SIZE+1 downto 0); 

signal sgn_a_aux, sgn_b_aux, sgn_c_aux   : std_logic;

signal carrie_out                        : std_logic;
signal swap                              : std_logic:= '0';

signal tmp:  std_logic_vector(7 downto 0);
signal load: std_logic;


begin


-- Inicia señales internas
-- Agrega bits ocultos
-- Invierte operandos dependiendo del exponente
a_aux      <= a             when (exp_a >= exp_b) else b;
mant_a_aux <= ('1'&mant_a)  when (exp_a >= exp_b) else ('1'&mant_b);
sgn_a_aux  <= sgn_a         when (exp_a >= exp_b) else (sgn_b);
exp_a_aux  <= exp_a         when (exp_a >= exp_b) else (exp_b);

b_aux      <= b             when (exp_a >= exp_b) else a;
mant_b_aux <= ('1'&mant_b)  when (exp_a >= exp_b) else ('1'&mant_a);
sgn_b_aux  <= sgn_b         when (exp_a >= exp_b) else (sgn_a);
exp_b_aux  <= exp_b         when (exp_a >= exp_b) else (exp_a);    

swap <= '1' when (exp_b > exp_a) else '0';

-- Genera el complemento
comp: entity WORK.complement
	        generic map
            (
                 NBITS => MANT_SIZE+1
            )
            port map
            (
                 A => unsigned(mant_b_aux),
                 B => mant_b_aux_complement
             );    

-- Toma el complemnto si hay signos distintos                       
mant_b2_aux <= mant_b_aux_complement(MANT_SIZE downto 0) when (sgn_b /= sgn_a) else mant_b_aux;

-- G- BIT
g_bit <= mant_b2_aux(shift-1) when (shift > 0)
         --else mant_b2_aux(0) when shift = 0;
         else '0' when shift = 0;
-- Ancho a desplazar
shift <= (to_integer(unsigned(exp_a)) - to_integer(unsigned(exp_b))) when (exp_a >= exp_b) else (to_integer(unsigned(exp_b)) - to_integer(unsigned(exp_a)));

-- Desplaza a derecha y rellena con 1s si se tomo complemnto 0s si no se tomo complemento
mant_b3_aux <= (MANT_SIZE downto MANT_SIZE-shift+1 => '1') & (mant_b2_aux(MANT_SIZE downto shift)) when (sgn_b /= sgn_a and shift > 0)
                else (MANT_SIZE downto MANT_SIZE-shift+1 => '0') & (mant_b2_aux(MANT_SIZE downto shift)) when (shift > 0)
                else mant_b2_aux when shift = 0;
-- Suma de mantisas
mant_adder: entity WORK.adder_nbits
	generic map
	(
	   N_BITS => MANT_SIZE+1
	)
	port map
	(
		a => mant_a_aux,
		b => mant_b3_aux,
		carrie_in => '0',
		carrie_out => carrie_out,       
		sum => mant_c_aux
	);

comp2: entity WORK.complement
	        generic map
            (
                 NBITS => MANT_SIZE+1
            )
            port map
            (
                 A => unsigned(mant_c_aux),
                 B => mant_c_aux_complement
             );    

--mant_c1_aux <= mant_c_aux_complement(MANT_SIZE downto 0) when (carrie_out = '0' and sgn_b /= sgn_a and mant_c_aux(MANT_SIZE)='1');
mant_c1_aux <=mant_c_aux;
-- SI hubo carrie out 
mant_c2_aux <= (MANT_SIZE  => '1') & (mant_c1_aux(MANT_SIZE downto 1)) when (carrie_out = '1' and sgn_b = sgn_a)
                else mant_c_aux_complement(MANT_SIZE downto 0) when (carrie_out = '0' and sgn_b /= sgn_a and mant_c_aux(MANT_SIZE)='1')
                else mant_c1_aux(MANT_SIZE downto 0);

-- manejo del signo
sgn_c_aux <= sgn_a                              when (sgn_a = sgn_b)
            else    sgn_b                       when (swap = '1')
            else    sgn_b                       when (carrie_out = '0' and sgn_b_aux /= sgn_a_aux and mant_c_aux(MANT_SIZE)='1')
            else    sgn_a                      ;
    
-- Cuenta ceros a la izquierda    
counter     <= to_integer(unsigned(count_l_zeros(mant_c2_aux(MANT_SIZE downto 0)))) when mant_c2_aux(MANT_SIZE)='0' else 0;

zero_mask   <= (others => '0');  
mant_c3_aux <= mant_c2_aux(MANT_SIZE-counter downto 0)&(g_bit)&(zero_mask(counter-2 downto 0)) when (counter > 1 and (not(carrie_out = '1') or not(sgn_a = sgn_b)))
               else mant_c2_aux(MANT_SIZE-counter downto 0) & g_bit when (counter = 1 and (not(carrie_out = '1') or not(sgn_a = sgn_b)))
               else mant_c2_aux;  

-- exponente
exp_mask <= (others => '0');
exp_inf <= (others => '1');

exp_c_aux <=   std_logic_vector(unsigned(exp_a_aux)+1) when (carrie_out = '1' and sgn_b = sgn_a and (unsigned(exp_a)/=0 and unsigned(exp_b)/=0))
               else std_logic_vector(unsigned(exp_a_aux)-counter) when unsigned(mant_c3_aux)/=0 
               else exp_mask;   

exp_c <= exp_mask when(unsigned(exp_a) = 1 and unsigned(exp_b)=1 and sgn_a /= sgn_b)
         else std_logic_vector(unsigned(exp_inf)-1) when (unsigned(exp_a) = unsigned(exp_b) and unsigned(exp_b)= (unsigned(exp_inf)-1) and sgn_a=sgn_b)
         else   exp_inf when (unsigned(exp_c_aux)=(unsigned(exp_inf)) and (unsigned(mant_a)=0 or unsigned(mant_b)=0))
         else std_logic_vector(unsigned(exp_inf)-1) when(unsigned(exp_c_aux)=(unsigned(exp_inf)))
         else  exp_c_aux;
         
mant_inf <= (others => '1');  
mant_zero <= (others => '0');    
   
mant_c <= mant_inf when (unsigned(exp_a)=unsigned(exp_inf)-1 and unsigned(exp_b)=unsigned(exp_inf)-1 and (unsigned(mant_a)=0 or unsigned(mant_b)=0))
          else mant_zero when(unsigned(exp_a) = 1 and unsigned(exp_b)=1 and sgn_a /= sgn_b)
          else   mant_zero when (unsigned(exp_c_aux)=(unsigned(exp_inf)) and (unsigned(mant_a)=0 or unsigned(mant_b)=0))
            else mant_zero when (unsigned(exp_c_aux)=(unsigned(exp_inf))-1 and (unsigned(mant_a)=0 or unsigned(mant_b)=0))
          else std_logic_vector(unsigned(mant_inf)) when(unsigned(exp_c_aux)=(unsigned(exp_inf)))
          
          else  mant_c3_aux;
sgn_c <= sgn_c_aux;

end adder_arq;
