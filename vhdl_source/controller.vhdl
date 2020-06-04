library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
	port (	clk			: in	std_logic;
		reset			: in	std_logic;

		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;
		mine_detect		: in	std_logic;

		count_in		: in	std_logic_vector (19 downto 0);
		count_reset		: out	std_logic;

		motor_l_reset		: out	std_logic;
		motor_l_direction	: out	std_logic;

		motor_r_reset		: out	std_logic;
		motor_r_direction	: out	std_logic
	);
end entity controller;

architecture behaviour of controller is

	type controller_state is ( 	motor_uit ,
					motor_both,
					motor_gentleleft,
					motor_gentleright,
					motor_sharpleft,
					motor_sharpright,
					motor_white_mine,
					motor_right_mine,
					motor_reset_mine);
	signal state, new_state : controller_state;

begin
	process ( clk )
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				state <= motor_uit; 
			else
				state <= new_state;
			end if ;
		end if ;
	end process ;

	process (state, count_in, sensor_l, sensor_r, sensor_m, mine_detect)
	begin
		case state is
			when motor_uit =>
				count_reset <= '1';
				motor_l_reset <= '1';
				motor_r_reset <= '1';
				if (mine_detect = '1') then
					new_state <=	motor_reset_mine;
				else
					if (sensor_l = '0' and sensor_m = '0' and sensor_r = '0') then
						new_state <= 	motor_both; 
					elsif (sensor_l = '0' and sensor_m = '0' and sensor_r = '1') then
						new_state <= 	motor_gentleleft;
					elsif (sensor_l = '0' and sensor_m = '1' and sensor_r = '0') then
						new_state <= 	motor_both;
					elsif (sensor_l = '0' and sensor_m = '1' and sensor_r = '1') then
						new_state <= 	motor_sharpleft;
					elsif (sensor_l = '1' and sensor_m = '0' and sensor_r = '0') then
						new_state <= 	motor_gentleright;
					elsif (sensor_l = '1' and sensor_m = '0' and sensor_r = '1') then
						new_state <= 	motor_both; 	
					elsif (sensor_l = '1' and sensor_m = '1' and sensor_r = '0') then
						new_state <= 	motor_sharpright;
					elsif (sensor_l = '1' and sensor_m = '1' and sensor_r = '1') then
						new_state <= 	motor_both; 	
					else
						new_state <= 	motor_uit; 
					end if;
				end if;
			when motor_white_mine =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_r_reset <= '0';
				motor_l_direction <= '1';		
				motor_r_direction <= '1';
				if (unsigned(count_in) = 1000000 and sensor_l = '1' and sensor_m = '1' and sensor_r = '0') then
					new_state <= 	motor_uit; 
				elsif (unsigned(count_in) = 1000000) then
					new_state <=	motor_reset_mine;
				else
					new_state <= 	motor_white_mine;
				end if;
			when motor_right_mine =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_r_reset <= '0';
				motor_l_direction <= '1';		
				motor_r_direction <= '1';
				if (unsigned(count_in) = 1000000) then
					new_state <=	motor_reset_mine;
				else
					new_state <= 	motor_right_mine;
				end if;
			when motor_reset_mine =>
				count_reset <= '1';
				motor_l_reset <= '1';
				motor_r_reset <= '1';
				motor_l_direction <= '1';		
				motor_r_direction <= '1';
				if (sensor_l = '1' and sensor_m = '1' and sensor_r = '1') then
					new_state <=	motor_white_mine;
				else
					new_state <=	motor_right_mine;
				end if;
			when motor_both =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_r_reset <= '0';
				motor_l_direction <= '1';		
				motor_r_direction <= '0';	
				if (unsigned(count_in) = 1000000) then
					new_state <= motor_uit;
				else
					new_state <= motor_both;
				end if;
			when motor_gentleleft =>
				count_reset <= '0';
				motor_l_reset <= '1';
				motor_r_reset <= '0';
				motor_l_direction <= '0';		
				motor_r_direction <= '0';	
				if (unsigned(count_in) = 1000000) then
					new_state <= motor_uit;
				else
					new_state <= motor_gentleleft;
				end if;		
			when motor_sharpleft =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_r_reset <= '0';
				motor_l_direction <= '0';		
				motor_r_direction <= '0';	
				if (unsigned(count_in) = 1000000) then
					new_state <= motor_uit;
				else
					new_state <= motor_sharpleft;
				end if;
			when motor_gentleright =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_r_reset <= '1';
				motor_l_direction <= '1';		
				motor_r_direction <= '0';	
				if (unsigned(count_in) = 1000000) then
					new_state <= motor_uit;
				else
					new_state <= motor_gentleright;
				end if;	
			when motor_sharpright =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_r_reset <= '0';
				motor_l_direction <= '1';		
				motor_r_direction <= '1';	
				if (unsigned(count_in) = 1000000) then
					new_state <= motor_uit;
				else
					new_state <= motor_sharpright;
				end if;
		end case;
	end process;
end architecture behaviour;
