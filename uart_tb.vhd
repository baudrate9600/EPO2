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
		read_data: in std_logic := '0'; -- read from receiver buffer 
		new_data: out std_logic -- new data available
	);
end component uart;
   -- Clock/reset
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    --Uart IO 
    signal rx,tx,read_data,new_data: std_logic; 
    signal data_out : std_logic_vector(7 downto 0);
    signal write_data : std_logic := '0';
    signal tx_byte : std_logic_vector(8 downto 0):=  "000000000";
    signal data_in : std_logic_vector(7 downto 0):=  "00000000";
    signal rx_byte : std_logic_vector(8 downto 0) := "000000000"; 
    signal data_byte : std_logic_vector(7 downto 0); 
    signal parity : std_logic;
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
	write_data  => write_data,
	new_data => new_data 
    );


    clk <= not clk after 0.5*CLOCK_PERIOD; -- generate clock
    reset <= '0' after 0.4 ms;     -- hold reset for 2 clock cycles


   
    process 
    begin
       wait until tx = '0';

        wait for BAUD_PERIOD/2;
        if tx = '0' then -- Start bit detected
           for I in 0 to 8 loop
                wait for BAUD_PERIOD;
               rx_byte(I) <= tx;
            end loop;
       end if;

      wait for 0.5 ms; -- reset output for next round
        --rx_byte <= (others => '0');
    end process;
  
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
    
    process begin 

         wait for 1 ms;
         data_in <= "01100110";
         write_data <= '1'; 
         wait for 0.5 ms;
         write_data <= '0'; 
         wait for 1 ms;
         write_data <= '1';
         data_in <= "01100111";
         wait for 0.5 ms; 
         write_data <= '0'; 
         wait;
  end process;
    
    
    
tx_byte <= data_byte & parity; 
    process 
    begin 
        
       data_byte <= "01100110";
       parity <= '0';
       
       wait for 0.5 ms;
       
       	tx_send <= not tx_send;
      wait for 2 ms; 
        data_byte <= "01100111";
       parity <= '0';
   
       	tx_send <= not tx_send;
      wait for 2 ms;
       data_byte <= "01100111";
       parity <= '1';
 
       	tx_send <= not tx_send;
      wait for 2 ms; 
      wait;
       data_byte <= "01101001";
       parity <= '1';

       	tx_send <= not tx_send;
      wait for 2 ms; 
	

	wait;
    end process;
    process begin 
      read_data <= '0';
      wait until new_data = '1';
      wait for 0.1 ms; 
      read_data <= '1';
      wait for 0.1 ms;
      read_data <= '0';
  end process;


end architecture;




