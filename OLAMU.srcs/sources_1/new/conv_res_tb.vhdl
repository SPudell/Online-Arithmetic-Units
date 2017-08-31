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
	constant L   	 : positive := 4;
	constant A 	 	 : positive := digit_set_bound(RAD); 
	constant N   	 : positive := bit_width(A); 
	
	-- component ports
	signal clk   	: std_logic := '1'; 
	signal rst   	: std_logic := '1';
	signal vld_i 	: std_logic := '0';
	signal vld_o 	: std_logic := '0';
	signal p_i 	 	: std_logic_vector(N-1   downto 0);
	signal q_o   	: std_logic_vector(L*N-1 downto 0);
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
		variable cnt 		: std_logic_vector(L-1 downto 0) := (others => '0');
		variable ref 		: std_logic_vector(L*N-1 downto 0) := (others => '0');
		variable ref_int	: integer := 0; 
	begin
	
		wait until rising_edge(clk);
		
		rst 	<= '0';
		vld_i <= '1';
		
		for i in 0 to (RAD**L)-1 loop
			cnt := std_logic_vector(to_unsigned(i, cnt'length));
			
			
			for j in 0 to L-1 loop			-- 0000  0001  0100  0101
				p_i <= '0' & cnt(L-1-j);	--  0 0   0 1   1 0   1 1
				ref((L*N)-1-(2*j) downto (L*N)-2-(2*j)) := '0' & cnt(L-1-j);
				wait until rising_edge(clk);
			end loop;
			
			wait for 1 ns;
			ref_int := to_dec(RAD, L, N, ref);
			
			if ref_int >= -(rad**(L-1)) then
				assert (q_dec_o = ref_int) report integer'image(i) & ".1 number failed. " & integer'image(ref_int) & " expected, but is " & integer'image(q_dec_o) & "." severity error;
			else
				report integer'image(i) & ".3 Overflow: Number " & integer'image(ref_int) & " out of range." severity error;
			end if;
			
			
			for j in 0 to L-1 loop					-- 0000   0011  1100   1111
				p_i <= cnt(L-1-j) & cnt(L-1-j);	--  0 0   0 -1  -1 0  -1 -1
				ref((L*N)-1-(2*j) downto (L*N)-2-(2*j)) := cnt(L-1-j) & cnt(L-1-j);
				wait until rising_edge(clk);
			end loop;
			
			wait for 1 ns;
			ref_int := to_dec(RAD, L, N, ref);
			
			if ref_int >= -(rad**(L-1)) then
				assert (q_dec_o = ref_int) report integer'image(i) & ".2 number failed. " & integer'image(ref_int) & " expected, but is " & integer'image(q_dec_o) & "." severity error;
			else
				report integer'image(i) & ".3 Overflow: Number " & integer'image(ref_int) & " out of range." severity error;
			end if;
		end loop;
		
		vld_i <= '0';
		p_i 	<= (N-1 downto 0 => '0');
		wait until rising_edge(clk);
		rst 	<= '1';
		wait until rising_edge(clk);
		rst 	<= '0';
		wait until rising_edge(clk);
		
		
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