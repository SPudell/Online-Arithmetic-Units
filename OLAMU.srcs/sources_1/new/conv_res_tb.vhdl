------------------------------------------------------------
-- Result-Converter (red. -> conv.)
------------------------------------------------------------
-- Testbench
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity conv_res_tb is
end conv_res_tb;

architecture sim of conv_res_tb is
		
	-- component generics
	constant PERIOD : Time := 10 ns;
	constant RAD 	 : positive := 2;
	constant L   	 : positive := 2;
	constant A 	 	 : positive := digit_set_bound(RAD); 
	constant N   	 : positive := bit_width(A); 
	
	-- component ports
	signal clk   	: std_logic := '1'; 
	signal rst   	: std_logic := '1';
	signal vld_i 	: std_logic := '0';
	signal vld_o 	: std_logic := '0';
	signal p_i 	 	: std_logic_vector(N-1 downto 0);
	signal q_o   	: std_logic_vector((L*(N-1))-1 downto 0);
	signal q_dec_o : integer;
		
	-- control signal
	signal finished : boolean := false;
	
begin

	UUT: entity work.conv_res
		generic map(
			RAD => RAD,
			L => L,
			N => N)
		port map (
			clk 		=> clk,
			rst 		=> rst,
			vld_i 	=> vld_i,
			vld_o 	=> vld_o,
			p_i 		=> p_i,
			q_o 		=> q_o,
			q_dec_o 	=> q_dec_o);
	
	clk <= not clk after PERIOD / 2 when not finished;
	
	
	stimuli: process
		variable i   : integer range 0 to (2**(L*N+1));
		variable j   : std_logic_vector(L*N-1 downto 0) := (others => '0');
		variable tmp : std_logic_vector(L*N-1 downto 0) := (others => '0');
	begin
	
		wait until rising_edge(clk);
		rst 	<= '0';
		vld_i <= '1';

		while i < (2**(L*N+1))-1 loop
			j := std_logic_vector(to_unsigned(i, j'length));
				
			for k in 0 to L-1 loop
				if j(((L*N)-(2*k)-1) downto ((L*N)-(2*k)-2)) = ('1' & (N-2 downto 0 => '0')) then
					tmp := (others => '0');
					tmp((L*N)-(2*k)-2) := '1';
					i := i + to_integer(unsigned(tmp));
					j := std_logic_vector(to_unsigned(i, j'length));
				end if;
			
				p_i <= j(((L*N)-(2*k)-1) downto ((L*N)-(2*k)-2));
				wait until rising_edge(clk);
			end loop;
			
			i := i + 1;
		end loop;
			
--		wait for 1 ns;
--		assert (q_dec_o = ref_int) report integer'image(i) & ".1 number failed. " & integer'image(ref_int) & " expected, but is " & integer'image(q_dec_o) & "." severity error;
		
		vld_i <= '0';
		p_i 	<= (N-1 downto 0 => '0');
		wait until rising_edge(clk);
		rst 	<= '1';
		wait until rising_edge(clk);
		rst 	<= '0';
		
		finished <= true;
		wait;
		
	end process stimuli;


--	stimuli: process		-- manual tested
--	begin
	
--		wait until rising_edge(clk);
		
--		------------------------------------------------
--		-- 1. Tests  ->  r = 2
--		------------------------------------------------
--		-- 1.1 Test:
--		------------------------------------------------
--		rst 	<= '0';
--		vld_i <= '1';
--		p_i 	<= "01";
--		wait until rising_edge(clk);
		
--		p_i <= "11";
--		wait until rising_edge(clk);
			
--		p_i <= "11";
--		wait until rising_edge(clk);
		
--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "00";
--		wait until rising_edge(clk);

--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "01";
--		wait until rising_edge(clk);
		
--		p_i <= "01";
--		wait until rising_edge(clk);
		
--		vld_i <= '0';
--		p_i 	<= "00";
--		wait until rising_edge(clk);
		
		
--		--------------------------------------------------
--		-- 1.2 Test:
--		--------------------------------------------------
--		rst <= '1';
--		wait until rising_edge(clk);
		
--		rst 	<= '0';
--		vld_i <= '1';
--		p_i 	<= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "01";
--		wait until rising_edge(clk);
			
--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "11";
--		wait until rising_edge(clk);
		
--		p_i <= "01";
--		wait until rising_edge(clk);

--		p_i <= "01";
--		wait until rising_edge(clk);
		
--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "11";
--		wait until rising_edge(clk);
		
----		vld_i <= '0';
----		p_i 	<= "00";
----		wait until rising_edge(clk);
		
		
--		--------------------------------------------------
--		-- 1.3 Test:
--		--------------------------------------------------
--		rst 	<= '0';
--		vld_i <= '1';	
--		p_i 	<= "01";
--		wait until rising_edge(clk);
		
--		p_i <= "00";
--		wait until rising_edge(clk);
			
--		p_i <= "11";
--		wait until rising_edge(clk);
		
--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "01";
--		wait until rising_edge(clk);

--		p_i <= "11";
--		wait until rising_edge(clk);
		
--		p_i <= "11";
--		wait until rising_edge(clk);
		
--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		vld_i <= '0';
--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		--------------------------------------------------
--		-- 1.4 Test:
--		--------------------------------------------------
--		rst 	<= '0';
--		vld_i <= '1';
--		p_i 	<= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "01";
--		wait until rising_edge(clk);
			
--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "11";
--		wait until rising_edge(clk);
		
--		p_i <= "01";
--		wait until rising_edge(clk);

--		p_i <= "01";
--		wait until rising_edge(clk);
		
--		p_i <= "00";
--		wait until rising_edge(clk);
		
--		p_i <= "11";
--		wait until rising_edge(clk);
		
--		vld_i <= '0';
--		p_i 	<= "00";
--		wait until rising_edge(clk);


--		------------------------------------------------
--		-- 2. Tests  ->  r = 4 
--		------------------------------------------------
--		-- 2.1 Test:
--		------------------------------------------------
--		-- 2   0 (-1)  0   0   3 (-2)(-1) (red.)
--		-- 1   3   3   0   0   2   1   3  (con.)
--		------------------------------------------------
--		rst 	<= '0';
--		vld_i <= '1';
--		p_i 	<= "010";
--		wait until rising_edge(clk);
		
--		p_i <= "000";
--		wait until rising_edge(clk);
			
--		p_i <= "111";
--		wait until rising_edge(clk);
		
--		p_i <= "000";
--		wait until rising_edge(clk);
		
--		p_i <= "000";
--		wait until rising_edge(clk);

--		p_i <= "011";
--		wait until rising_edge(clk);
		
--		p_i <= "110";
--		wait until rising_edge(clk);
		
--		p_i <= "111";
--		wait until rising_edge(clk);
		
--		vld_i <= '0';
--		p_i <= "000";
--		wait for 2ns;
--		assert (q_o = "001011011000000010001011") report "1. conversion failed." severity error;

--		--------------------------------------------------
--		-- 2.2 Test:
--		--------------------------------------------------
--		-- 1 (-2)  0 (-1)  0   1   2 (-1) (red.)
--		-- 0   1   3   3   0   1   1   3  (con.)
--		--------------------------------------------------
--		rst <= '1';
--		wait until rising_edge(clk);		
		
--		rst 	<= '0';
--		vld_i <= '1';
--		p_i 	<= "001";
--		wait until rising_edge(clk);
		
--		p_i <= "110";
--		wait until rising_edge(clk);
			
--		p_i <= "000";
--		wait until rising_edge(clk);
		
--		p_i <= "111";
--		wait until rising_edge(clk);
		
--		p_i <= "000";
--		wait until rising_edge(clk);

--		p_i <= "001";
--		wait until rising_edge(clk);
		
--		p_i <= "010";
--		wait until rising_edge(clk);
		
--		p_i <= "111";
--		wait until rising_edge(clk);
		
--		vld_i <= '0';
--		p_i 	<= "000";
--		wait for 2ns;
--		assert (q_o = "000001011011000001001011") report "2. conversion failed." severity error;


--		rst <= '1';
--		wait until rising_edge(clk);
--		rst <= '0';
--		wait until rising_edge(clk);
		
		
--		finished <= true;
--		wait;
		
--	end process stimuli;

end sim;