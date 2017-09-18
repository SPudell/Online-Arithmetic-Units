------------------------------------------------------------
-- Digit-Serial Online-Adder for Radix = 2 (ds_oladd_r2)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ds_oladd_r2 is
	generic (
		RAD	: positive := 2;	-- radix-r
		N		: positive := 2	-- operands bit-width
	);
   port (
      clk 	: in  std_logic;
      rst 	: in  std_logic;
      lst_i : in  std_logic;
		x_i 	: in  std_logic_vector(N-1 downto 0);
		y_i 	: in  std_logic_vector(N-1 downto 0);
		z_o 	: out std_logic_vector(N-1 downto 0)
	);
end ds_oladd_r2;

architecture rtl of ds_oladd_r2 is

   component full_adder
      port (
         a   : in  std_logic;
         b   : in  std_logic;
         c_i : in  std_logic;
         c_o : out std_logic;
         s   : out std_logic);
   end component;

	signal sig_x  : std_logic_vector(N-1 downto 0) := (others => '0');
	signal sig_y  : std_logic_vector(N-1 downto 0) := (others => '0');
   signal sig_a2 : std_logic := '0';
   signal sig_b2 : std_logic := '0';
   signal sig_c1 : std_logic := '0';
   signal sig_c2 : std_logic := '0';
   signal sig_s1 : std_logic := '0';
   signal sig_s2 : std_logic := '0';
   signal sig_z1 : std_logic := '0';
   signal sig_z2 : std_logic_vector(N-1 downto 0) := (others => '0');

begin

   fa1: full_adder
      port map (
         a   => sig_x(1),
         b   => not sig_x(0),
         c_i => sig_y(1),
         c_o => sig_c1,
         s   => sig_s1
   	);
   
   fa2: full_adder
      port map (
         a   => sig_a2,
         b   => sig_b2,
         c_i => sig_c1,
         c_o => sig_c2,
         s   => sig_s2
      );
   
   process(clk)
   begin
      if rising_edge(clk) then
      	if rst = '1' then
      		sig_a2 <= '0';
      	   sig_b2 <= '0';
      	   sig_z1 <= '0';
      	   sig_z2 <= (others => '0');
      	else
				sig_a2 <= sig_s1;
				sig_b2 <= not sig_y(0);
				sig_z1 <= sig_s2;
				sig_z2 <= std_logic_vector'(sig_z1, not sig_c2);
				
				if lst_i = '1' then
--					sig_a2 <= '1';
--					sig_b2 <= '0';
--					sig_z1 <= '1';
--					sig_z2 <= std_logic_vector'('0', '1');
				end if;
			end if;
      end if;
   end process;
   
	with x_i select
		sig_x <= "01" when "11",
   			 	"10" when "01",
   			 	"00" when others;
   			 
	with y_i select
		sig_y <= "01" when "11",
   			 	"10" when "01",
   			 	"00" when others;
   
   with sig_z2 select
		z_o	<= "11" when "01",
   				"01" when "10",
					"00" when others;
   
end rtl;