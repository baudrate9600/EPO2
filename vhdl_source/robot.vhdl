library IEEE;
use IEEE.std_logic_1164.all;

entity robot is
	port (  clk             : in    std_logic;
		reset           : in    std_logic;

		sensor_l_in     : in    std_logic;
		sensor_m_in     : in    std_logic;
		sensor_r_in     : in    std_logic;

        mine_detect     : in std_logic;

		motor_l_pwm     : out   std_logic;
		motor_r_pwm     : out   std_logic
	);
end entity robot;

architecture behav of robot is
    signal i_count_out : std_logic_vector(19 downto 0);
    signal i_count_reset :std_logic; 
    signal i_buffered_L,i_buffered_M,i_buffered_R : std_logic;
    signal i_motor_l_reset,   i_motor_l_direction , i_motor_r_reset,i_motor_r_direction : std_logic;
    
    --COMPONENTS 
    component motorcontrol is
	   port (	clk		: in	std_logic;
		  reset		: in	std_logic;
		  direction	: in	std_logic;
		  count_in	: in	std_logic_vector (19 downto 0);

		  pwm		: out	std_logic
	    );
    end component ;
    
    component controller is
	   port (	clk			: in	std_logic;
		  reset			: in	std_logic;

		  sensor_l		: in	std_logic;
		  sensor_m		: in	std_logic;
		  sensor_r		: in	std_logic;

		  count_in		: in	std_logic_vector (19 downto 0);
		  count_reset		: out	std_logic;
          mine_detect   : in std_logic;
		  motor_l_reset		: out	std_logic;
		  motor_l_direction	: out	std_logic;

		  motor_r_reset		: out	std_logic;
		  motor_r_direction	: out	std_logic
		
	   );
    end component;
    
    component input_buffer is
      port (
      CLK         : in std_logic;
      sensor_L_in : in std_logic;
      sensor_M_in : in std_logic;
      sensor_R_in : in std_logic; 
      sensor_L_out : out std_logic; 
      sensor_M_out : out std_logic;
      sensor_R_out : out std_logic
      ) ;
    end component;
    
    component timebase is
        port (
          clk : in std_logic; 
          reset : in std_logic;
          count_out : out std_logic_vector ( 19 downto 0)
        ) ;
      end component;
    

begin
    motor_left : motorcontrol port map(
        clk => clk,
        reset => i_motor_l_reset,
        direction => i_motor_l_direction,
        count_in => i_count_out,
        pwm => motor_l_pwm
    );
    motor_right : motorcontrol port map( 
        clk => clk, 
        reset => i_motor_r_reset,
        direction => i_motor_r_direction,
        count_in => i_count_out,
        pwm => motor_r_pwm

    );
    control : controller port map( 
        clk => clk, 
        reset => reset,
        sensor_l => i_buffered_L ,
        sensor_M => i_buffered_M, 
        sensor_R => i_buffered_R,
        count_in => i_count_out,
        count_reset => i_count_reset,
        mine_detect => mine_detect,
        motor_l_reset  =>i_motor_l_reset,
        motor_l_direction => i_motor_l_direction,
        motor_r_reset	=> i_motor_r_reset,
        motor_r_direction  => i_motor_r_direction
    );
    inputbuffers : input_buffer port map( 
        clk => clk, 
        sensor_l_in => sensor_l_in,
        sensor_m_in=> sensor_m_in,
        sensor_r_in => sensor_r_in,
        sensor_L_out => i_buffered_L ,
        sensor_M_out => i_buffered_M, 
        sensor_R_out => i_buffered_R
    );
    time_base : timebase port map( 
        clk => clk,
        reset => i_count_reset,
        count_out => i_count_out
    );

end behav ; -- behav