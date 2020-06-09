library IEEE;
-- Hier komen de gebruikte libraries:
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity controller is

	port ( clk : in std_logic;
		reset : in std_logic;

		sensor_l : in std_logic;
		sensor_m : in std_logic;
		sensor_r : in std_logic;

		mine_detect: in std_logic;

		write_data: out std_logic; 
		read_data: out std_logic;  
		new_data: in std_logic;
		data_received: in std_logic_vector(7 downto 0);
		data_send: out std_logic_vector(7 downto 0);

		count_in : in std_logic_vector (19 downto 0);
		count_reset : out std_logic;

		motor_l_reset : out std_logic;
		motor_l_direction : out std_logic;

		motor_r_reset : out std_logic;
		motor_r_direction : out std_logic
		);
end entity controller;

architecture controller_behav of controller is
	type diff_states is (Startturn,Sensor_check,Wait_for_line,Mine_revert,Mine_send);
	signal state, next_state: diff_states;
	signal sensor: std_logic_vector(2 downto 0); 
	signal mine : std_logic; -- using for being in state mine_detect.
	signal motorreset: std_logic;
	signal reset_l_motor, reset_r_motor: std_logic;
begin
	sensor(2)<=sensor_l;
	sensor(1)<=sensor_m;
	sensor(0)<=sensor_r;

	ttl:process(sensor,state,mine_detect, count_in)
  	begin
			case state is
				when Startturn =>
					motor_l_direction <= '1';
					motor_r_direction <= '1';
					reset_l_motor <= '0';
					reset_r_motor <= '0';
					read_data <= '1';
					write_data <= '0';
					data_send <= "11111111";
					if(sensor="111") then
						next_state <= Wait_for_line;
					else 
						next_state <= Startturn;
					end if;
				when Wait_for_line =>
					motor_l_direction <= '1';
					motor_r_direction <= '1';
					reset_l_motor <= '0';
					reset_r_motor <= '0';
					read_data <= '1';
					write_data <= '0';
					data_send <= "11111111";
					if(sensor="110") then
						next_state <= Mine_revert;
					else 
						next_state <= Wait_for_line;
					end if;
				when Mine_revert =>
					motor_l_direction <= '1';
					motor_r_direction <= '1';
					reset_l_motor <= '0';
					reset_r_motor <= '0';
					if (unsigned(count_in) = 0) then
						next_state <= Mine_send;
					else
						next_state <= Mine_revert;
    					end if;
				when Mine_send =>
					motor_l_direction <= '1';
					motor_r_direction <= '1';
					reset_l_motor <= '0';
					reset_r_motor <= '0';
      					read_data <= '0';
					write_data <= '1';
					data_send <= "01101101";
					next_state <= Sensor_check;
				when Sensor_check=>
					read_data <= '1';
					write_data <= '0';
					data_send <= "11111111";
					if (sensor="000") then
						motor_l_direction <= '1';
        					motor_r_direction <= '0';
						reset_l_motor <= '0';
						reset_r_motor <= '0';

					elsif(sensor= "001") then
        					motor_l_direction <= '0';
       						motor_r_direction <= '0';
						reset_l_motor <= '1';
						reset_r_motor <= '0';

					elsif(sensor= "010") then
						motor_l_direction <= '1';
        					motor_r_direction <= '0';
						reset_l_motor <= '0';
						reset_r_motor <= '0';

					elsif(sensor= "011") then
        					motor_l_direction <= '0';
        					motor_r_direction <= '0';
						reset_l_motor <= '0';
						reset_r_motor <= '0';

					elsif(sensor= "100") then
						motor_l_direction <= '1';
        					motor_r_direction <= '0';
						reset_r_motor <= '1';
						reset_l_motor <= '0';

					elsif(sensor= "101") then
						motor_l_direction <= '1';
        					motor_r_direction <= '0';
						reset_l_motor <= '0';
						reset_r_motor <= '0';

					elsif(sensor= "110") then
						motor_l_direction <= '1';
    						motor_r_direction <= '1';
						reset_l_motor <= '0';
						reset_r_motor <= '0';

					elsif(sensor= "111") then
						motor_l_direction <= '1';
   						motor_r_direction <= '0';
						reset_l_motor <= '0';
						reset_r_motor <= '0';

					else
						motor_l_direction <= '0';
        					motor_r_direction <= '0';
						reset_l_motor <= '0';
						reset_r_motor <= '0';
        				end if;
					if(mine_detect='1') then
						next_state<=Startturn;
					else
						next_state<=Sensor_check;
					end if;
     			end case;       
	end process;

	clk_sig: process(clk,reset)
	begin
		if (reset='1') then
    			count_reset <= '1';
    			motorreset <= '1';
    			state<=Sensor_check;
    		elsif (clk'event and clk = '1') then
			state<=next_state;
        		if (unsigned(count_in) = 1000000) then
      				count_reset <= '1';
      				motorreset <= '1';
    			else
      				count_reset <= '0';
      				motorreset <= '0';
    			end if;
		end if;
	end process;

	motor_l_reset <= reset_l_motor or motorreset;
	motor_r_reset <= reset_r_motor or motorreset;


end controller_behav;
