--------------------------------------------------
-- Full-Adder (FA)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
   port (
      a   : in  std_logic;
      b   : in  std_logic;
      c_i : in  std_logic;
      c_o : out std_logic;
      s   : out std_logic
   );
end full_adder;

architecture rtl of full_adder is
   
   signal p : std_logic := '0';
   
begin

   p <= a xor b;
   s <= p xor c_i;

   with p select 
      c_o <= a   when '0',
             c_i when others;

end rtl;