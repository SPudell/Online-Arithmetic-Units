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
	constant L   	 : positive := 12;
	constant A 	 	 : positive := digit_set_bound(RAD); 
	constant N   	 : positive := bit_width(A); 
	
	-- component ports
	signal clk   	: std_logic := '1'; 
	signal rst   	: std_logic := '1';
	signal vld_i 	: std_logic := '0';
	signal vld_o 	: std_logic := '0';
	signal p_i 	 	: std_logic_vector(N-1 downto 0);
	signal q_o   	: std_logic_vector((L*(N-1))-1 downto 0);
	
--	signal i_in 	: std_logic_vector(L*N-1 downto 0) := (others => '0');
--	signal i_out 	: std_logic_vector((L*(N-1))-1 downto 0) := (others => '0');
		
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
			q_o 		=> q_o);
			
	
	clk <= not clk after PERIOD / 2 when not finished;
	
	
	stimuli: process
		variable i     : integer range 0 to (2**(L*N+1))-1;
		variable i_tmp : unsigned(L*N-1 downto 0) := (others => '0');
		variable i_max : unsigned(L*N-1 downto 0) := (others => '1');
		variable i_ref : std_logic_vector(L*(N-1)-1 downto 0) := (others => '0');
	begin
	
		wait until rising_edge(clk);
		rst 	<= '0';
		wait until rising_edge(clk);
		vld_i <= '1';
		
		
		while i <= i_max loop
			i_tmp := to_unsigned(i, i_tmp'length);
			
			for k in 0 to L-1 loop
				if i_tmp(((L*N)-(k*N)-1) downto ((L*N)-(k*N)-N)) = ('1' & (N-2 downto 0 => '0')) then
					i 		:= i + (2**((L*N)-(k*N)-N));
					i_tmp := to_unsigned(i, i_tmp'length);
				end if;
													
				p_i <= std_logic_vector(i_tmp(((L*N)-(k*N)-1) downto ((L*N)-(k*N)-N)));
				wait until rising_edge(clk);
			end loop;
			
			i_ref := std_logic_vector(to_unsigned(to_dec(RAD, L, N, std_logic_vector(i_tmp)), i_ref'length));
--			i_in	<= std_logic_vector(i_tmp);
--			i_out	<= i_ref;
			wait for 1 ns;
			assert (q_o = i_ref) report "Conversion failed. Is " &  integer'image(to_integer(signed(q_o))) & ", but " & integer'image(to_integer(signed(i_ref))) & " expected." severity error;
				
			i := i + 1;
		end loop;
				
		
		vld_i <= '0';
		p_i 	<= (others => '0');
		wait until rising_edge(clk);
		rst 	<= '1';
		wait until rising_edge(clk);
		rst 	<= '0';
		
		
		finished <= true;
		wait;
		
	end process stimuli;
end sim;