-- grouptask 5 testbench for EPO-2 student version


library IEEE;
use IEEE.std_logic_1164.all;


entity grouptask5_tb is
end entity;


architecture sim of grouptask5_tb is

    constant CLOCK_PERIOD    : time := 20 ns; -- 50 MHz clock
    constant BAUD_PERIOD     : time := 104167 ns; -- 9600 baud rate
    constant PWM_PERIOD      : time := 20 ms; -- 50 Hz
    constant NO_MINE_PERIOD  : time := 100 us; -- 10 kHz
    constant MINE_PERIOD     : time := 115 us; -- 8.7 kHz


    component Top is
    	port (
    		clk			: in  std_logic;
    		reset			: in  std_logic;

    		sensor_l_in		: in  std_logic;
    		sensor_m_in		: in  std_logic;
    		sensor_r_in		: in  std_logic;

    		mine_sensor		: in  std_logic;

    		rx			: in  std_logic;
    		tx			: out std_logic;

    		motor_l_pwm		: out std_logic;
    		motor_r_pwm		: out std_logic
    	);
    end component Top;


    -- Clock/reset
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    -- Robot IO
    signal sensors : std_logic_vector(2 downto 0);
    signal sensor_l_in, sensor_m_in, sensor_r_in : std_logic;
    signal mine_sensor : std_logic := '0';
    signal rx, tx : std_logic;
    signal motor_l_pwm, motor_r_pwm : std_logic;

    -- Host UART
    signal tx_send : std_logic := '0';
    signal tx_byte : std_logic_vector(7 downto 0);
    signal rx_byte : std_logic_vector(7 downto 0);

    -- Toggle mine frequency
    signal mine_sim : std_logic;

begin

    -- Robot instance
    robot_inst: Top port map (
        clk         => clk,
        reset       => reset,

        sensor_l_in    => sensors(2),
        sensor_m_in    => sensors(1),
        sensor_r_in    => sensors(0),

        mine_sensor => mine_sensor,

        rx          => rx,
        tx          => tx,

        motor_l_pwm => motor_l_pwm,
        motor_r_pwm => motor_r_pwm
    );

    sensor_l_in    <= sensors(2);
    sensor_m_in    <= sensors(1);
    sensor_r_in    <= sensors(0);

    clk <= not clk after 0.5*CLOCK_PERIOD; -- generate clock
    reset <= '0' after 2*CLOCK_PERIOD;     -- hold reset for 2 clock cycles


    -- Simulated host RX
    process
    begin
        wait until tx = '0';
        rx_byte <= (others => 'U'); -- reset output

        wait for BAUD_PERIOD/2;
        if tx = '0' then -- Start bit detected
            for I in 0 to 7 loop
                wait for BAUD_PERIOD;
                rx_byte(I) <= tx;
            end loop;
        end if;
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


    -- Host sim
    -- Host TX values
    --   6F 'o' 180 turnaround, ignore first crossing
    --   70 'p' backwards + clockwise turn
    --   71 'q' backwards + counterclockwise turn
    -- Host RX values
    --   67 'g' passed crossing
    --   6D 'm' mine detected
    --   74 't' station reached
    process
    begin
        -- Init
        tx_byte <= X"00";
        sensors <= "101";
        mine_sim <= '0';
        wait for 100 us;

        -- Start going forward, offset by half a period
        wait for 1.5*PWM_PERIOD;

        -- Follow line
        sensors <= "001"; -- turn left
        wait for PWM_PERIOD;

        sensors <= "100"; -- turn right
        wait for PWM_PERIOD;

        -- Detect mine, wait for response
        sensors <= "101";
        mine_sim <= '1';
        wait until rx_byte = X"6D"; -- 4 periods

        -- Send 'o', start turnaround
        sensors <= "001";
        tx_byte <= X"6F";
        tx_send <= not tx_send;
        mine_sim <= '0';
        wait for 1.5*PWM_PERIOD;

        sensors <= "011";
        wait for PWM_PERIOD;

        sensors <= "111"; -- all white, continue turnaround
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        sensors <= "110"; -- detect line again, return to line follower mode
        wait for PWM_PERIOD;

        sensors <= "100";
        wait for PWM_PERIOD;

        -- Detect crossing, should be ignored
        sensors <= "000";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        sensors <= "101"; -- return to line follower mode
        wait for PWM_PERIOD;
        wait for PWM_PERIOD; -- 14.5 periods

        -- Message 'g' should be received by now

        -- Detect next mine, wait for response
        sensors <= "101";
        mine_sim <= '1';
        wait until rx_byte = X"6D";

        -- Send 'p', drive backwards for 5 cycles
        sensors <= "101";
        tx_byte <= X"70";
        tx_send <= not tx_send;
        mine_sim <= '0';
        wait for 1.5*PWM_PERIOD;
        wait for PWM_PERIOD;

        sensors <= "001";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        -- Start turning clockwise (right)
        sensors <= "011";
        wait for PWM_PERIOD;

        sensors <= "111";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        sensors <= "110"; -- detect line again, return to line follower mode
        wait for PWM_PERIOD;

        sensors <= "101";
        wait for PWM_PERIOD; -- 24.5 periods

        -- Message 'g' should be received by now

        -- Detect next mine, wait for response
        sensors <= "101";
        mine_sim <= '1';
        wait until rx_byte = X"6D";

        -- Send 'q', drive backwards for 5 cycles
        sensors <= "101";
        tx_byte <= X"71";
        tx_send <= not tx_send;
        mine_sim <= '0';
        wait for 1.5*PWM_PERIOD;
        wait for PWM_PERIOD;
        sensors <= "100";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        -- Start turning counterclockwise (left)
        sensors <= "110";
        wait for PWM_PERIOD;

        sensors <= "111";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD;

        sensors <= "011"; -- detect line again, return to line follower mode
        wait for PWM_PERIOD;

        sensors <= "101";
        wait for PWM_PERIOD; -- 34.5 periods

        -- Message 'g' should be received by now

        sensors <= "101"; -- continue forward
        wait for PWM_PERIOD;

        -- Detect station, stop and wait
        sensors <= "111";
        wait for PWM_PERIOD;
        wait for PWM_PERIOD; -- 37.5 periods

        -- Message 't' should be received by now

        wait;
    end process;

end architecture;
