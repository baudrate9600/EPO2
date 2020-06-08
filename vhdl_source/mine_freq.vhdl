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
				reset_state,
				wait_for_high, 
				count_high
				);
	signal state, new_state : mine_state;
	signal mine_count, new_mine_count	: unsigned(19 downto 0);

begin
	process (reset,clk)
	begin
		if reset = '1' then 
		
			state <= reset_state; 
		 
		elsif rising_edge(clk) then 
			state <= new_state;	
			new_mine_count <= mine_count + 1;
		end if; 
	end process ;

	process (state, mine_sensor,new_mine_count)
	begin
		case state is
			when reset_state => 
				mine_count <= (others => '0');
				mine_detect <= '0';
				new_state <= wait_for_high;
			when wait_for_high =>
				if mine_sensor = '1' then 
					mine_count <= (others => '0');
					new_state <= count_high; 
				end if; 
			when count_high => 
				mine_count <= new_mine_count;
				if mine_sensor = '0' then 
					if (unsigned(mine_count) < 2500) then 
						mine_detect <= '0'; 
					else  
						mine_detect <= '1'; 
					end if; 
					new_state <= wait_for_high;
				end if; 
		end case;
	end process;

	
end architecture behaviour;