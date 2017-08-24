--------------------------------------------------
-- Register (reg)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reg is
   port (
      clk	 : in  std_logic;
		rst	 : in  std_logic;
		data_i : in  std_logic;
		data_o : out std_logic
   );
end reg;

architecture rtl of reg is

	signal reg_data : std_logic;
	
begin

   process(clk)
   begin
      if rising_edge(clk) then
      	if rst = '1' then
      		reg_data <= '0';
      	else
   			reg_data <= data_i;   		
			end if;
      end if;
   end process;
   
   data_o <= reg_data;
   
end rtl;