-- grouptask 3 testbench for EPO-2 student version


library IEEE;
use IEEE.std_logic_1164.all;


entity grouptask3_tb is
end entity;


architecture sim of grouptask3_tb is

    component robot is
        port (  clk             : in    std_logic;
                reset           : in    std_logic;

                sensor_l_in     : in    std_logic;
                sensor_m_in     : in    std_logic;
                sensor_r_in     : in    std_logic;

                mine_sensor     : in    std_logic;

                rx              : in    std_logic;

                motor_l_pwm     : out   std_logic;
                motor_r_pwm     : out   std_logic
        );
    end component;

    constant CLOCK_PERIOD    : time := 20 ns; -- 50 MHz clock
    constant BAUD_PERIOD     : time := 104167 ns; -- 9600 baud rate
    constant PWM_PERIOD      : time := 20 ms;
    constant NO_MINE_PERIOD  : time := 100 us; -- 10 kHz

    -- Clock/reset
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    -- Robot IO
    signal sensors : std_logic_vector(2 downto 0);
    signal sensor_l, sensor_m, sensor_r : std_logic;
    signal mine_sensor : std_logic;
    signal rx : std_logic;
    signal motor_l_pwm, motor_r_pwm : std_logic;

    -- Host TX
    signal tx_send : std_logic := '0';
    signal tx_byte : std_logic_vector(7 downto 0);

begin

    robot_inst: robot port map (
        clk         => clk,
        reset       => reset,

        sensor_l_in => sensors(2),
        sensor_m_in => sensors(1),
        sensor_r_in => sensors(0),

        mine_sensor => mine_sensor,

        rx          => rx,

        motor_l_pwm => motor_l_pwm,
        motor_r_pwm => motor_r_pwm
    );

    sensor_l <= sensors(2);
    sensor_m <= sensors(1);
    sensor_r <= sensors(0);

    clk <= not clk after 0.5*CLOCK_PERIOD; -- generate clock
    reset <= '0' after 2*CLOCK_PERIOD;     -- hold reset for 2 clock cycles

    -- Simulate mine sensor
    process
    begin
        mine_sensor <= '0';
        wait for 0.5*NO_MINE_PERIOD;
        mine_sensor <= '1';
        wait for 0.5*NO_MINE_PERIOD;
    end process;

    -- Simulated host TX
    process
    begin
        rx <= '1';
        wait on tx_send;

        -- Start
        rx <= '0';
        wait for BAUD_PERIOD;

        -- Data
        for I in 0 to 7 loop
            rx <= tx_byte(I);
            wait for BAUD_PERIOD;
        end loop;

        -- Stop
        rx <= '1';
        wait for BAUD_PERIOD;
    end process;


    -- Host sim
    -- Host TX values
    --   66 'f' forward on next crossing
    --   6C 'l' left on next crossing
    --   72 'r' right on next crossing
    process
    begin
        -- Init
        tx_byte <= X"00";
        sensors <= "101";
        wait for 100 us;

        -- Start going forward, offset by half a period
        tx_byte <= X"66";
        tx_send <= not tx_send;
        sensors <= "101";
        wait for 1.5*PWM_PERIOD;


        -- Follow line
        sensors <= "001"; -- turn left
        wait for PWM_PERIOD;

        sensors <= "100"; -- turn right
        wait for PWM_PERIOD;

        -- Detect crossing, continue going forward for 5 cycles
        sensors <= "000";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        sensors <= "011"; -- should be ignored
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        -- Continue following line
        sensors <= "100"; -- turn right
        wait for PWM_PERIOD; -- 9.5 periods

        -- Turn left on next crossing
        tx_byte <= X"6C";
        tx_send <= not tx_send;
        sensors <= "101";
        wait for PWM_PERIOD;

        -- Detect crossing, continue going forward for 5 cycles
        sensors <= "000";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        sensors <= "110"; -- should be ignored
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;
        wait for PWM_PERIOD; -- 15.5 periods

        -- Turn should start here, sensors should be ignored
        sensors <= "100";
        wait for PWM_PERIOD;

        sensors <= "110"; -- should be ignored
        wait for PWM_PERIOD;

        sensors <= "111"; -- detect all white, continue turnaround
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        -- Detect line again, return to line-following mode
        sensors <= "011";
        wait for PWM_PERIOD;

        sensors <= "001"; -- turn left
        wait for PWM_PERIOD; -- 21.5 periods

        -- Turn right on next crossing
        tx_byte <= X"72";
        tx_send <= not tx_send;
        sensors <= "101";
        wait for PWM_PERIOD;

        -- Detect crossing, continue going forward for 5 cycles
        sensors <= "000";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        sensors <= "001"; -- should be ignored
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;
        wait for PWM_PERIOD; -- 27.5 periods

        -- Turn should start here, sensors should be ignored
        sensors <= "001";
        wait for PWM_PERIOD;

        sensors <= "011"; -- should be ignored
        wait for PWM_PERIOD;

        sensors <= "111"; -- detect all white, continue turnaround
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        -- Detect line again, return to line-following mode
        sensors <= "110";
        wait for PWM_PERIOD;

        sensors <= "101";
        wait for PWM_PERIOD; -- 33.5 periods

        wait;
    end process;

end architecture;
