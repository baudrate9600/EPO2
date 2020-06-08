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
type diff_states is (Startturn,Sensor_check,Wait_for_line,Check_point,Process_character,left,right,foward);
signal usart_state : usart_states;
signal state, next_state: diff_states;
signal sensor: std_logic_vector(2 downto 0); 
signal mine : std_logic; -- using for being in state mine_detect.
signal motorreset: std_logic;
signal reset_l_motor, reset_r_motor: std_logic;



begin

sensor(2)<=sensor_l;
sensor(1)<=sensor_m;
sensor(0)<=sensor_r;
ttl:process(sensor,state,mine_detect)
  begin
case state is
  when Startturn =>
    motor_l_direction <= '1';
    motor_r_direction <= '1';
    reset_l_motor <= '0';
    reset_r_motor <= '0';
    
    if(sensor="111") then
      next_state <= Wait_for_line;
    else 
      next_state<=Startturn;
    end if;
when Wait_for_line =>
    motor_l_direction <= '1';
    motor_r_direction <= '1';
    if(sensor="110") then
      next_state <= Sensor_check;
    else 
      next_state <= Wait_for_line;
    end if;
when Check_point =>
    if(new_data = '1') then
      next_state <= Process_character; 
    else 
      next_state <= Check_point; 
    end if; 
when Process_character => 
    if data_out = X"108" then 
      next_state = left;
    elsif data_out = X"114" then 
      next_state = right; 
    elsif data_out = X"102" then 
     next_state = foward; 
   end  if; 
when Sensor_check=>
    --All black ( checkpoint) 
    if (sensor="000") then
      motor_l_direction<= '1';
      motor_r_direction <= '0';
      reset_l_motor <= '0';
      reset_r_motor <= '0';
      next_state <= Check_point;
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



motor_l_reset <= reset_l_motor or motorreset ;
motor_r_reset <= reset_r_motor or motorreset ;



end controller_behav;
