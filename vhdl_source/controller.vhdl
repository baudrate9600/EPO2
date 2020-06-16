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
		data_received
: in std_logic_vector(7 downto 0);
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
type diff_states is (Startturn,Sensor_check,Check_point,sleft,sright,foward,wait_for_black, mine_send, Mine_check_point,backwards, t_send, sendg_reset); -- , mine_revert, t_revert
signal state, next_state: diff_states;
signal sensor: std_logic_vector(2 downto 0); 
signal mine : std_logic; -- using for being in state mine_detect.
signal motorreset: std_logic;
signal internal_count_reset : std_logic;
signal new_pulse_counter : integer range 0 to 7;
signal pulse_counter : integer range 0 to 7;
signal reset_l_motor, reset_r_motor: std_logic;
signal start_uart_transfer : std_logic; 
signal usart_state : std_logic;
signal skipcrossing : std_logic;
signal sendg : std_logic;
signal mine_reset : std_logic;
signal turn : std_logic; -- 1 for 180 turn, 0 for backwards
signal skip_reset : std_logic;

begin

sensor(2)<=sensor_l;
sensor(1)<=sensor_m;
sensor(0)<=sensor_r;
ttl:process(sensor,state,mine_detect, internal_count_reset,new_pulse_counter,count_in)
  begin
case state is
  when Startturn =>
    skipcrossing <= '1';
    motor_l_direction <= '1';
    motor_r_direction <= '1';
    reset_l_motor <= '0';
    reset_r_motor <= '0';
    mine_reset <= '0';
    turn <= '1';
--    read_data <= '0';
    
    if(sensor="111") then
      next_state <= wait_for_black;
    else 
      next_state<=Startturn;
    end if;


--When the checkpoint has been reached wait until new_data arrives from the uart and then go foward 
when Check_point => 

    if(new_data = '1') then
    	next_state <= foward;
	pulse_counter <= 0; 
    else 
        next_state <= Check_point; 
    end if; 

--Go foward for 5 pulses then process the character that was sent from the uart 
when foward => 
      motor_l_direction <= '1';
      motor_r_direction <= '0';
      reset_l_motor <= '0';
      reset_r_motor <= '0';
      turn <= '0';
      --Process the revieced character. 
      if (internal_count_reset = '1') then 
          pulse_counter <= new_pulse_counter;
        if(pulse_counter = 6) then 
--	  read_data <= '0';
          pulse_counter <= 0;
          if (data_received = X"6C") then    --'l'
            next_state <= sleft;
          elsif (data_received = X"72") then --'r' 
            next_state <= sright; 
          elsif (data_received = X"66") then --'f'
            next_state <= Sensor_check; 
	    sendg <= '1';
          end  if; 
        end if;
      end if;

when sleft => 
--      read_data <= '1';
      motor_l_direction <= '0';
      motor_r_direction <= '0';
      reset_l_motor <= '0';
      reset_r_motor <= '0';
      turn <= '0';
      if(sensor = "111") then 
        next_state <= wait_for_black;
      else
	next_state <= sleft;
      end if; 

when sright => 
--      read_data <= '1';
      motor_l_direction <= '1'; 
      motor_r_direction <= '1'; 
      reset_l_motor <= '0'; 
      reset_r_motor <= '0'; 
      turn <= '0';
      if(sensor = "111") then 
        next_state <= wait_for_black; 
      else
	next_state <= sright;
      end if;

--when Mine_revert =>
--      motor_l_direction <= '0';
--      motor_r_direction <= '0';
--      reset_l_motor <= '1';
--      reset_r_motor <= '1';
--      if (unsigned(count_in) = 0) then
--		next_state <= Mine_send;
--      else
--		next_state <= Mine_revert;
--      end if;
				
when Mine_send =>
--      read_data <= '0';
	motor_l_direction <= '0';
      	motor_r_direction <= '0';
      	reset_l_motor <= '1';
      	reset_r_motor <= '1';
	if (unsigned(count_in) = 0) then
      		start_uart_transfer <= '1';
      		data_send <= X"6D";
		next_state <= Mine_check_point;
	else
		next_state <= Mine_send;
	end if;

--when t_revert =>
--      motor_l_direction <= '0';
--      motor_r_direction <= '0';
--      reset_l_motor <= '1';
--      reset_r_motor <= '1';
--      if (unsigned(count_in) = 0) then
--		next_state <= t_send;
--      else
--		next_state <= t_revert;
--      end if;

when t_send =>
      motor_l_direction <= '0';
      motor_r_direction <= '0';
      reset_l_motor <= '1';
      reset_r_motor <= '1';
--      read_data <= '0';
      start_uart_transfer <= '1';
      data_send <= X"74";
      next_state <= Mine_check_point;

when Mine_check_point =>
	start_uart_transfer <= '0';
	if (data_received'event) then
      		if (data_received = X"6F") then    --'o' or 't' for challenge b
	   		mine_reset <= '1';
            		next_state <= Startturn;
     		elsif ((data_received = X"70") or (data_received= X"71")) then --'p' or 'q'
	   		mine_reset <= '1';
            		next_state <= backwards; 
      		else
            		next_state <= Mine_check_point;
      		end  if; 
	else
		next_state <= Mine_check_point;
      	end  if; 

--Go backwards for 5 pulses then process the character that was sent from the uart 
when backwards => 
--      read_data <= '1';
      mine_reset <= '0';
      motor_l_direction <= '0';
      motor_r_direction <= '1';
      reset_l_motor <= '0';
      reset_r_motor <= '0';
      --Process the revieced character. 
      if (internal_count_reset = '1') then 
          pulse_counter <= new_pulse_counter;
        if(pulse_counter = 6) then 
          pulse_counter <= 0;
--	  read_data <= '0';
          if (data_received = X"70") then    --'p'
            next_state <= sright;
          elsif (data_received = X"71") then --'q' 
            next_state <= sleft; 
	  else
	    next_state <= backwards;
          end  if; 
	else
	    next_state <= backwards;
        end if;
      else
      	next_state <= backwards;
      end if;

when wait_for_black =>
--      read_data <= '1';
      if (sensor_l = '0' or sensor_r = '0' or sensor_m = '0') then
	sendg <= '1';
        next_state <= Sensor_check;
      else
	next_state <= wait_for_black; 
      end if;

when sendg_reset =>
	sendg <= '0';
        next_state <= Sensor_check;

when Sensor_check=>
    start_uart_transfer <= '0';
    --All black ( checkpoint) 
    if (sensor="000") then
      	motor_l_direction<= '1';
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
        reset_l_motor <= '1';
        reset_r_motor <= '1';
    end if;

if(mine_detect='1') then
      next_state<= Mine_send;
elsif (turn = '0' and sendg = '1' and ((sensor_l = '0') or (sensor_r = '0') or (sensor_m='0')) and (unsigned(count_in) = 0)) then
	start_uart_transfer <= '1';
      	data_send <= X"67";
	next_state <= sendg_reset;
elsif (turn = '1' and sendg = '1' and sensor= "101" and (unsigned(count_in) = 0)) then
	start_uart_transfer <= '1';
      	data_send <= X"67";
	next_state <= sendg_reset;
elsif(sensor="111") then
      next_state<= t_send;
else
    if(skipcrossing ='1') then
	next_state <= Sensor_check;
	if (sensor = "000") then
	    skip_reset <= '1';
	end if;
	if(skip_reset = '1') then    
		if((sensor_l = '1') or (sensor_r = '1') or (sensor_m='1')) then
			skipcrossing <='0';
	    		skip_reset <= '0';
		end if;
	end if;
    else
    	if (sensor="000") then
		next_state<= Check_point;
    	else 
		next_state<= Sensor_check;
	end if;
end if;
end if;
     end case;  
end process;

clk_sig: process(clk,reset)
begin
if (reset='1') then
    count_reset <= '1';
    motorreset <= '1';
    state<=Sensor_check;
--    skipcrossing <= '0';
--    start_uart_transfer <= '0';
    elsif (clk'event and clk='1') then
        state<=next_state;
        if (unsigned(count_in) = 1000000 or mine_reset = '1') then
      count_reset <= '1';
      internal_count_reset <= '1'; 
      motorreset <= '1';
      new_pulse_counter <= pulse_counter + 1;
    else
      internal_count_reset <= '0';
      count_reset <= '0';
      motorreset <= '0';
    end if;
end if;
end process;

--When start_uart_transfer is 1 it sends 1 byte 
--start_uart_transfer has to become 0 first before it can send again 
send_usart: process(clk)
begin
  if reset = '1' then 
      usart_state <= '0'; 
  elsif rising_edge(clk) then 
    case usart_state is
      when '0' => 
        if start_uart_transfer = '1' then 
	    read_data <= '0';
            write_data <= '1'; 
            usart_state <= '1';
        end if; 
      when '1' =>
	  read_data <= '1';
          write_data <= '0';
        if start_uart_transfer = '0' then 
          usart_state <= '0'; 
        end if;

      when others =>
        
    
    end case;

  end if;
  
end process send_usart;

motor_l_reset <= reset_l_motor or motorreset ;
motor_r_reset <= reset_r_motor or motorreset ;

end controller_behav;

