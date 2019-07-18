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
use IEEE.numeric_std.all;
	
------------------------------------------------------------------------
-- Entidades
------------------------------------------------------------------------
entity fp_adder is
        
-- Cantidades de bits de la representación en punto flotante
-- Los valores por defecto son para la síntesis e implementación
generic
(
   WORD_SIZE:      natural:= 24;    
   MANTISSA_SIZE:  natural:= 17;             
   EXP_SIZE:       natural:= 6
);   


-- Entradas y salidas en formato de punto flotante normalizado
port
(
    clk_i:         in std_logic;

    a: in          std_logic_vector(WORD_SIZE-1 downto 0);	          
    b: in          std_logic_vector(WORD_SIZE-1 downto 0);          	  
    c: out         std_logic_vector(WORD_SIZE-1 downto 0)            
);


constant BIAS: integer := (2**(EXP_SIZE-1)-1);

end;


------------------------------------------------------------------------
-- Arquitectura
------------------------------------------------------------------------
architecture fp_adder_architecture of fp_adder is

    -- Signos
	signal sgn_a:              std_logic;						
	signal sgn_b:              std_logic; 						
	signal sgn_c:              std_logic;

    -- Exponentes
	signal exp_a:              std_logic_vector(EXP_SIZE-1 downto 0);			
	signal exp_b:              std_logic_vector(EXP_SIZE-1 downto 0);			
	signal exp_c:              std_logic_vector(EXP_SIZE-1 downto 0);
	signal single_bias_exp_c:  std_logic_vector(EXP_SIZE-1 downto 0);
    signal double_bias_exp_c:  std_logic_vector(EXP_SIZE-1 downto 0);
    signal exp_normalized:     std_logic_vector(EXP_SIZE-1 downto 0);

    -- Mantissas
	signal mant_a:             std_logic_vector(MANTISSA_SIZE-1 downto 0); 	
	signal mant_b:             std_logic_vector(MANTISSA_SIZE-1 downto 0); 	   
    signal mant_c:             std_logic_vector((MANTISSA_SIZE) downto 0);
    signal mant_product_truncated: std_logic_vector(MANTISSA_SIZE-1 downto 0);      

    signal add: std_logic_vector(WORD_SIZE-1 downto 0);

begin

	-- Separación de exponentes, signos y mantissas
	sgn_a <= a(WORD_SIZE-1);							
        sgn_b <= b(WORD_SIZE-1);                            
    
        exp_a <= (a(WORD_SIZE-2 downto WORD_SIZE-EXP_SIZE-1));                
        exp_b <= (b(WORD_SIZE-2 downto WORD_SIZE-EXP_SIZE-1));                
    
        mant_a <= a(WORD_SIZE-EXP_SIZE-2 downto 0);            
        mant_b <= b(WORD_SIZE-EXP_SIZE-2 downto 0);        		

    

	adder: entity WORK.adder
	        generic map
            (
                 WORD_SIZE => WORD_SIZE,
                 EXP_SIZE => EXP_SIZE,
                 MANT_SIZE => MANTISSA_SIZE
            )
            port map
            (
                 clk => clk_i,   
                       
                 a => a,
                 b => b,      
                           
                 mant_a => mant_a,
                 mant_b => mant_b,
                 mant_c => mant_c,
                 
                 exp_a => exp_a,
                 exp_b => exp_b,
                 exp_c => exp_c,
                 
                 sgn_a => sgn_a,
                 sgn_b => sgn_b,
                 sgn_c => sgn_c
             );    
                            
    -- Valor de retorno.
    c <=(sgn_c&exp_c&mant_c(MANTISSA_SIZE-1 downto 0));
    
end;
