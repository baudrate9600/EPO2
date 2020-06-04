--Author: Olasoji Makinwa 
--date: 14/3/2020
--description: 
--Input buffer
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity input_buffer is
  port (
    CLK         : in std_logic;
    sensor_L_in : in std_logic;
    sensor_M_in : in std_logic;
    sensor_R_in : in std_logic; 
    sensor_L_out : out std_logic; 
    sensor_M_out : out std_logic;
    sensor_R_out : out std_logic
  ) ;
end input_buffer;

architecture behav of input_buffer is
    signal buffer_register_0 :  std_logic_vector(2 downto 0); 
    signal buffer_register_1 :  std_logic_vector(2 downto 0); 



begin
    buffers : process( clk )
    begin
        if rising_edge(clk) then 
        
        --latches the value of the first flip flop
        buffer_register_1(0)  <=  buffer_register_0(0);
        buffer_register_1(1)  <=  buffer_register_0(1);
        buffer_register_1(2)  <=  buffer_register_0(2);
        
        --latches the value of the sensors
        buffer_register_0(0)  <= sensor_L_in; 
        buffer_register_0(1)  <= sensor_M_in; 
        buffer_register_0(2)  <= sensor_R_in; 

        end if; 
    end process ; -- buffers
    
    --the output signals are connected to the second flip flop
    sensor_L_out  <= buffer_register_1(0);
    sensor_M_out  <= buffer_register_1(1);
    sensor_R_out  <= buffer_register_1(2);
end behav ; -- behav