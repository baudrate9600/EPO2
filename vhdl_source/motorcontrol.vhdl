
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity motorcontrol is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		direction	: in	std_logic; --'0' = left anmd '1' = right
		count_in	: in	std_logic_vector (19 downto 0);

		pwm		: out	std_logic
	);
end entity motorcontrol;

architecture behaviour of motorcontrol is

	type motor_controller_state is ( motor_uit ,
					motor_left,
					motor_right);
	signal state, new_state : motor_controller_state;

begin
	process ( clk )
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				state <= motor_uit; 
			else
				state <= new_state;
			end if ;
		end if ;
	end process ;

	process (state, direction, count_in)
	begin
		case state is
			when motor_uit =>
				pwm <= '0' ;
				if ( direction = '0') then
					new_state <= motor_left ;
				else
					new_state <= motor_right ;
				end if;
			when motor_left =>
				if (unsigned(count_in) >= 50000) then
					pwm <= '0';
				else
					pwm <= '1';
				end if;
			when motor_right =>
				if (unsigned(count_in) >= 100000) then
					pwm <= '0';
				else
					pwm <= '1';
				end if;
		end case;
	end process;
end architecture behaviour;

--library IEEE;
--use IEEE.std_logic_1164.all;
--use ieee.numeric_std.all;

--entity motorcontrol_tb is
--end entity motorcontrol_tb;

--architecture structural of motorcontrol_tb is
--	component motorcontrol is
--		port (	clk		: in	std_logic;
--			reset		: in	std_logic;
--			direction	: in	std_logic;
--			count_in	: in	std_logic_vector (19 downto 0);
--
--			pwm		: out	std_logic
--		);
--	end component;
--	component timebase is
--		port (	clk		: in	std_logic;
--			reset		: in	std_logic;
--
--			count_out	: out	std_logic_vector (19 downto 0)
--		);
--	end component;
--	signal clk, reset, pwm, direction: std_logic;
--	signal count_in, count_out: std_logic_vector (19 downto 0);
--begin
--	clk <= '0' after 0 ns, '1' after 10 ns when clk/= '1' else '0' after 10 ns;
--	reset <= '1' after 0 ns, '0' after 11 ns;
--	direction <= '1' after 0 ns, '0' after 20ms;
--	count_in <= count_out;
--L1: timebase port map (clk=>clk, reset=>reset, count_out=>count_out);
--L2: motorcontrol port map (clk=>clk, reset=>reset, direction=>direction, count_in=>count_in, pwm=>pwm);

--end structural;
