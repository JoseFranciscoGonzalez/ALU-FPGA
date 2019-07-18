------------------------------------------------------------------------
-- fp_multiplication.vhd
--
-- Modulo de multiplicación de dos números en representación
-- de punto flotante según el estándar IEEE 754.
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
entity fp_mult is
        
-- Cantidades de bits de la representación en punto flotante
-- Los valores por defecto son para la síntesis e implementación
generic
(
   WORD_SIZE:      natural:= 26;    
   MANTISSA_SIZE:  natural:= 18;             
   EXP_SIZE:       natural:= 7
);   


-- Entradas y salidas en formato de punto flotante normalizado
port
(
    a: in          std_logic_vector(WORD_SIZE-1 downto 0);	          
    b: in          std_logic_vector(WORD_SIZE-1 downto 0);          	  
    c: out         std_logic_vector(WORD_SIZE-1 downto 0)            
);


constant BIAS: integer := (2**(EXP_SIZE-1)-1);

end;


------------------------------------------------------------------------
-- Arquitectura
------------------------------------------------------------------------
architecture fp_mult_architecture of fp_mult is

    -- Signos
	signal sgn_a:              std_logic;						
	signal sgn_b:              std_logic; 						
	signal sgn_c:              std_logic;

    -- Exponentes
	signal exp_a:              std_logic_vector(EXP_SIZE downto 0);			
	signal exp_b:              std_logic_vector(EXP_SIZE downto 0);			
	signal exp_c:              std_logic_vector(EXP_SIZE downto 0);
	signal single_bias_exp_c:  std_logic_vector(EXP_SIZE downto 0);
    signal double_bias_exp_c:  std_logic_vector(EXP_SIZE downto 0);
    signal exp_normalized:     std_logic_vector(EXP_SIZE downto 0);

    -- Mantissas
	signal mant_a:             std_logic_vector(MANTISSA_SIZE-1 downto 0); 	
	signal mant_b:             std_logic_vector(MANTISSA_SIZE-1 downto 0); 	   
    signal mant_product:       std_logic_vector((2*MANTISSA_SIZE)+1 downto 0);
    signal mant_product_truncated: std_logic_vector(MANTISSA_SIZE-1 downto 0);      


begin

	-- Separación de exponentes, signos y mantissas
	sgn_a <= a(WORD_SIZE-1);							
	sgn_b <= b(WORD_SIZE-1);							

	exp_a <= ('0'&a(WORD_SIZE-2 downto WORD_SIZE-EXP_SIZE-1));				
	exp_b <= ('0'&b(WORD_SIZE-2 downto WORD_SIZE-EXP_SIZE-1));				

	mant_a <= a(WORD_SIZE-EXP_SIZE-2 downto 0);			
	mant_b <= b(WORD_SIZE-EXP_SIZE-2 downto 0);				


    -- Suma de exponentes
	exp_adder: entity WORK.adder_nbits
	generic map
	(
	   N_BITS => EXP_SIZE+1
	)
	port map
	(
		a => exp_a,
		b => exp_b,
		carrie_in => '0',
		carrie_out => OPEN,       
		sum => double_bias_exp_c
	);

	-- Resta del doble BIAS
	bias_subtractor: entity WORK.subtractor_nbits
	generic map
	(
	   N_BITS => EXP_SIZE+1
	)
	port map
	(
		a => double_bias_exp_c,
		b => std_logic_vector(to_unsigned(BIAS,EXP_SIZE+1)),			
		result => single_bias_exp_c
	);

    exp_c <= single_bias_exp_c;
	
	-- Multiplicación sin signo de mantissas con dígito oculto de normalizacion
    mant_product <= std_logic_Vector(unsigned('1' & mant_a) * unsigned('1' & mant_b));

    
	

    -- Normalización de exponente
    exp_normalized <=  
               -- Casos especiales con Overflow de exponente se llevan a infinito
                    std_logic_vector(unsigned(exp_c)-2)         when (unsigned(exp_c)=((2**EXP_SIZE)))
               else std_logic_vector(unsigned(exp_c) - 1)       when ((mant_product(2*MANTISSA_SIZE+1)='1') AND (unsigned(exp_c)=((2**EXP_SIZE)-1)))
               else std_logic_vector(unsigned(exp_c) - 1)       when ((mant_product(2*MANTISSA_SIZE+1)='0') AND (unsigned(exp_c)=((2**EXP_SIZE)-1)))
               else std_logic_vector(unsigned(exp_c))           when ((mant_product(2*MANTISSA_SIZE+1)='1') AND (unsigned(exp_c)=((2**EXP_SIZE)-2)))
               else std_logic_vector(unsigned(exp_c))           when ((mant_product(2*MANTISSA_SIZE+1)='0') AND (unsigned(exp_c)=((2**EXP_SIZE)-2)))
               -- Casos Cero
               -- Caso exponente cero con corrimiento de coma
               else std_logic_vector(unsigned(exp_c) + 1)       when ((mant_product(2*MANTISSA_SIZE+1)='1') AND (to_integer(unsigned(exp_c))=0))                                             
               -- Caso exponente cero sin corrimiento de coma
               else std_logic_vector(to_unsigned(0,EXP_SIZE+1)) when ((mant_product(2*MANTISSA_SIZE+1)='0') AND (to_integer(unsigned(exp_c))=0))
               --Caso exponente con Overflow General
               else std_logic_vector(to_unsigned((2**EXP_SIZE)-2,EXP_SIZE+1)) when (to_integer(signed(exp_c)) <= -(2**EXP_SIZE-1))
               -- Caso exponente con underflow General
               else std_logic_vector(to_unsigned(0,EXP_SIZE+1)) when (to_integer(signed(exp_c)) < 0)
               -- Caso general con corrimiento de coma
               else std_logic_vector(unsigned(exp_c) + 1)       when ((mant_product(2*MANTISSA_SIZE+1)='1'))
               -- Caso general sin corrimiento de coma
               else std_logic_vector(unsigned(exp_c))           when ((mant_product(2*MANTISSA_SIZE+1)='0'))
               ;
        
    -- Normalización de Mantissa
    mant_product_truncated <= 
              -- Casos con Overflow
              std_logic_vector(to_unsigned((2**(MANTISSA_SIZE))-1,MANTISSA_SIZE))      when  (unsigned(exp_c)=((2**EXP_SIZE)))
              else std_logic_vector(to_unsigned((2**(MANTISSA_SIZE))-1,MANTISSA_SIZE)) when ((mant_product(2*MANTISSA_SIZE+1)='1') AND (unsigned(exp_c)=((2**EXP_SIZE)-1)))
              else std_logic_vector(to_unsigned((2**(MANTISSA_SIZE))-1,MANTISSA_SIZE)) when ((mant_product(2*MANTISSA_SIZE+1)='0') AND (unsigned(exp_c)=((2**EXP_SIZE)-1)))
              else std_logic_vector(to_unsigned((2**(MANTISSA_SIZE))-1,MANTISSA_SIZE)) when ((mant_product(2*MANTISSA_SIZE+1)='1') AND (unsigned(exp_c)=((2**EXP_SIZE)-2)))
              else mant_product((2*(MANTISSA_SIZE+1)-3) downto (MANTISSA_SIZE))        when ((mant_product(2*MANTISSA_SIZE+1)='0') AND (unsigned(exp_c)=((2**EXP_SIZE)-2)))
              -- Casos Cero
              else std_logic_vector(to_unsigned(0,MANTISSA_SIZE))                      when ((mant_product(2*MANTISSA_SIZE+1)='0') AND (to_integer(unsigned(exp_c)) = 0 ))
              else mant_product((2*(MANTISSA_SIZE+1)-2) downto (MANTISSA_SIZE+1))      when ((mant_product(2*MANTISSA_SIZE+1)='1') AND (to_integer(unsigned(exp_c)) = 0 ))
              else std_logic_vector(to_unsigned((2**(MANTISSA_SIZE))-1,MANTISSA_SIZE)) when (to_integer(signed(exp_c)) <= -(2**EXP_SIZE-1))
              else std_logic_vector(to_unsigned(0,MANTISSA_SIZE))                      when (to_integer(signed(exp_c)) <= 0)
              -- Caso general
              else mant_product((2*(MANTISSA_SIZE+1)-2) downto (MANTISSA_SIZE+1))      when ((mant_product(2*(MANTISSA_SIZE+1)-1)='1'))
              else mant_product((2*(MANTISSA_SIZE+1)-3) downto (MANTISSA_SIZE))        when ((mant_product(2*(MANTISSA_SIZE+1)-1)='0'))
              ;
    
    -- Multiplicación de signos	
    sgn_c <= 
             -- Caso con Overflow
             sgn_a xor sgn_b when (unsigned(exp_c)=((2**EXP_SIZE)))
             else sgn_a xor sgn_b when (to_integer(signed(exp_c)) <= -(2**EXP_SIZE-1))
             -- Caso con Underflow
             else '0'        when (to_integer(signed(exp_c)) < 0)       
             -- Caso de valor cero
             else '0'        when (to_integer(signed(exp_c)) = 0 AND (mant_product(2*MANTISSA_SIZE+1)='0') )                          
             -- caso general
             else sgn_a xor sgn_b;
                            
    -- Valor de retorno.
    c <=(sgn_c&exp_normalized(EXP_SIZE-1 downto 0)&mant_product_truncated);
    
end;
