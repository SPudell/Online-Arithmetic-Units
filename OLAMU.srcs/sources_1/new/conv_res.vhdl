--------------------------------------------------
-- Result-Converter (red. -> conv.)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conv_res is
    port (
        op_p_i : in  std_logic;
        op_m_i : in  std_logic;
        op_o   : out std_logic
    );
end conv_res;

architecture rtl of conv_res is
begin
    
end rtl;