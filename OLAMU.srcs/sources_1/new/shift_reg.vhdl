--------------------------------------------------
-- Shift-Register (shift_reg)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity shift_reg is
	generic(
		I : positive := 2
	);
	port (
		clk 		: in  std_logic;
		rst 		: in  std_logic;
      data_i 	: in  std_logic;
		data_o 	: out std_logic
   );
end shift_reg;

architecture rtl of shift_reg is   

	component reg
		port (
         clk 		: in  std_logic;
			rst 		: in  std_logic;
			data_i 	: in  std_logic;
			data_o 	: out std_logic);
   end component;
  
	signal sig_data : std_logic_vector(I downto 0) := (others => '0');
	 
begin
   
   reg_gen: for k in 0 to I-1 generate
		reg_x: reg
			port map(
				clk 	 => clk,
				rst 	 => rst,
				data_i => sig_data(k),
				data_o => sig_data(k+1));
   end generate reg_gen;
   
   sig_data(0) <= data_i;
   data_o		<= sig_data(I);  
   
end rtl;