-- grouptask 4 testbench for EPO-2 student version


library IEEE;
use IEEE.std_logic_1164.all;


entity uart_tb is
end entity;


architecture sim of uart_tb is

    constant CLOCK_PERIOD    : time := 20 ns; -- 50 MHz clock
    constant BAUD_PERIOD     : time := 104167 ns; -- 9600 baud rate
    constant PWM_PERIOD      : time := 20 ms;
    constant NO_MINE_PERIOD  : time := 100 us; -- 10 kHz


    component uart is
	port (
		clk, reset: in std_logic;
		rx: in std_logic; -- input bit stream
		tx: out std_logic; -- output bit stream
		data_in: in std_logic_vector(7 downto 0); -- byte to be sent
		data_out: out std_logic_vector(7 downto 0); -- received byte
		write_data: in std_logic; -- write to transmitter buffer 
		read_data: in std_logic; -- read from receiver buffer 
		new_data: out std_logic -- new data available
	);
end component uart;
   -- Clock/reset
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    --Uart IO 
    signal rx,tx,write_data,read_data,new_data: std_logic; 
    signal data_in, data_out : std_logic_vector(7 downto 0);

    signal rx_byte, tx_byte : std_logic_vector(8 downto 0);
     signal tx_send : std_logic := '0';
  

begin

    -- Robot instance
    uart_inst: uart port map (
        clk         => clk,
        reset       => reset,

        rx          => rx,
        tx          => tx,

	data_in     => data_in,
	data_out    => data_out,
	
	read_data   => read_data, 
	write_data  => write_data 
    );


    clk <= not clk after 0.5*CLOCK_PERIOD; -- generate clock
    reset <= '0' after 2*CLOCK_PERIOD;     -- hold reset for 2 clock cycles


   -- Simulated host RX
--    process
--    begin
--       wait until tx = '0';

--        wait for BAUD_PERIOD/2;
 --       if tx = '0' then -- Start bit detected
  --          for I in 0 to 7 loop
--                wait for BAUD_PERIOD;
 --               rx_byte(I) <= tx;
 --           end loop;
  --      end if;
--
 --       wait for 60 ms; -- reset output for next round
  --      rx_byte <= (others => 'U');
  --  end process;

    -- Simulated host TX 
    process
    begin
        rx <= '1';
        wait on tx_send;

        -- Start
        rx <= '0';
        wait for BAUD_PERIOD;

        -- Datarun
        for I in 0 to 8 loop
            rx <= tx_byte(I);
            wait for BAUD_PERIOD;
        end loop;

        -- Stop
        rx <= '1';
        wait for BAUD_PERIOD;
    end process;

    process 
    begin 
   
       tx_byte <= X"00" & "0";
       tx_byte <= "10110100" & "0"; -- EVEN bit with parity zero 
       	tx_send <= not tx_send;
      wait for 3 ms; 

       tx_byte <= "10010100" & "1"; -- ODD bit with parity one 
       	tx_send <= not tx_send;
      wait for 3 ms; 
       
       tx_byte <= "10110101" & "0"; -- EVEN bit with parity one
       	tx_send <= not tx_send;
      wait for 3 ms; 
       
       tx_byte <= "10010100" & "1"; -- ODD bit with parity zero 
       	tx_send <= not tx_send;
      wait for 3 ms; 
	

	wait;
    end process;



end architecture;




