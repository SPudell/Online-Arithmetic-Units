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
	constant RAD	 	: positive := 16;								-- radix
	constant L		 	: positive := 3;								-- operand-length -> #digits per operand
	constant D		 	: positive := get_online_delay(RAD);	-- online-delay
	constant A 		 	: positive := digit_set_bound(RAD);		-- boundary of the digit-set for specific radix
	constant N   	 	: positive := bit_width(A);				-- necessary bit-wdith for representation for digits in the set
	constant W   	 	: positive := L*(N-1);						-- bit-wdith for result-vector in conventional representation  
		
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
	
	signal sig_chk_i	: std_logic := '0';
	signal sig_chk_o	: std_logic := '0';
	
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
		variable cnt_s, cnt_f : integer := 0;
		variable i, j 			 : integer range 0 to (2**(L*N+1))-1 := 0;
		variable i_tmp, j_tmp : unsigned(L*N-1 downto 0) := (others => '0');
		variable i_max, j_max : unsigned(L*N-1 downto 0) := (others => '1');
	begin
		------------------------------
		-- 1. Simu.-Init.
		------------------------------
		wait until rising_edge(clk);
		rst 	<= '0';
		vld_i <= '0';
		lst_i <= '0';
		x_i 	<= (others => '0');
		y_i 	<= (others => '0');
		wait until rising_edge(clk);
		
		------------------------------
		-- 2. Simu.-Exec.
		------------------------------
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
					
					if vld_z_o = '1' then
						if q_z_o = sig_ref_o then
							report integer'image(cnt_s + cnt_f + 1) & ". Computation succeeded. Is " &  integer'image(to_integer(signed(q_z_o))) & ", and " & integer'image(to_integer(signed(sig_ref_o))) & " expected.";
							cnt_s := cnt_s + 1;
						else
							report integer'image(cnt_s + cnt_f + 1) & ". Computation failed. Is " &  integer'image(to_integer(signed(q_z_o))) & ", but " & integer'image(to_integer(signed(sig_ref_o))) & " expected.";
							cnt_f := cnt_f + 1;
						end if;
					end if;
				end loop;
				
				vld_i 	 <= '0';
				lst_i 	 <= '0';
				sig_ref_i <= std_logic_vector(to_signed((to_dec(RAD, L, N, std_logic_vector(i_tmp)) + to_dec(RAD, L, N, std_logic_vector(j_tmp))), sig_ref_i'length));
				
				j := j + 1;
			end loop;
			
			j := 0;
			i := i + 1;
		end loop;
						
		------------------------------
		-- 3. Simu.-Final.
		------------------------------
		vld_i <= '0';
		lst_i <= '0';
		x_i 	<= (others => '0');
		y_i 	<= (others => '0');
		
		-- wait for last result digit
		for m in 0 to D loop
			wait until rising_edge(clk);
		end loop;
		
		if vld_z_o = '1' then
			if q_z_o = sig_ref_o then
				report integer'image(cnt_s + cnt_f + 1) & ". Computation succeeded. Is " &  integer'image(to_integer(signed(q_z_o))) & ", and " & integer'image(to_integer(signed(sig_ref_o))) & " expected.";
				cnt_s := cnt_s + 1;
			else
				report integer'image(cnt_s + cnt_f + 1) & ". Computation failed. Is " &  integer'image(to_integer(signed(q_z_o))) & ", but " & integer'image(to_integer(signed(sig_ref_o))) & " expected.";
				cnt_f := cnt_f + 1;
			end if;
		end if;
		
		-- final report
		report "Result: Out of " & integer'image(cnt_s + cnt_f) & " calculations were " & integer'image(cnt_s) & " successful and " &  integer'image(cnt_f) & " failed.";
				
		
		finished <= true;
		wait;	
		
	end process stimuli;
end sim;