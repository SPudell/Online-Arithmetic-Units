--------------------------------------------------
-- Control-Unit (cu)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity cu is
	generic(
		RAD : positive := 2
	);
	port (
		clk 	: in  std_logic;
		rst 	: in  std_logic;
      vld_i	: in  std_logic;
		lst_i	: in  std_logic;
		lst_o	: out std_logic;
		vld_o	: out std_logic;
		rdy_o	: out std_logic
   );
end cu;

architecture rtl of cu is

	component shift_reg
		generic (
			I 	 	 : positive);
		port (
			clk 	 : in  std_logic;
			rst 	 : in  std_logic;
			data_i : in  std_logic;
			data_o : out std_logic);
	end component;

begin
	
	rad_2: if RAD = 2 generate
		shift_reg_lst: shift_reg
			generic map (
				I => 3)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => lst_i,
				data_o => lst_o);
				
		shift_reg_vld: shift_reg
			generic map (
				I => 3)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => vld_i,
				data_o => vld_o);			
  	end generate rad_2;

	rad_g2: if RAD > 2 generate
		shift_reg_lst: shift_reg
			generic map (
				I => 2)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => lst_i,
				data_o => lst_o);
				
		shift_reg_vld: shift_reg
			generic map (
				I => 2)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => vld_i,
				data_o => vld_o);				
  	end generate rad_g2;
  	
  	process(rst)
	begin
		if rst = '1' then
			rdy_o <= '0';
		else
			rdy_o <= '1';
		end if;
	end process;
	   
end rtl;