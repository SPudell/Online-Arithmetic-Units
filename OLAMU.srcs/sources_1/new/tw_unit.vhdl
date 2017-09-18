------------------------------------------------------------
-- TW-Unit (tw_unit)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tw_unit is
	generic (
		RAD	: positive := 4;	-- radix-r 
		A		: positive := 3;	-- digit-set bound a
		N 		: positive := 3	-- operand bit-width
	);
   port (
   	lst_i : in  std_logic;
      x_i 	: in  std_logic_vector(N-1 downto 0);
      y_i 	: in  std_logic_vector(N-1 downto 0);
      t_o 	: out std_logic_vector(N-1 downto 0);
      w_o 	: out std_logic_vector(N-1 downto 0)
   );
end tw_unit;

architecture rtl of tw_unit is

	component signed_adder
		generic (
			N : positive);
      port (
			a_i  : in  std_logic_vector(N-1 downto 0);
			b_i  : in  std_logic_vector(N-1 downto 0);
			s_o  : out std_logic_vector(N   downto 0));
   end component;

	signal tmp_s 	: std_logic_vector(N   downto 0) := (others => '0');
	signal tmp_t 	: std_logic_vector(N-1 downto 0) := (others => '0');
	signal tmp_w 	: std_logic_vector(N   downto 0) := (others => '0');
		
begin

	sa1: signed_adder
		generic map (
			N => N)
		port map (
			a_i => x_i,
			b_i => y_i,
			s_o => tmp_s);
		
		
	process(tmp_s)
	begin
		if signed(tmp_s) >= A then
			tmp_t <= (N-3 downto 0 => '0') & "01";
			tmp_w <= std_logic_vector(signed(tmp_s) - RAD);
		elsif signed(tmp_s) <= -A then
			tmp_t <= (N-3 downto 0 => '1') & "11";
			tmp_w <= std_logic_vector(signed(tmp_s) + RAD);
		else
			tmp_t <= (others => '0');
			tmp_w <= tmp_s;
		end if;
	end process;
	
	t_o <= tmp_t when lst_i = '0' else (others => '0');
	w_o <= tmp_w(N-1 downto 0);
			
end rtl;