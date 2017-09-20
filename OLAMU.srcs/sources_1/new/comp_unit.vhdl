------------------------------------------------------------
-- Composite Algo. Unit (comp_unit) -> z=(x+y)+(x+y)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity comp_unit is
	generic (
		RAD	: positive := 4;		-- radix-r
		L 		: positive := 4		-- vector-length -> #digits per operand
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
end comp_unit;

architecture rtl of comp_unit is

	constant A : positive := digit_set_bound(RAD);	-- boundary for the digit-set
	constant N : positive := bit_width(A);				-- bit-width for the digit-set
	
	component dp_oladd_top
		generic (
			RAD	: positive := 2;
			L 		: positive := 4);
		port (
			clk 		: in  std_logic;
			rst 		: in  std_logic;
			lst_i		: in  std_logic;
			vld_i		: in  std_logic;
			lst_o		: out std_logic;
			vld_o		: out std_logic;
			rdy_o		: out std_logic;			
			x_i 		: in  std_logic_vector(N-1 downto 0);
			y_i 		: in  std_logic_vector(N-1 downto 0);
			z_o 		: out std_logic_vector(N-1 downto 0)
		);
	end component;
		
	component conv_res
		generic (
			RAD 	: positive; 
			L	 	: positive;
			N	 	: positive);
		port (
			clk	: in  std_logic;
			rst	: in  std_logic;
			vld_i	: in  std_logic;
			vld_o	: out std_logic;
			p_i 	: in  std_logic_vector(N-1 downto 0);
			q_o 	: out std_logic_vector((L*(N-1))-1 downto 0));
	end component;
	
	signal sig_z_o 	: std_logic_vector(N-1 downto 0) := (others => '0');
	signal sig_z1_o 	: std_logic_vector(N-1 downto 0) := (others => '0');
	signal sig_z2_o 	: std_logic_vector(N-1 downto 0) := (others => '0');
	signal sig_lst1_o : std_logic := '0';
	signal sig_lst2_o : std_logic := '0';
	signal sig_vld_o 	: std_logic := '0';
	signal sig_vld1_o	: std_logic := '0';
	signal sig_vld2_o	: std_logic := '0';
	signal sig_rdy1_o	: std_logic := '0';
	signal sig_rdy2_o	: std_logic := '0';
	
	
	
begin
   
	add_unit_1: dp_oladd_top
		generic map (
			RAD 		=> RAD,
			L 	 		=> L)
		port map (
			clk 		=> clk,
			rst 		=> rst,
			lst_i 	=> lst_i,
			vld_i 	=> vld_i,
			lst_o 	=> sig_lst1_o,
			vld_o 	=> sig_vld1_o,
			rdy_o 	=> sig_rdy1_o,
			x_i 		=> x_i,
			y_i 		=> y_i,
			z_o 		=> sig_z1_o
		);
		
	add_unit_2: dp_oladd_top
		generic map (
			RAD 		=> RAD,
			L 	 		=> L)
		port map (
			clk 		=> clk,
			rst 		=> rst,
			lst_i 	=> lst_i,
			vld_i 	=> vld_i,
			lst_o 	=> sig_lst2_o,
			vld_o 	=> sig_vld2_o,
			rdy_o 	=> sig_rdy2_o,
			x_i 		=> x_i,
			y_i 		=> y_i,
			z_o 		=> sig_z2_o
		);

	add_unit_3: dp_oladd_top
		generic map (
			RAD 		=> RAD,
			L 	 		=> L)
		port map (
			clk 		=> clk,
			rst 		=> rst,
			lst_i 	=> sig_lst1_o,
			vld_i 	=> sig_vld1_o,
			lst_o 	=> lst_o,
			vld_o 	=> sig_vld_o,
			rdy_o 	=> rdy_o,
			x_i 		=> sig_z1_o,
			y_i 		=> sig_z2_o,
			z_o 		=> sig_z_o
		);		
  		
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