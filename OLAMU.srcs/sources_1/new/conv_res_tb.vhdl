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
	constant RAD : positive := 4;
	constant L   : positive := 8;
	constant A 	 : positive := digit_set_bound(RAD); 
	constant N   : positive := bit_width(A); 
	
	-- component ports
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal p_i : std_logic_vector(N-1   downto 0);
	signal q_o : std_logic_vector(L*N-1 downto 0);
	
	-- control signal
	signal finished : boolean := false;
	
begin

	UUT: entity work.conv_res
		generic map(
			RAD => RAD,
			L => L,
			N => N
		)
		port map (
			clk => clk,
			rst => rst,
			p_i => p_i,
			q_o => q_o
		);
	
	clk <= not clk after 10 ns when not finished;
	
	stimuli: process
	begin
	
		wait until rising_edge(clk);
		
		
		--------------------------------------------------
		-- 1. Test:
		-- 2   0 (-1)  0   0   3 (-2)(-1) (red.)
		-- 1   3   3   0   0   2   1   3  (con.)
		--------------------------------------------------
		
		rst <= '0';		
		p_i <= "010";
		wait until rising_edge(clk);
		
		p_i <= "000";
		wait until rising_edge(clk);
			
		p_i <= "111";
		wait until rising_edge(clk);
		
		p_i <= "000";
		wait until rising_edge(clk);
		
		p_i <= "000";
		wait until rising_edge(clk);

		p_i <= "011";
		wait until rising_edge(clk);
		
		p_i <= "110";
		wait until rising_edge(clk);
		
		p_i <= "111";
		wait until rising_edge(clk);
		
		p_i <= "000";
		wait for 2ns;
		assert (q_o = "001011011000000010001011") report "1. conversion failed." severity error;
		wait until rising_edge(clk);
		
		
		--------------------------------------------------
		-- 2. Test:
		-- 1 (-2)  0 (-1)  0   1   2 (-1) (red.)
		-- 0   1   3   3   0   1   1   3  (con.)
		--------------------------------------------------
		
		rst <= '1';
		wait until rising_edge(clk);		
		
		rst <= '0';
		p_i <= "001";
		wait until rising_edge(clk);
		
		p_i <= "110";
		wait until rising_edge(clk);
			
		p_i <= "000";
		wait until rising_edge(clk);
		
		p_i <= "111";
		wait until rising_edge(clk);
		
		p_i <= "000";
		wait until rising_edge(clk);

		p_i <= "001";
		wait until rising_edge(clk);
		
		p_i <= "010";
		wait until rising_edge(clk);
		
		p_i <= "111";
		wait until rising_edge(clk);
		
		p_i <= "000";
		wait for 2ns;
		assert (q_o = "000001011011000001001011") report "2. conversion failed." severity error;
		wait until rising_edge(clk);
				
		
		finished <= true;
		wait;
		
	end process stimuli;
end sim;