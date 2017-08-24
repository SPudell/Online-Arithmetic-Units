------------------------------------------------------------
-- Digit-Serial Online-Adder for Radix = 2 (ds_oladd_r2)
------------------------------------------------------------
-- Testbench
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ds_oladd_r2_tb is
end ds_oladd_r2_tb;

architecture sim of ds_oladd_r2_tb is
	
	-- component ports
	signal clk, rst : std_logic := '1';
	signal x_i, y_i : std_logic_vector(1 downto 0);
	signal z_o		 : std_logic_vector(1 downto 0);
	
	-- control signal
	signal finished : boolean := false;
	
begin

	UUT: entity work.ds_oladd_r2
		port map (
			clk => clk,
			rst => rst,
			x_i => x_i,
			y_i => y_i,
			z_o => z_o
		);
	
	clk <= not clk after 10 ns when not finished;
	
	stimuli: process
	begin
		wait until rising_edge(clk);
		
		rst <= '0';
		x_i <= "00";
		y_i <= "10";
		wait until rising_edge(clk);
	
		x_i <= "10";
		y_i <= "00";
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "01";	
		wait until rising_edge(clk);		
		
		x_i <= "01";
		y_i <= "00";
		wait for 2 ns;
		assert (z_o = "01") report "1. digit failed." severity error;
		wait until rising_edge(clk);
	
		x_i <= "10";
		y_i <= "10";
		wait for 2 ns;
		assert (z_o = "11") report "2. digit failed." severity error;
		wait until rising_edge(clk);
		
		x_i <= "10";
		y_i <= "01";	
		wait for 2 ns;
		assert (z_o = "10") report "3. digit failed." severity error;
		wait until rising_edge(clk);	
		
		x_i <= "00";
		y_i <= "01";
		wait for 2 ns;
		assert (z_o = "00") report "4. digit failed." severity error;
		wait until rising_edge(clk);
	
		x_i <= "01";
		y_i <= "00";
		wait for 2 ns;
		assert (z_o = "11") report "5. digit failed." severity error;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "00";	
		wait for 2 ns;
		assert (z_o = "01") report "6. digit failed." severity error;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "00";
		wait for 2 ns;
		assert (z_o = "11") report "7. digit failed." severity error;
		wait until rising_edge(clk);
	
		x_i <= "00";
		y_i <= "00";
		wait for 2 ns;
		assert (z_o = "10") report "8. digit failed." severity error;
		wait until rising_edge(clk);
		
		finished <= true;
		wait;
		
	end process stimuli;
end sim;
