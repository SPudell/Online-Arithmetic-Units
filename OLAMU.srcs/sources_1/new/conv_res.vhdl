--------------------------------------------------
-- Result-Converter (red. -> conv.)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conv_res is
	generic (
		RAD : positive := 2;		-- radix
		L	 : positive := 8;		-- vector-length -> #digits
		N	 : positive := 2		-- bit-width per digit
	);
	port (
		-- ctrl signals
		lst_i	: in  std_logic;
		
		-- data signals
   	p_i 	: in  std_logic_vector(N-1 downto 0);
   	q_o 	: out std_logic_vector(L*(N-1) downto 0)
	);
end conv_res;

architecture rtl of conv_res is

	signal reg_q	: std_logic_vector(L*(N-1) downto 0) := (others => '0');
	signal reg_qm	: std_logic_vector(L*(N-1) downto 0) := (others => '0');
	
begin
	
	
	
end rtl;