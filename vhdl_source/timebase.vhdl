library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity timebase is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;

		count_out	: out	std_logic_vector (19 downto 0)
	);
end entity timebase;

architecture behaviour of timebase is
signal count, new_count: unsigned (19 downto 0);

begin
	process(clk,reset)
	begin
		if (clk'event and clk='1') then
			if (reset='1') then
				count <= (others => '0');
			else
				count <= new_count;
			end if;
		end if;
	end process;
	
	process(count)
	begin
			new_count <= count + 1;
	end process;
	count_out <= std_logic_vector (count);
end behaviour;
 
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity timebase_tb is
end entity timebase_tb;

architecture structural of timebase_tb is
	component timebase is
		port (	clk		: in	std_logic;
			reset		: in	std_logic;

			count_out	: out	std_logic_vector (19 downto 0)
		);
	end component;
	signal clk, reset: std_logic;
	signal count_out: std_logic_vector (19 downto 0);
begin
	clk <= '0' after 0 ns, '1' after 10 ns when clk/= '1' else '0' after 10 ns;
	reset <= '1' after 0 ns, '0' after 11 ns;
L1: timebase port map (clk=>clk, reset=>reset, count_out=>count_out);

end structural;