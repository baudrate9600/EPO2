--Author: Olasoji Makinwa 
--date: 14/3/2020
--description: 
--This program  counts to 2^20 enough to store 1 milion counts 
-- which allows the fpga to track a period of atleast 20ms 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timebase is
  port (
    clk : in std_logic;             
    reset : in std_logic;
    count_out : out std_logic_vector (19 downto 0)
  ) ;
end timebase;

architecture behav of timebase is

    signal counter : unsigned (19 downto 0);   --Counter needs to count to atleast 1M , so atleast 20 bits are needed 

begin
    counter_process : process( clk, reset )
    begin
        --Every rising edge increment the counter 
        if (rising_edge(clk)) then 
            --Reset the counter to zero
            if (reset = '1' )then
                counter <= (others => '0');
            else 
            --Counter resets after reaching the max value
                counter <= counter +  1;
            end if;
        end if; 
    

        
    end process ; -- counter_process

    --Assign the value to the output 
    count_out <= std_logic_vector (counter);
end behav ; -- behav

