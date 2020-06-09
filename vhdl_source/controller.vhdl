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

count_in : in std_logic_vector (19 downto 0);
count_reset : out std_logic;

motor_l_reset : out std_logic;
motor_l_direction : out std_logic;

motor_r_reset : out std_logic;
motor_r_direction : out std_logic
);
end entity controller;

architecture controller_behav of controller is
type diff_states is (Startturn,Sensor_check,Wait_for_line,Startrigth,Goforward); -- add Startleft
signal state, next_state: diff_states;
signal sensor: std_logic_vector(2 downto 0); 
signal mine : std_logic; 			-- using for being in state mine_detect.
signal motorreset: std_logic;
signal reset_l_motor, reset_r_motor: std_logic;
--signal direction : std_logic;			-- direction=0 for left turn, direction=1 for rigth turn
signal rounds : integer range 0 to 5;
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
			if(sensor="111") then
				next_state <= Wait_for_line;
			else next_state<=Startturn;
			end if;
		when Wait_for_line =>
			--if(direction='1') then
				motor_l_direction <= '1';
				motor_r_direction <= '1';
				reset_l_motor <= '0';
				reset_r_motor <= '0';
				if(sensor="110") then
					next_state <= Sensor_check;
				else next_state <= Wait_for_line;
				end if;
			--else
				--motor_l_direction <= '0';
				--motor_r_direction <= '0';
				--reset_l_motor <= '0';
				--reset_r_motor <= '0';
				--if(sensor="011") then
				--	next_state <= Sensor_check;
				--else next_state <= Wait_for_line;
				--end if;
			--end if;
		when StartRigth =>
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			reset_l_motor <= '0';
			reset_r_motor <= '0';
			--direction<= '1';
			if(sensor="111") then
				next_state <= Wait_for_line;
			else next_state <= StartRigth;
			end if;
--		when StartLeft =>
--			motor_l_direction <= '0';
--			motor_r_direction <= '0';
--			reset_l_motor <= '0';
--			reset_r_motor <= '0';
--			direction<= '0';
--			if(sensor="111") then
--				next_state <= Wait_for_line;
--			else next_state <= StartLeft;
			
		when Goforward =>
			motor_l_direction <= '1';
			motor_r_direction <= '0';
			reset_l_motor <= '0';
			reset_r_motor <= '0';
			if(unsigned(count_in)=1000000) then
				if(rounds=5) then
					--if (data_out = X"114") then
						next_state <= StartRigth;
					--else if (data_out = X"102") then
					--	next_state <= Sensor_check;
					--else if (data_out = X"108") then 
					--	next_state <= StartLeft;
					--end if;
					rounds <= 0;
				else
					rounds <= rounds+1;
					next_state <= Goforward;
				end if;
			else
				next_state <= Goforward;
			end if;
		when Sensor_check=>
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
				--direction<= '1';
				next_state<=Startturn;
			--else if(rising_edge(read_data)) then
				--next_state<=Goforward;
			elsif(sensor="000") then
				next_state <= Goforward;
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
    elsif (clk'event and clk='1') then
state<=next_state;
        if (unsigned(count_in) =1000000) then
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
