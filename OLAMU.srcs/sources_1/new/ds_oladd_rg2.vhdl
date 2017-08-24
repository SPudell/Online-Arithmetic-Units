------------------------------------------------------------
-- Digit-Serial Online-Adder for Radix > 2 (ds_oladd_rg2)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ds_oladd_rg2 is
	generic (
		RAD	: positive := 4;	-- radix-r 
		A		: positive := 3;	-- digit-set bound 'a'
		N		: positive := 3	-- operand bit-width
	);
   port (
      clk : in  std_logic;
      rst : in  std_logic;
      x_i : in  std_logic_vector(N-1 downto 0);
      y_i : in  std_logic_vector(N-1 downto 0);
      z_o : out std_logic_vector(N-1 downto 0)
	);
end ds_oladd_rg2;

architecture rtl of ds_oladd_rg2 is

	component signed_adder
		generic (
			N : positive);
      port (
			a_i  : in  std_logic_vector(N-1 downto 0);
			b_i  : in  std_logic_vector(N-1 downto 0);
			s_o  : out std_logic_vector(N   downto 0));
   end component;
   
   component tw_unit
      generic (
   		RAD	: positive;
   		A		: positive;
   		N 		: positive);
      port (
         x_i : in  std_logic_vector(N-1 downto 0);
         y_i : in  std_logic_vector(N-1 downto 0);
         t_o : out std_logic_vector(N-1 downto 0);
         w_o : out std_logic_vector(N-1 downto 0));
   end component;

	signal sig_t : std_logic_vector(N-1 downto 0) := (others => '0');
	signal sig_w : std_logic_vector(N-1	downto 0) := (others => '0');
	signal sig_z : std_logic_vector(N   downto 0) := (others => '0');
	
	signal reg_w : std_logic_vector(N-1	downto 0) := (others => '0');
	signal reg_z : std_logic_vector(N-1 downto 0) := (others => '0');
	
begin

	sa1: signed_adder
		generic map (
			N => N)
		port map (
			a_i => sig_t,
			b_i => reg_w,
			s_o => sig_z
		);
	
	tw1: tw_unit
		generic map (
			RAD => RAD,
			A		=> A,
			N		=> N)
   	port map (
   		x_i => x_i,
   		y_i => y_i,
   		t_o => sig_t,
   		w_o => sig_w
   	);
   
   process(clk)
   begin
   	if rising_edge(clk) then
			if rst = '1' then
				reg_w <= (others => '0');
				reg_z <= (others => '0');
			else
				reg_w <= sig_w;
				reg_z <= sig_z(N-1 downto 0);
			end if;
		end if;  	
	end process;
	
	z_o <= reg_z;
		
end rtl;