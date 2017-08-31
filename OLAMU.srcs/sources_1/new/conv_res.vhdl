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
		L	 : positive := 8;		-- vector-length -> #digits
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
   	q_o 		: out std_logic_vector(L*N-1 downto 0);
   	q_dec_o	: out integer
	);
end conv_res;

architecture rtl of conv_res is
	
	signal reg_q  : std_logic_vector(L*N-1 downto 0) := (others => '0');
	signal reg_qm : std_logic_vector(L*N-1 downto 0) := (others => '0');
	
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
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg_q <= (others => '0');
			else
				if vld_i = '1' then
					if sft_q = '1' then
						reg_q <= reg_q(((L*N-1)-N) downto 0) & p_i;
					else
						reg_q <= reg_qm(((L*N-1)-N) downto 0) & std_logic_vector(RAD + signed(p_i));
					end if;
				end if;	
			end if;
		end if;
	end process;
	
	proc_reg_qm: process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg_qm <= (others => '0');
			else
				if vld_i = '1' then
					if sft_qm = '1' then
						reg_qm <= reg_qm(((L*N-1)-N) downto 0) & std_logic_vector((RAD-1) + signed(p_i));
					else
						reg_qm <= reg_q(((L*N-1)-N) downto 0) & std_logic_vector(signed(p_i)-1);
					end if;
				end if;
			end if;
		end if;
	end process;

	sft_q   <= '0' when (signed(p_i) < 0) else '1';
	sft_qm  <= '0' when (signed(p_i) > 0) else '1';
	
	q_o 	  <= reg_q;
	q_dec_o <= to_dec(RAD, L, N, reg_q);
	
end rtl;