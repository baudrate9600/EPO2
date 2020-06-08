library IEEE;
use IEEE.std_logic_1164.all;

entity robot is
	port (  clk             : in    std_logic;
		reset           : in    std_logic;

		sensor_l_in     : in    std_logic;
		sensor_m_in     : in    std_logic;
		sensor_r_in     : in    std_logic;

		mine_sensor	: in	std_logic;

		write_data	: out std_logic; 
		read_data	: out std_logic;  
		new_data	: in std_logic;
		data_out	: in std_logic_vector(7 downto 0);
		data_in		: out std_logic_vector(7 downto 0);

		motor_l_pwm     : out   std_logic;
		motor_r_pwm     : out   std_logic
	);
end entity robot;

architecture structural of robot is
	component controller is
		port (	clk			: in	std_logic;
			reset			: in	std_logic;

			sensor_l		: in	std_logic;
			sensor_m		: in	std_logic;
			sensor_r		: in	std_logic;
			mine_detect		: in	std_logic;

			write_data		: out std_logic; 
			read_data		: out std_logic;  
			new_data		: in std_logic;
			data_received		: in std_logic_vector(7 downto 0);
			data_send			: out std_logic_vector(7 downto 0);

			count_in		: in	std_logic_vector (19 downto 0);
			count_reset		: out	std_logic;

			motor_l_reset		: out	std_logic;
			motor_l_direction	: out	std_logic;

			motor_r_reset		: out	std_logic;
			motor_r_direction	: out	std_logic
		      );
	end component;
	component mine_freq is
		port (	clk		: in	std_logic;
			reset		: in	std_logic;
			mine_sensor	: in	std_logic;
			
			mine_detect	: out	std_logic
		     );
	end component;
	component inputbuffer is
		port (	clk		: in	std_logic;

			sensor_l_in	: in	std_logic;
			sensor_m_in	: in	std_logic;
			sensor_r_in	: in	std_logic;
			mine_sensor_in	: in	std_logic;

			sensor_l_out	: out	std_logic;
			sensor_m_out	: out	std_logic;
			sensor_r_out	: out	std_logic;
			mine_sensor_out	: out	std_logic
		     );
	end component;
	component motorcontrol is
		port (	clk		: in	std_logic;
			reset		: in	std_logic;
			direction	: in	std_logic;
			count_in		: in	std_logic_vector (19 downto 0);

			pwm		: out	std_logic
		     );
	end component;
	component timebase is
 		port (	clk		: in	std_logic;
			reset		: in	std_logic;

			count_out	: out	std_logic_vector (19 downto 0)
		     );
	end component;
	signal count_signal: std_logic_vector (19 downto 0);
	signal 	sensor_l_buf, 
		sensor_m_buf, 
		sensor_r_buf, 
		count_resets, 
		motor_l_resets, 
		motor_r_resets, 
		motor_l_directions, 
		motor_r_directions, 
		mine_sensor_buf, 
		mine_detect_buf: std_logic;
begin
L1: timebase port map (	clk=>clk, 
			reset=>count_resets, 
			count_out=>count_signal
		      );
L2: inputbuffer port map (	clk=>clk, 
				sensor_l_in=>sensor_l_in, 
				sensor_m_in=>sensor_m_in, 
				sensor_r_in=>sensor_r_in, 
				mine_sensor_in =>mine_sensor,
				sensor_l_out=>sensor_l_buf, 
				sensor_m_out=>sensor_m_buf, 
				sensor_r_out=>sensor_r_buf,
				mine_sensor_out =>mine_sensor_buf
			 );
L3: mine_freq port map (	clk=>clk,
				reset=>reset,
				mine_sensor=>mine_sensor_buf,
				mine_detect=>mine_detect_buf
			);
L4: controller port map (	clk=>clk,
				reset=>reset,
				sensor_l=>sensor_l_buf,
				sensor_m=>sensor_m_buf,
				sensor_r=>sensor_r_buf,
				mine_detect =>mine_detect_buf,
				count_in=>count_signal,
				count_reset=>count_resets,
				motor_l_reset=>motor_l_resets,
				motor_r_reset=>motor_r_resets,
				motor_l_direction=>motor_l_directions,
				motor_r_direction=>motor_r_directions,
				data_received=>data_out,
				data_send=>data_in,
				write_data=>write_data,
				read_data=>read_data,
				new_data=>new_data			
			 );
L5: motorcontrol port map (	clk=>clk,
				reset=>motor_l_resets,
				direction=>motor_l_directions,
				count_in=>count_signal,
				pwm=>motor_l_pwm
			     );
L6: motorcontrol port map (	clk=>clk,
				reset=>motor_r_resets,
				direction=>motor_r_directions,
				count_in=>count_signal,
				pwm=>motor_r_pwm
			     );				

end structural;
