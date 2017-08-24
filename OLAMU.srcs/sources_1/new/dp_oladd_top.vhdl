------------------------------------------------------------
-- Dynamic-Precision Online-Adder Top-Level (dp_oladd_top)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity dp_oladd_top is
	generic (
		RAD	: positive := 2	-- radix-r
	);
	port (
		-- control signals
		clk 	: in  std_logic;
		rst 	: in  std_logic;
		vld_i	: in  std_logic;
		lst_i	: in  std_logic;
		lst_o	: out std_logic;
		vld_o	: out std_logic;
		rdy_o	: out std_logic;
		
		--data signals
		x_i : in  std_logic_vector(bit_width(digit_set_bound(RAD))-1 downto 0);
		y_i : in  std_logic_vector(bit_width(digit_set_bound(RAD))-1 downto 0);
		z_o : out std_logic_vector(bit_width(digit_set_bound(RAD))-1 downto 0)
	);
end dp_oladd_top;

architecture rtl of dp_oladd_top is

	constant A : positive := digit_set_bound(RAD);	-- boundary for the digit-set
	constant N : positive := bit_width(A);				-- bit-width for the digit-set
		
	component ds_oladd_r2
		generic (
			RAD	: positive; 
			N		: positive);
      port (
         clk : in  std_logic;
			rst : in  std_logic;
			x_i : in  std_logic_vector(N-1 downto 0);
			y_i : in  std_logic_vector(N-1 downto 0);
			z_o : out std_logic_vector(N-1 downto 0));
   end component;
   
	component ds_oladd_rg2
		generic (
			RAD : positive; 
			A	 : positive;
			N	 : positive);
		port (
			clk : in  std_logic;
			rst : in  std_logic;
			x_i : in  std_logic_vector(N-1 downto 0);
			y_i : in  std_logic_vector(N-1 downto 0);
			z_o : out std_logic_vector(N-1 downto 0));
	end component;
	
	component cu
		generic(
			RAD : positive := 2);
		port (
			clk 	: in  std_logic;
			rst 	: in  std_logic;
	      vld_i	: in  std_logic;
			lst_i	: in  std_logic;
			lst_o	: out std_logic;
			vld_o	: out std_logic;
			rdy_o	: out std_logic);
	end component;
	
	signal sig_vld_o : std_logic := '0';
	
begin

	ctrl_unit: cu
		generic map (
			RAD => RAD)
		port map (
			clk 	=> clk,
			rst 	=> rst,
			vld_i => vld_i,
			lst_i => lst_i,
			lst_o => lst_o,
			vld_o => sig_vld_o,
			rdy_o => rdy_o);
	
	rad_2: if RAD = 2 generate
		oladd_r2: ds_oladd_r2
			generic map (
				RAD => RAD,
				N	 => N)
			port map (
				clk => clk,
				rst => rst,
				x_i => x_i,
				y_i => y_i,
				z_o => z_o);
  	end generate rad_2;

	rad_g2: if RAD > 2 generate
		oladd_rg2: ds_oladd_rg2
			generic map (
				RAD => RAD,
				A		=> A,
				N		=> N)
			port map (
				clk => clk,
				rst => rst,
				x_i => x_i,
				y_i => y_i,
				z_o => z_o);
  	end generate rad_g2;
  	
  	
  	vld_o <= sig_vld_o;
	
end rtl;