library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity mine_freq is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		mine_sensor	: in	std_logic;
			
		mine_detect	: out	std_logic
	);
end entity mine_freq;

architecture behaviour of mine_freq is

	type mine_state is ( 	
				S0,
				S1, 
				S2
				);
	signal state, new_state : mine_state;
	signal mine_count, new_mine_count	: unsigned(19 downto 0);

begin
	process (reset,clk)
	begin
		if reset = '1' then 
		
			state <= S0; 
		 
		elsif rising_edge(clk) then 
			state <= new_state;	
			new_mine_count <= mine_count + 1;
		end if; 
	end process ;

	process (state, mine_sensor,new_mine_count)
	begin
		case state is
			when S0 => 
				mine_count <= (others => '0');
				mine_detect <= '0';
				new_state <= S1;
			when S1 =>
				if mine_sensor = '1' then 
					mine_count <= (others => '0');
					new_state <= S2; 
				end if; 
			when S2 => 
				mine_count <= new_mine_count;
				if mine_sensor = '0' then 
					if (unsigned(mine_count) < 2777) then 
						mine_detect <= '0'; 
					else  
						mine_detect <= '1'; 
					end if; 
					new_state <= S1;
				end if; 
		end case;
	end process;

	
end architecture behaviour;