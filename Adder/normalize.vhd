
--process(clk)
--   variable zero_count : natural:=0;
--begin

--if(rising_edge(clk)) then
--zero_count := 0;


--  for i in mant_c_aux'range loop
--    if mant_c_aux(i) = '0' then
--      zero_count := zero_count + 1;
--      mant_c3_aux <= shift_left(unsigned(mant_c2_aux), 1);
--    else
--      exit;
--    end if;
--  end loop;
  
--counter <=  zero_count;
--end if;
--end process;
