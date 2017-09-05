--------------------------------------------------
-- Register (reg)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reg is
	generic(
		W 		 : positive := 1
	);
   port (
      clk	 : in  std_logic;
		rst	 : in  std_logic;
		data_i : in  std_logic_vector(W-1 downto 0);
		data_o : out std_logic_vector(W-1 downto 0)
   );
end reg;

architecture rtl of reg is

	signal reg_data : std_logic_vector(W-1 downto 0);
	
begin

   process(clk)
   begin
      if rising_edge(clk) then
      	if rst = '1' then
      		reg_data <= (others => '0');
      	else
   			reg_data <= data_i;   		
			end if;
      end if;
   end process;
   
   data_o <= reg_data;
   
end rtl;