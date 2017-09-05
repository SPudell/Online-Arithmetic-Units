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
	
	constant W : positive := 1;
	
	component shift_reg
		generic (
			I 	 	 : positive;
			W 	 	 : positive);
		port (
			clk 	 : in  std_logic;
			rst 	 : in  std_logic;
			data_i : in  std_logic_vector(W-1 downto 0);
			data_o : out std_logic_vector(W-1 downto 0));
	end component;

	signal vec_vld_i : std_logic_vector(W-1 downto 0);
	signal vec_vld_o : std_logic_vector(W-1 downto 0);
	signal vec_lst_i : std_logic_vector(W-1 downto 0);
	signal vec_lst_o : std_logic_vector(W-1 downto 0);
	
begin
	
	rad_2: if RAD = 2 generate
		shift_reg_lst: shift_reg
			generic map (
				I => 3,
				W => W)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => vec_lst_i,
				data_o => vec_lst_o);
				
		shift_reg_vld: shift_reg
			generic map (
				I => 3,
				W => W)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => vec_vld_i,
				data_o => vec_vld_o);			
  	end generate rad_2;

	rad_g2: if RAD > 2 generate
		shift_reg_lst: shift_reg
			generic map (
				I => 2,
				W => W)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => vec_lst_i,
				data_o => vec_lst_o);
				
		shift_reg_vld: shift_reg
			generic map (
				I => 2,
				W => W)
			port map (
				clk 	 => clk,
				rst 	 => rst,
				data_i => vec_vld_i,
				data_o => vec_vld_o);				
  	end generate rad_g2;
  	
  	
  	vec_vld_i(0) <= vld_i;
  	vec_lst_i(0) <= lst_i;
 
  	vld_o <= vec_vld_o(0);
  	lst_o <= vec_lst_o(0);
  	
  	rdy_o <= '0' when rst = '1' else '1';
	   
end rtl;