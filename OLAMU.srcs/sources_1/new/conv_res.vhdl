--------------------------------------------------
-- Result-Converter (red. -> conv.)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity conv_res is
	generic (
		RAD : positive := 2;		-- radix
		L	 : positive := 8;		-- vector-length -> #digits per operand
		N	 : positive := 2		-- bit-width per digit
	);
	port (
		-- ctrl signals
		clk	: in  std_logic;
		rst	: in  std_logic;
		vld_i	: in  std_logic;
		vld_o	: out std_logic;
		
		-- data signals
   	p_i 		: in  std_logic_vector(N-1 downto 0);
   	q_o 		: out std_logic_vector((L*(N-1))-1 downto 0)
	);
end conv_res;

architecture rtl of conv_res is

	signal reg_q  : std_logic_vector((L*(N-1))-1 downto 0) := (others => '0');
	signal reg_qm : std_logic_vector((L*(N-1))-1 downto 0) := (others => '0');
	
	signal cnt_r  : unsigned(log_2_ceil(L) downto 0) := (others => '0');
	
	signal sft_q  : std_logic := '0';
	signal sft_qm : std_logic := '0';
	
begin

	proc_ctrl: process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cnt_r <= (others => '0');
				vld_o <= '0';
			else
				if cnt_r = L-1 then
					vld_o <= '1';
					
				else
					vld_o <= '0';
				end if;
				
				if vld_i = '1' then
					if cnt_r = L-1 then
						cnt_r <= (others => '0');
					else
						cnt_r <= cnt_r + 1;
					end if;					
				end if;
			end if;
		end if;
	end process;

	proc_reg_q: process(clk)
		variable tmp : std_logic_vector(N-1 downto 0);
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg_q <= (others => '0');
			else
				if vld_i = '1' then
					if sft_q = '1' then
						tmp	:= p_i;
						reg_q <= reg_q((L*N-L-N) downto 0) & tmp(N-2 downto 0);
					else
						tmp	:= std_logic_vector(RAD + signed(p_i));
						reg_q <= reg_qm((L*N-L-N) downto 0) & tmp(N-2 downto 0);
					end if;
				end if;	
			end if;
		end if;
	end process;
	
	proc_reg_qm: process(clk)
		variable tmp : std_logic_vector(N-1 downto 0);
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg_qm <= (others => '0');
			else
				if vld_i = '1' then
					if sft_qm = '1' then
						tmp := std_logic_vector((RAD-1) + signed(p_i));
						reg_qm <= reg_qm((L*N-L-N) downto 0) & tmp(N-2 downto 0);
					else
						tmp := std_logic_vector(signed(p_i)-1);
						reg_qm <= reg_q((L*N-L-N) downto 0) & tmp(N-2 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;

	sft_q   <= '0' when (signed(p_i) < 0) else '1';
	sft_qm  <= '0' when (signed(p_i) > 0) else '1';
	
	q_o 	  <= reg_q;
	
end rtl;