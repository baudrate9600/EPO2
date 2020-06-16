--Test bench of the parity checker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parity_tb is 
end parity_tb;



architecture test of parity_tb is 
	component parity is 
		port(
			data_in    : in std_logic_vector(8 downto 0); 
			data_error : out std_logic
			);
	end component parity; 
	signal data_in : std_logic_vector(8 downto 0); 
	signal data_error : std_logic; 

begin 
	DUT: parity port map(data_in,data_error);
process begin 
	--Even amount of bits so parity is zero 
	data_in <= "101010100";
	wait for 10 ns; 
	--Oneven amount of bits so
	data_in <= "101010001";
	wait for 10 ns; 
	--
	data_in <= "101010101";
	wait for 10 ns; 
	--
	data_in <= "101010000";
	wait for 10 ns; 
	wait;
end process;



end test;
