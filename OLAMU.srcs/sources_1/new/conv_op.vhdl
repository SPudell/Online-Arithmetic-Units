--------------------------------------------------
-- Operand-Converter (conv. -> red.)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity conv_op is
	generic (
		RAD : positive := 2;		-- radix
		L	 : positive := 8;		-- vector-length -> #digits
		N	 : positive := 2		-- bit-width per digit
	);
	port (
		-- ctrl signals
		clk	: in  std_logic;
		rst	: in  std_logic;
		vld_i	: in  std_logic;
		vld_o	: out std_logic;
		lst_o	: out std_logic;
		rdy_o : out std_logic;
		
		-- data signals
		p_i 		: in  integer;
		q_o 		: out std_logic_vector(N-1 downto 0)
	);
end conv_op;

architecture rtl of conv_op is

	signal cnt_r : unsigned(log_2_ceil(L) downto 0) := (others => '0');
	
	signal reg_p : signed(31 downto 0) := (others => '0');
	
	signal sig_neg : std_logic := '0';
	signal sig_vld : std_logic := '0';
	signal sig_lst : std_logic := '0';
	signal sig_rdy : std_logic := '0';
	
begin
	
	proc_ctrl: process(clk)
		variable tmp : signed(31 downto 0) := (others => '1'); 
	begin
		if rising_edge(clk) then
			if rst = '1' then
				tmp	  := (others => '1')
				reg_p   <= (others => '0');
				sig_neg <= '0';
				sig_vld <= '0';
				sig_lst <= '0';
				sig_rdy <= '1';
			else
			
				if sig_rdy = '0' then
					
				else
					if vld_i = '1' then
						if p_i < 0 then
							tmp     := tmp xor to_signed(p_i, tmp'length);
							sig_neg <= '1';
						else
							tmp     := to_signed(p_i, tmp'length);
							sig_neg <= '0';
						end if;
						reg_p   <= tmp;
						sig_rdy <= '0';					
					end if;
				end if;
			end if;
		end if;
	end process;
	
	vld_o <= sig_vld;
	lst_o <= sig_lst;
	rdy_o <= sig_rdy;
	
end rtl;