library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package functions is
	function to_dec(rad: positive; l: positive; n: positive; x: std_logic_vector) return integer;
	function to_bin(rad: positive; l: positive; n: positive; x: integer) return std_logic_vector;
	function digit_set_bound(arg : positive) return positive;
	function bit_width(arg : positive) return positive;
	function log_2_ceil(arg : positive) return positive;
end package functions;

package body functions is
	
	-- calcs the decimal value of a digit-vector with different radix (l -> #digits per vector, n -> #bit per digit)
	function to_dec(rad: positive; l: positive; n: positive; x: std_logic_vector) return integer is
		variable res : integer := 0;
	begin
		res := to_integer(signed(x((l*n)-1 downto (l*n)-n)));
				
		if l > 1 then
			for i in 1 to l-1 loop
				res := (res * rad) + to_integer(signed(x(((l-i)*n)-1 downto ((l-i)*n)-n)));
			end loop;
		end if;
		
		return res;
	end;
	
	-- calcs the binary digit-vector with different radix of a decimal number (l -> #digits per vector, n -> #bit per digit)
	function to_bin(rad: positive; l: positive; n: positive; x: integer) return std_logic_vector is
			variable res : std_logic_vector(l*n-1 downto 0) := (others => '0');
		begin
			
			
			return res;
		end;
	
	-- calcs digit-set boundary for a special radix -> a = (r + 1) / 2
	function digit_set_bound(arg : positive) return positive is
		variable tmp : positive;								
		variable res : natural;
	begin
		tmp := 1;
		res := 0;
		
		if arg = 2 then
			res := 1;
		elsif arg > 2 then
			tmp := arg + 1;
			
			if (tmp mod 2) = 0 then
				res := tmp / 2;
			else
				res := (tmp + 1) / 2;
			end if;
		end if;
				
		return res;
	end;

	-- calcs the necessary bit-widths to represent a number -> n = log2(a + 1) + 1
	function bit_width(arg : positive) return positive is
		variable hlp : positive;
		variable tmp : positive;								
		variable res : natural;
	begin
		hlp := arg + 1;
		tmp := 1;		
		res := 0;
		
		while hlp > tmp loop
			tmp := tmp * 2;
			res := res + 1;
		end loop;
				
		return res + 1;
	end;
	
	--calcs log2 of a number and rounds the result up to the next integer -> y = ceil(log2(x))
	function log_2_ceil(arg : positive) return positive is
		variable tmp : positive;								
		variable res : natural;
	begin
		tmp := 1;		
		res := 0;
	
		if arg = 1 then
			  res := 1;
		else		
			while arg > tmp loop
				tmp := tmp * 2;
				res := res + 1;
			end loop;
		end if;
				
		return res;
	end;
			
end functions;