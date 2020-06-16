--Parity checker
--Allemaal wel leuk en aardig tot the host twee error bits stuurt (⊙_⊙)？
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parity is 
	port(
		data_in    : in std_logic_vector(8 downto 0); 
		data_error : out std_logic
		);
end parity; 

architecture structural of parity is 
	--Intermediate signals 
	signal  parity_bit : std_logic;
	signal	z_0, z_1, z_2, z_3 : std_logic;	
	signal  y_0, y_1 : std_logic;
	signal  x : std_logic;

begin 
	parity_bit <=data_in(8);	

	--Xor two bits and store the product 
	z_0 <= data_in(0) xor data_in(1);
	z_1 <= data_in(2) xor data_in(3);
	z_2 <= data_in(4) xor data_in(5);
	z_3 <= data_in(6) xor data_in(7);
	
	--again xor two of the 4 xor'd bits 
	y_0 <= z_0 xor z_1; 
	y_1 <= z_2 xor z_3;
	
	--If the bit has a even amount of bits x = 0 
	--..if it has an odd number of bits x = 1 
	x <= y_0 xor y_1;
	
	--If the host claimed to have sent an odd/even amount of bits 
	--..by xor  the computed parity with the parity bit it can be 
	--..determined if there was an error 
	data_error <= x xor parity_bit;
		

end structural;
			
