library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package functions is
	function digit_set_bound(arg : positive) return positive;
	function bit_width(arg : positive) return positive;
	function log_2_ceil(arg : positive) return positive;
end package functions;

package body functions is
	
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