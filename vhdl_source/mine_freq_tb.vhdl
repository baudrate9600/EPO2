library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity mine_freq_tb is
end entity mine_freq_tb;

architecture test of mine_freq_tb is
    
component mine_freq is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		mine_sensor	: in	std_logic;
		mine_detect	: out	std_logic
	);
end component mine_freq;

    signal clk, reset, mine_sensor, mine_detect : std_logic;
begin
    DUT: mine_freq port map(clk,reset,mine_sensor,mine_detect);
    process 
    begin
        clk <= '0'; 
        wait for 10 ns; 
        clk <= '1';
        wait for 10 ns; 
    end process;


    process begin 
        reset <= '1' ; 
        wait for 10 us ;
        reset <= '0';
        wait for 600 us; 
        reset <= '1';
        wait ;
    end process; 

    process begin 
        mine_sensor <= '1';
        wait for 50 us; 
        mine_sensor <= '0'; 
        wait for 50 us;


        mine_sensor <= '1';
        wait for 57us;
        mine_sensor <= '0'; 
        wait for 57 us; 

        mine_sensor <= '1'; 
        wait for 50 us; 
        mine_sensor <= '0';
        wait for 50 us;
        
        mine_sensor <= '1';
        wait for 57 us ;
        mine_sensor <= '0'; 
        wait for 57 us; 
    end process;

        
            
    
end architecture test;