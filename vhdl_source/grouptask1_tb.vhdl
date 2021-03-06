-- grouptask 1 testbench for EPO-2 student version


library IEEE;
use IEEE.std_logic_1164.all;


entity grouptask1_tb is
end entity;


architecture sim of grouptask1_tb is

    component top is
        port (  clk             : in    std_logic;
                reset           : in    std_logic;

                sensor_l_in     : in    std_logic;
                sensor_m_in     : in    std_logic;
                sensor_r_in     : in    std_logic;

                mine_sensor : in    std_logic;

                motor_l_pwm     : out   std_logic;
                motor_r_pwm     : out   std_logic;

                tx          : out       std_logic
        );
    end component;

    constant CLOCK_PERIOD    : time := 20 ns; -- 50 MHz clock
    constant PWM_PERIOD      : time := 20 ms; -- 50 Hz
    constant NO_MINE_PERIOD  : time := 100 us; -- 10 kHz
    constant MINE_PERIOD     : time := 115 us; -- 8.7 kHz

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    signal sensors : std_logic_vector(2 downto 0);
    signal sensor_l, sensor_m, sensor_r : std_logic;
    signal mine_sensor : std_logic;
    signal tx : std_logic;
    signal motor_l_pwm, motor_r_pwm : std_logic;

    signal mine_sim : std_logic;

begin

    robot_inst: top port map (
        clk         => clk,
        reset       => reset,

        sensor_l_in => sensors(2),
        sensor_m_in => sensors(1),
        sensor_r_in => sensors(0),

        mine_sensor => mine_sensor,

        motor_l_pwm => motor_l_pwm,
        motor_r_pwm => motor_r_pwm,

        tx          => tx
    );

    sensor_l <= sensors(2);
    sensor_m <= sensors(1);
    sensor_r <= sensors(0);

    clk <= not clk after 0.5*CLOCK_PERIOD; -- generate clock
    reset <= '0' after 2*CLOCK_PERIOD;     -- hold reset for 2 clock cycles

    -- Simulate mine sensor with changing frequency
   process
   begin
       if mine_sim = '1' then
           mine_sensor <= '0';
           wait for 0.5*MINE_PERIOD;
           mine_sensor <= '1';
           wait for 0.5*MINE_PERIOD;
       else
           mine_sensor <= '0';
           wait for 0.5*NO_MINE_PERIOD;
           mine_sensor <= '1';
           wait for 0.5*NO_MINE_PERIOD;
       end if;
   end process;


   -- Main simulation process
    process
    begin
        sensors <= "101"; -- forward
        mine_sim <= '0';
        wait for 1.5*PWM_PERIOD;

        sensors <= "001"; -- turn left
        wait for PWM_PERIOD;

        sensors <= "011"; -- sharp left
        wait for PWM_PERIOD;

        sensors <= "100"; -- turn right
        wait for PWM_PERIOD;

        sensors <= "110"; -- sharp right
        wait for PWM_PERIOD;

        sensors <= "101"; -- forward again
        wait for PWM_PERIOD; -- 6.5 periods

        for I in 1 to 2 loop -- detect two mines

            sensors <= "101"; -- detect mine, start turnaround
            mine_sim <= '1';
            wait for PWM_PERIOD;

            sensors <= "100"; -- should be ignored
            mine_sim <= '0';
            wait for PWM_PERIOD;

            sensors <= "011"; -- should be ignored
            wait for PWM_PERIOD;

            sensors <= "111"; -- detect all white, continue turnaround
            wait for PWM_PERIOD;
            wait for PWM_PERIOD;

            sensors <= "110"; -- detect line again, return to line-following mode
            wait for PWM_PERIOD; -- 12.5 periods

            sensors <= "101"; -- forward, 'm' should be received by now
            wait for PWM_PERIOD;

            sensors <= "001"; -- turn left
            wait for PWM_PERIOD;

            sensors <= "100"; -- turn right
            wait for PWM_PERIOD; -- 15.5 periods

        end loop; -- 24.5 periods after 2 iterations

        wait;
    end process;

end architecture;
