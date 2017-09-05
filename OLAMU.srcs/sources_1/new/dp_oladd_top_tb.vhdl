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
	constant PERIOD 	: Time := 10 ns;
	constant RAD	 	: positive := 2;
	constant L		 	: positive := 2;
	constant D		 	: positive := get_online_delay(RAD);
	constant A 		 	: positive := digit_set_bound(RAD);
	constant N   	 	: positive := bit_width(A);
	constant W   	 	: positive := L*(N-1);
		
	-- component ports
	signal clk, rst 	: std_logic := '1';
	signal vld_i 		: std_logic;
	signal lst_i		: std_logic;
	signal vld_o 		: std_logic;
	signal lst_o		: std_logic;
	signal rdy_o		: std_logic;
	signal vld_x_o		: std_logic;
	signal vld_y_o		: std_logic;
	signal vld_z_o		: std_logic;
	signal x_i, y_i 	: std_logic_vector(N-1 downto 0);
	signal z_o		 	: std_logic_vector(N-1 downto 0);
	signal q_x_o 		: std_logic_vector(W-1 downto 0) := (others => '0'); 
	signal q_y_o		: std_logic_vector(W-1 downto 0) := (others => '0');
	signal q_z_o 		: std_logic_vector(W-1 downto 0) := (others => '0');
	signal sig_ref_i 	: std_logic_vector(W-1 downto 0) := (others => '0');
	signal sig_ref_o	: std_logic_vector(W-1 downto 0) := (others => '0');
	
	signal success		: std_logic := '0';
	
	-- control signal
	signal finished 	: boolean := false;
	
begin

	UUT: entity work.dp_oladd_top
		generic map (
			RAD 		=> RAD,
			L 	 		=> L)
		port map (
			clk 		=> clk,
			rst 		=> rst,
			lst_i 	=> lst_i,
			vld_i 	=> vld_i,
			lst_o 	=> lst_o,
			vld_o 	=> vld_o,
			rdy_o 	=> rdy_o,
			vld_x_o 	=> vld_x_o,
			vld_y_o 	=> vld_y_o,
			vld_z_o 	=> vld_z_o,
			x_i 		=> x_i,
			y_i 		=> y_i,
			z_o 		=> z_o,
			q_x_o		=> q_x_o,
			q_y_o		=> q_y_o,
			q_z_o		=> q_z_o);
	
	shift_reg_ref: entity work.shift_reg
		generic map (
			I 			=> D,
			W 			=> W)
		port map (
			clk 	 	=> clk,
			rst 	 	=> rst,
			data_i 	=> sig_ref_i,
			data_o 	=> sig_ref_o);
		
	clk <= not clk after PERIOD / 2 when not finished;
	
	
	stimuli: process
		variable cnt 	: integer := 0;
		variable cnt_s : integer := 0;
		variable cnt_f : integer := 0;
		variable i, j 	: integer range 0 to (2**(L*N+1))-1 := 0;
		variable i_tmp : unsigned(L*N-1 downto 0) := (others => '0');
		variable j_tmp : unsigned(L*N-1 downto 0) := (others => '0');
		variable i_max : unsigned(L*N-1 downto 0) := (others => '1');
		variable j_max : unsigned(L*N-1 downto 0) := (others => '1');
	begin
	
		wait until rising_edge(clk);
		rst 	<= '0';
		vld_i <= '0';
		lst_i <= '0';
		success <= '0';
		x_i 	<= (others => '0');
		y_i 	<= (others => '0');
		wait until rising_edge(clk);
		vld_i <= '1';
		
		
		while i <= i_max loop
			i_tmp := to_unsigned(i, i_tmp'length);
			
			
			while j <= j_max loop
				j_tmp := to_unsigned(j, j_tmp'length);
				
				vld_i <= '1';
				
				for k in 0 to L-1 loop
					if i_tmp(((L*N)-(k*N)-1) downto ((L*N)-(k*N)-N)) = ('1' & (N-2 downto 0 => '0')) then
						i 		:= i + (2**((L*N)-(k*N)-N));
						i_tmp := to_unsigned(i, i_tmp'length);
					end if;
					
					if j_tmp(((L*N)-(k*N)-1) downto ((L*N)-(k*N)-N)) = ('1' & (N-2 downto 0 => '0')) then
						j 		:= j + (2**((L*N)-(k*N)-N));
						j_tmp := to_unsigned(j, j_tmp'length);
					end if;
					
					if k = L-1 then
						lst_i <= '1';
					end if;
					
					x_i <= std_logic_vector(i_tmp(((L*N)-(k*N)-1) downto ((L*N)-(k*N)-N)));
					y_i <= std_logic_vector(j_tmp(((L*N)-(k*N)-1) downto ((L*N)-(k*N)-N)));
					wait until rising_edge(clk);
					lst_i <= '0';
					success <= '0';	
				end loop;
				
				vld_i <= '0';
								
				cnt := cnt + 1;
				sig_ref_i <= std_logic_vector(to_unsigned((to_dec(RAD, L, N, std_logic_vector(i_tmp)) + to_dec(RAD, L, N, std_logic_vector(j_tmp))), sig_ref_i'length));
				--assert (q_z_o = sig_ref_o) report integer'image(cnt-(D-1)) & ". Computation failed. Is " &  integer'image(to_integer(signed(q_z_o))) & ", but " & integer'image(to_integer(signed(sig_ref_o))) & " expected." severity error;
				if q_z_o = sig_ref_o then
					report integer'image(cnt-(D-1)) & ". Computation succeeded. Is " &  integer'image(to_integer(signed(q_z_o))) & ", but " & integer'image(to_integer(signed(sig_ref_o))) & " expected.";
					cnt_s := cnt_s + 1;
					success <= '1';
				else
					report integer'image(cnt-(D-2)) & ". Computation failed. Is " &  integer'image(to_integer(signed(q_z_o))) & ", but " & integer'image(to_integer(signed(sig_ref_o))) & " expected.";
					cnt_f := cnt_f + 1;
					success <= '0';
				end if;
				
				j := j + 1;
			end loop;
			
			j := 0;
			i := i + 1;
		end loop;
		
		report "Result: Out of " & integer'image(cnt_s + cnt_f) & " calculations were " & integer'image(cnt_s) & " successful and " &  integer'image(cnt_f) & " failed.";
				
		
		vld_i <= '0';
		lst_i <= '0';
		x_i 	<= (others => '0');
		y_i 	<= (others => '0');
		
		for m in 0 to D loop
			wait until rising_edge(clk);
		end loop;
		
		rst 	<= '1';
		wait until rising_edge(clk);
		rst 	<= '0';
		
		
		finished <= true;
		wait;	
		
	end process stimuli;
end sim;