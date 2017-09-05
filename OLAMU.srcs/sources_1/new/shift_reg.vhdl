--------------------------------------------------
-- Shift-Register (shift_reg)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity shift_reg is
	generic(
		I 			: positive := 2;
		W 			: positive := 1
	);
	port (
		clk 		: in  std_logic;
		rst 		: in  std_logic;
      data_i 	: in  std_logic_vector(W-1 downto 0);
		data_o 	: out std_logic_vector(W-1 downto 0)
   );
end shift_reg;

architecture rtl of shift_reg is 

	component reg
		generic (
			W 			: positive);
		port (
         clk 		: in  std_logic;
			rst 		: in  std_logic;
			data_i 	: in  std_logic_vector(W-1 downto 0);
			data_o 	: out std_logic_vector(W-1 downto 0));
   end component;
  
	signal sig_data : std_logic_vector((I+1)*W-1 downto 0) := (others => '0');
	 
begin
   
   reg_gen: for k in 1 to I generate
		reg_x: reg
			generic map (
				W => W
			)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => sig_data(k*W-1 downto k*W-W),
				data_o => sig_data((k+1)*W-1 downto (k+1)*W-W));
   end generate reg_gen;
   
   sig_data(W-1 downto 0)	<= data_i;
   data_o						<= sig_data((I+1)*W-1 downto (I+1)*W-W);
   
end rtl;