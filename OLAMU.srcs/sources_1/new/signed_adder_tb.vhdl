------------------------------------------------------------
-- Signed-Adder (signed_adder)
------------------------------------------------------------
-- Testbench
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity signed_adder_tb is
end signed_adder_tb;

architecture sim of signed_adder_tb is
	
	-- component generics
	constant N : positive := 3;
	
	-- component ports
	signal clk		 : std_logic := '0';
	signal a_i, b_i : std_logic_vector(N-1 downto 0);
	signal s_o		 : std_logic_vector(N   downto 0);
	
	-- control signal
	signal finished : boolean := false;
	
begin

	UUT: entity work.signed_adder
		generic map(
			N => N
		)
		port map (
			a_i => a_i,
			b_i => b_i,
			s_o => s_o
		);
	
	clk <= not clk after 10 ns when not finished;
	
	stimuli: process
	begin
			
		a_i <= "000";
		b_i <= "000";
		wait until rising_edge(clk);
	
		a_i <= "001";
		b_i <= "010";
		wait until rising_edge(clk);		
		
		a_i <= "001";
		b_i <= "111";
		wait until rising_edge(clk);
	
		a_i <= "101";
		b_i <= "110";
		wait until rising_edge(clk);
				
		a_i <= "011";
		b_i <= "011";
		wait until rising_edge(clk);
	
		a_i <= "101";
		b_i <= "101";
		wait until rising_edge(clk);
		
		a_i <= "010";
		b_i <= "110";
		wait until rising_edge(clk);
	
		a_i <= "011";
		b_i <= "101";
		wait until rising_edge(clk);
		
		a_i <= "111";
		b_i <= "101";
		wait until rising_edge(clk);
	
		a_i <= "111";
		b_i <= "111";
		wait until rising_edge(clk);
		
		
		finished <= true;
		wait;
		
	end process stimuli;
end sim;