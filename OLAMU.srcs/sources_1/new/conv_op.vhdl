--------------------------------------------------
-- Operand-Converter (conv. -> red.)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conv_op is
    port (
        op_i   : in  std_logic;
        op_p_o : out std_logic;
        op_m_o : out std_logic
    );
end conv_op;

architecture rtl of conv_op is
begin
    
end rtl;