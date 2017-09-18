------------------------------------------------------------
-- Digit-Serial Online-Adder for Radix > 2 (ds_oladd_rg2)
------------------------------------------------------------
-- Testbench
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ds_oladd_rg2_tb is
end ds_oladd_rg2_tb;

architecture sim of ds_oladd_rg2_tb is
	
	-- component generics
	constant RAD 	: positive := 4;
	constant A 		: positive := 3;
	constant N 		: positive := 3;
	
	-- component ports
	signal clk, rst : std_logic := '1';
	signal lst_i 	 : std_logic;
	signal x_i, y_i : std_logic_vector(N-1 downto 0);
	signal z_o		 : std_logic_vector(N-1 downto 0);
	
	-- control signal
	signal finished : boolean := false;
	
begin

	UUT: entity work.ds_oladd_rg2
		generic map (
			RAD => RAD,
			A		=> A,
			N		=> N)
		port map (
			clk 	=> clk,
			rst 	=> rst,
			lst_i => lst_i,
			x_i 	=> x_i,
			y_i 	=> y_i,
			z_o 	=> z_o
		);
		
	clk <= not clk after 10 ns when not finished;
	
	stimuli: process
	begin
		wait until rising_edge(clk);
		
		rst <= '0';
		x_i <= "001";
		y_i <= "010";
		wait until rising_edge(clk);
	
		x_i <= "010";
		y_i <= "111";
		wait until rising_edge(clk);
		
		x_i <= "101";
		y_i <= "101";
		wait for 2 ns;
		assert (z_o = "111") report "1. digit failed." severity error;
		wait until rising_edge(clk);
	
		x_i <= "011";
		y_i <= "011";
		wait for 2 ns;
		assert (z_o = "000") report "2. digit failed." severity error;
		wait until rising_edge(clk);
		
		x_i <= "000";
		y_i <= "010";	
		wait for 2 ns;
		assert (z_o = "111") report "3. digit failed." severity error;
		wait until rising_edge(clk);	
		
		x_i <= "111";
		y_i <= "010";
		wait for 2 ns;
		assert (z_o = "010") report "4. digit failed." severity error;
		wait until rising_edge(clk);
	
		x_i <= "000";
		y_i <= "000";
		wait for 2 ns;
		assert (z_o = "010") report "5. digit failed." severity error;
		wait until rising_edge(clk);
		
		x_i <= "000";
		y_i <= "000";	
		wait for 2 ns;
		assert (z_o = "001") report "6. digit failed." severity error;
		wait until rising_edge(clk);
		
				
		finished <= true;
		wait;
		
	end process stimuli;
end sim;