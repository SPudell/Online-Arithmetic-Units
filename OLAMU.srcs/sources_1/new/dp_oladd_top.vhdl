------------------------------------------------------------
-- Dynamic-Precision Online-Adder Top-Level (dp_oladd_top)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity dp_oladd_top is
	generic (
		RAD	: positive := 2;		-- radix-r
		L 		: positive := 8		-- vector-length -> #digits per operand
	);
	port (
		-- control signals
		clk 		: in  std_logic;
		rst 		: in  std_logic;
		lst_i		: in  std_logic;
		vld_i		: in  std_logic;
		lst_o		: out std_logic;
		vld_o		: out std_logic;
		rdy_o		: out std_logic;
		vld_x_o	: out std_logic;
		vld_y_o	: out std_logic;
		vld_z_o	: out std_logic;
				
		--data signals
		x_i 		: in  std_logic_vector(bit_width(digit_set_bound(RAD))-1 downto 0);
		y_i 		: in  std_logic_vector(bit_width(digit_set_bound(RAD))-1 downto 0);
		z_o 		: out std_logic_vector(bit_width(digit_set_bound(RAD))-1 downto 0);
		q_x_o		: out std_logic_vector((L*((bit_width(digit_set_bound(RAD)))-1))-1 downto 0);
		q_y_o		: out std_logic_vector((L*((bit_width(digit_set_bound(RAD)))-1))-1 downto 0);
		q_z_o		: out std_logic_vector((L*((bit_width(digit_set_bound(RAD)))-1))-1 downto 0)
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
	
	component conv_res
		generic (
			RAD : positive; 
			L	 : positive;
			N	 : positive);
		port (
			clk		: in  std_logic;
			rst		: in  std_logic;
			vld_i		: in  std_logic;
			vld_o		: out std_logic;
			p_i 		: in  std_logic_vector(N-1 downto 0);
			q_o 	 	: out std_logic_vector((L*(N-1))-1 downto 0));
	end component;
	
	component cu
		generic(
			RAD : positive);
		port (
			clk 	: in  std_logic;
			rst 	: in  std_logic;
	      vld_i	: in  std_logic;
			lst_i	: in  std_logic;
			lst_o	: out std_logic;
			vld_o	: out std_logic;
			rdy_o	: out std_logic);
	end component;
	
	signal sig_z_o    : std_logic_vector(N-1 downto 0) := (others => '0');
	signal sig_vld_o  : std_logic := '0';
	
begin
	
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
				z_o => sig_z_o);
  	end generate rad_2;

	rad_g2: if RAD > 2 generate
		oladd_rg2: ds_oladd_rg2
			generic map (
				RAD => RAD,
				A 	 => A,
				N	 => N)
			port map (
				clk => clk,
				rst => rst,
				x_i => x_i,
				y_i => y_i,
				z_o => sig_z_o);
  	end generate rad_g2;
  	
  	ctrl_unit: cu
		generic map (
			RAD 	=> RAD)
		port map (
			clk 	=> clk,
			rst 	=> rst,
			vld_i => vld_i,
			lst_i => lst_i,
			lst_o => lst_o,
			vld_o => sig_vld_o,
			rdy_o => rdy_o);
  	
  	op_x_converter: conv_res
		generic map (
			RAD 	=> RAD,
			L	 	=> L,
			N	 	=> N)
		port map (
			clk 	=> clk,
			rst 	=> rst,
			vld_i => vld_i,
			vld_o => vld_x_o,
			p_i	=> x_i,
			q_o 	=> q_x_o);

	op_y_converter: conv_res
		generic map (
			RAD 	=> RAD,
			L	 	=> L,
			N	 	=> N)
		port map (
			clk 	=> clk,
			rst 	=> rst,
			vld_i => vld_i,
			vld_o => vld_y_o,
			p_i	=> y_i,
			q_o 	=> q_y_o);
									
	result_converter: conv_res
		generic map (
			RAD 	=> RAD,
			L	 	=> L,
			N 		=> N)
		port map (
			clk 	=> clk,
			rst 	=> rst,
			vld_i	=> sig_vld_o,
			vld_o => vld_z_o,
			p_i	=> sig_z_o,
			q_o 	=> q_z_o);
  	
  	vld_o <= sig_vld_o;
  	z_o 	<= sig_z_o;
	
end rtl;