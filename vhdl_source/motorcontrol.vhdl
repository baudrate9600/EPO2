--Author: Olasoji Makinwa 
--date: 14/3/2020
--description: 
--FSM for controlling the motor
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity motorcontrol is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		direction	: in	std_logic;
		count_in	: in	std_logic_vector (19 downto 0);

		pwm		: out	std_logic
	);
end entity motorcontrol;

architecture behav of motorcontrol is

	type motor_states is ( START , LEFT , RIGHT);
	signal state : motor_states;

begin
	--One period = 20ms 
    --Counter = 1M	
	--Left puls = 1 ms (1M / 20) = 50000 counts 
	--Right puls = 2ms (1M / 10) = 100000 couunts 
	FSM : process( CLK, RESET )
	begin
	  --Reset state, motor shouldnt turn 
		if( reset = '1' ) then 
			state<= START; 
			pwm<='0'; 
		elsif(rising_edge(CLK)) then 
		--Decide if motor should turn left or ight 
			if state = START then 
				if( direction = '1') then
					state <= RIGHT; 
				else 
					state <= LEFT;
				end if; 
				pwm<='1';
		--wait till The specified amount of counts has been reached 
			elsif state = RIGHT then 
				if (to_integer(unsigned(count_in)) = 100000) then
				  pwm<='0'; 
				end if;
			elsif state = LEFT then 
				if (to_integer(unsigned(count_in)) = 50000) then
				  pwm<='0'; 
				end if; 
		--To leave state RIGHT OR LEFT, the controller has to be reset 
			end if;
		end if; 
	end process ; -- FSM
	

end behav ; -- behav