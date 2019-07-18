entity shift is
  port(C, SI, ALOAD : in std_logic;
        D   : in std_logic_vector(7 downto 0);
        SO  : out std_logic);
end shift;
architecture archi of shift is
  signal tmp: std_logic_vector(7 downto 0);
  signal load: std_logic;
  begin 
  
    process (C, ALOAD, D)
      begin
        if (ALOAD='1') then
          tmp <= D;
			  for c in 8 downto 1 loop
					load <= tmp(c-1);
					SO <= load;
			  end loop;
        end if;
				   

    end process;
	

end archi;