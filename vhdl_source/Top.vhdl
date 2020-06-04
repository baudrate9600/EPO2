library IEEE;
use IEEE.std_logic_1164.all;

entity top is
	port (  clk             : in    std_logic;
		reset           : in    std_logic;

		sensor_l_in     : in    std_logic;
		sensor_m_in     : in    std_logic;
		sensor_r_in     : in    std_logic;

		mine_sensor	: in	std_logic;
		
		rx		: in std_logic;
		tx		: out std_logic;

		motor_l_pwm     : out   std_logic;
		motor_r_pwm     : out   std_logic
	);
end entity top;

architecture structural of top is
	component uart is
		port (
			clk, reset	: in std_logic;
			rx		: in std_logic; -- input bit stream
			tx		: out std_logic; -- output bit stream
			data_in		: in std_logic_vector(7 downto 0); -- byte to be sent
			data_out	: out std_logic_vector(7 downto 0); -- received byte
			write_data	: in std_logic; -- write to transmitter buffer 
			read_data	: in std_logic; -- read from receiver buffer 
			new_data	: out std_logic -- new data available
		);
	end component uart;

	component robot is
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
	end component robot;
	signal data_in_sig, data_out_sig : std_logic_vector(7 downto 0);
	signal write_data_sig, read_data_sig, new_data_sig : std_logic;
begin

L1: uart port map(	clk=>clk,
			reset=>reset,
			rx=>rx,
			tx=>tx,
			data_in=>data_in_sig,
			data_out=>data_out_sig,
			write_data=>write_data_sig,
			read_data=>read_data_sig,
			new_data=>new_data_sig
		);
L2: robot port map(	clk=>clk,
			reset=>reset,
			sensor_l_in=>sensor_l_in, 
			sensor_m_in=>sensor_m_in, 
			sensor_r_in=>sensor_r_in, 
			mine_sensor =>mine_sensor,
			motor_r_pwm=>motor_r_pwm,
			motor_l_pwm=>motor_l_pwm,
			data_in=>data_in_sig,
			data_out=>data_out_sig,
			write_data=>write_data_sig,
			read_data=>read_data_sig,
			new_data=>new_data_sig
		);

end structural;


