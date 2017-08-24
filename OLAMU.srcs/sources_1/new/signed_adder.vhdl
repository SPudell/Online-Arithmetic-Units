------------------------------------------------------------
-- Signed-Adder (signed_adder)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_adder is
	generic(
		N : positive := 3
	);
   port (
      a_i  : in  std_logic_vector(N-1 downto 0);
      b_i  : in  std_logic_vector(N-1 downto 0);
      s_o  : out std_logic_vector(N   downto 0)
   );
end signed_adder;

architecture rtl of signed_adder is	
begin
				  
	s_o <= (a_i(N-1) and b_i(N-1)) & std_logic_vector(signed(a_i) + signed(b_i));
	
end rtl;