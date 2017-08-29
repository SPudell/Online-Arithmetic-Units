------------------------------------------------------------
-- Dynamic-Precision Online-Adder Top-Level (dp_oladd_top)
------------------------------------------------------------
-- Testbench
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;

entity dp_oladd_top_tb is
end dp_oladd_top_tb;

architecture sim of dp_oladd_top_tb is
	
	-- component generics
	constant PERIOD : Time := 10 ns;
	constant RAD	 : positive := 2;
	constant L		 : positive := 8;
	constant A 		 : positive := digit_set_bound(RAD);
	constant N   	 : positive := bit_width(A);
	
	-- component ports
	signal clk, rst 		: std_logic := '1';
	signal vld_i, lst_i	: std_logic;
	signal vld_o, lst_o	: std_logic;
	signal q_vld_o			: std_logic;
	signal rdy_o			: std_logic;
	signal x_i, y_i 		: std_logic_vector(N-1 downto 0);
	signal z_o		 		: std_logic_vector(N-1 downto 0);
	signal q_o 				: std_logic_vector(L*N-1 downto 0);
	signal q_dec_o			: integer;
	
	-- control signal
	signal finished : boolean := false;
	
begin

	UUT: entity work.dp_oladd_top
		generic map (
			RAD => RAD,
			L 	 => L)
		port map (
			clk 		=> clk,
			rst 		=> rst,
			lst_i 	=> lst_i,
			vld_i 	=> vld_i,
			lst_o 	=> lst_o,
			vld_o 	=> vld_o,
			q_vld_o 	=> q_vld_o,
			rdy_o 	=> rdy_o,
			x_i 		=> x_i,
			y_i 		=> y_i,
			z_o 		=> z_o,
			q_o		=> q_o,
			q_dec_o	=> q_dec_o);
		
	clk <= not clk after PERIOD / 2 when not finished;
	
	stimuli: process -- r = 2, l = 8
	begin		
		
		----------------------------------------------------------------------
		-- 1. Test:
		----------------------------------------------------------------------
		-- x =   0    1    0   (-1)   1     1     0   (-1) = 59
		-- y =   1    0  (-1)    0    1   (-1)  (-1)    0	= 98
		-- -----------------------------------------------------------
		-- z = (-1)   0    1     0    0   (-1)    0     1  = 157 = -99
		----------------------------------------------------------------------
		
		wait until rising_edge(clk);
		
		rst	<= '0';
		vld_i <= '0';
		lst_i <= '0';
		x_i 	<= "00";
		y_i 	<= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		vld_i <= '1';
		x_i 	<= "00";
		y_i 	<= "01";
		wait for 2 ns;
		wait until rising_edge(clk);
	
		x_i <= "01";
		y_i <= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "11";	
		wait for 2 ns;
		wait until rising_edge(clk);		
		
		x_i <= "11";
		y_i <= "00";
		wait for 2 ns;
		assert (z_o = "11") report "1. digit failed." severity error;
		wait until rising_edge(clk);
	
		x_i <= "01";
		y_i <= "01";
		wait for 2 ns;
		assert (z_o = "00") report "2. digit failed." severity error;
		wait until rising_edge(clk);
		
		x_i <= "01";
		y_i <= "11";	
		wait for 2 ns;
		assert (z_o = "01") report "3. digit failed." severity error;
		wait until rising_edge(clk);	
		
		x_i <= "00";
		y_i <= "11";
		wait for 2 ns;
		assert (z_o = "00") report "4. digit failed." severity error;
		wait until rising_edge(clk);
	
		lst_i <= '1';
		x_i <= "11";
		y_i <= "00";
		wait for 2 ns;
		assert (z_o = "00") report "5. digit failed." severity error;
		wait until rising_edge(clk);
		
		lst_i <= '0';
		vld_i <= '0';
		x_i <= "00";
		y_i <= "00";	
		wait for 2 ns;
		assert (z_o = "11") report "6. digit failed." severity error;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "00";
		wait for 2 ns;
		assert (z_o = "00") report "7. digit failed." severity error;
		assert (lst_o = '0') report "Last-flag(1) failed. Has to be 0." severity error;
		wait until rising_edge(clk);
	
		x_i <= "00";
		y_i <= "00";
		wait for 2 ns;
		assert (z_o = "01") report "8. digit failed." severity error;
		assert (lst_o = '1') report "Last-flag(2) failed. Has to be 1." severity error;
		assert (vld_o = '1') report "Valid-flag(1) failed. Has to be 1." severity error;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "00";
		wait for 2 ns;
		assert (lst_o = '0') report "Last-flag(3) failed. Has to be 0." severity error;
		assert (vld_o = '0') report "Valid-flag(2) failed. Has to be 0." severity error;
		wait until rising_edge(clk);
		
		
		----------------------------------------------------------------------
		-- 2. Test:
		----------------------------------------------------------------------
		-- x =   1  (-1)    0    0    0     1     0   (-1) = 67
		-- y =   1  (-1) (-1)    1    0     0     1     0	= 50
		-- ------------------------------------------------------------
		-- z = (-1)   0  (-1)    1    1   (-1)    0     1  = 117 = -139 
		----------------------------------------------------------------------
		
		vld_i <= '1';
		lst_i <= '0';
		x_i 	<= "01";
		y_i 	<= "01";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "11";
		y_i <= "11";
		wait for 2 ns;
		wait until rising_edge(clk);
	
		x_i <= "00";
		y_i <= "11";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "01";	
		wait for 2 ns;
		wait until rising_edge(clk);		
		
		x_i <= "00";
		y_i <= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
	
		x_i <= "01";
		y_i <= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "01";	
		wait for 2 ns;
		wait until rising_edge(clk);	
		
		lst_i <= '1';
		x_i <= "11";
		y_i <= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
			
		lst_i <= '0';
		vld_i <= '0';
		x_i <= "00";
		y_i <= "00";	
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
	
		x_i <= "00";
		y_i <= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		
		----------------------------------------------------------------------
		-- 3. Test:
		----------------------------------------------------------------------
		-- x =   0    1    0   (-1)  (-1)    1     0   (-1) = 43
		-- y =   0    1  (-1)    1     1   (-1)    1     1	 = 55
		-- -----------------------------------------------------
		-- z =   1  (-1)   1     0     0     0     1     0  = 98
		----------------------------------------------------------------------
		
		vld_i <= '1';
		lst_i <= '0';
		x_i 	<= "00";
		y_i 	<= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "01";
		y_i <= "01";
		wait for 2 ns;
		wait until rising_edge(clk);
	
		x_i <= "00";
		y_i <= "11";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "11";
		y_i <= "01";	
		wait for 2 ns;
		wait until rising_edge(clk);		
		
		x_i <= "11";
		y_i <= "01";
		wait for 2 ns;
		wait until rising_edge(clk);
	
		x_i <= "01";
		y_i <= "11";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "01";	
		wait for 2 ns;
		wait until rising_edge(clk);	
		
		lst_i <= '1';
		x_i <= "11";
		y_i <= "01";
		wait for 2 ns;
		wait until rising_edge(clk);
			
--		lst_i <= '0';
--		vld_i <= '0';
--		x_i <= "00";
--		y_i <= "00";	
--		wait for 2 ns;
--		wait until rising_edge(clk);
		
--		x_i <= "00";
--		y_i <= "00";
--		wait for 2 ns;
--		wait until rising_edge(clk);
	
--		x_i <= "00";
--		y_i <= "00";
--		wait for 2 ns;
--		wait until rising_edge(clk);
		
		
		----------------------------------------------------------------------
		-- 4. Test:
		----------------------------------------------------------------------
		-- x =   0    1    0    0    1    1    0    0 = 76
		-- y =   0    0    1    1    1    0    1    1 = 59
		-- ------------------------------------------------
		-- z =   1    0    0    0    1    0  (-1)   1 = 135
		----------------------------------------------------------------------
		
		vld_i <= '1';
		lst_i <= '0';
		x_i 	<= "00";
		y_i 	<= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "01";
		y_i <= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
	
		x_i <= "00";
		y_i <= "01";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "01";	
		wait for 2 ns;
		wait until rising_edge(clk);		
		
		x_i <= "01";
		y_i <= "01";
		wait for 2 ns;
		wait until rising_edge(clk);
	
		x_i <= "01";
		y_i <= "00";
		wait for 2 ns;
		wait until rising_edge(clk);
		
		x_i <= "00";
		y_i <= "01";	
		wait for 2 ns;
		wait until rising_edge(clk);	
		
		lst_i <= '1';
		x_i <= "00";
		y_i <= "01";
		wait for 2 ns;
		wait until rising_edge(clk);
			
		lst_i <= '0';
		vld_i <= '0';
		x_i <= "00";
		y_i <= "00";
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
		
		rst <= '1';
		wait until rising_edge(clk);
		
		rst <= '0';
		wait until rising_edge(clk);
						
		
		finished <= true;
		wait;
		
	end process stimuli;
	
	
--	stimuli: process -- r = 4, l = 6
--	begin
	
--		wait until rising_edge(clk);
		
--		rst	<= '0';
--		vld_i <= '1';
--		lst_i <= '0';
--		x_i 	<= "001";
--		y_i 	<= "010";
--		wait until rising_edge(clk);
	
--		x_i <= "010";
--		y_i <= "111";
--		wait until rising_edge(clk);
		
--		x_i <= "101";
--		y_i <= "101";
--		wait for 2 ns;
--		assert (z_o = "111") report "1. digit failed." severity error;
--		wait until rising_edge(clk);
	
--		x_i <= "011";
--		y_i <= "011";
--		wait for 2 ns;
--		assert (z_o = "000") report "2. digit failed." severity error;
--		wait until rising_edge(clk);
		
--		x_i <= "000";
--		y_i <= "010";	
--		wait for 2 ns;
--		assert (z_o = "111") report "3. digit failed." severity error;
--		wait until rising_edge(clk);	
		
--		lst_i <= '1';
--		x_i 	<= "111";
--		y_i 	<= "010";
--		wait for 2 ns;
--		assert (z_o = "010") report "4. digit failed." severity error;
--		wait until rising_edge(clk);
	
--		lst_i <= '0';
--		vld_i <= '0';
--		x_i <= "000";
--		y_i <= "000";
--		wait for 2 ns;
--		assert (z_o = "010") report "5. digit failed." severity error;
--		wait until rising_edge(clk);
		
--		x_i <= "000";
--		y_i <= "000";	
--		wait for 2 ns;
--		assert (z_o = "001") report "6. digit failed." severity error;
--		wait until rising_edge(clk);
--		wait until rising_edge(clk);
		
		
--		finished <= true;
--		wait;
		
--	end process stimuli;
end sim;