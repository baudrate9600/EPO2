library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity mine_freq is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		mine_sensor	: in	std_logic;
			
		mine_detect	: out	std_logic
	);
end entity mine_freq;

architecture behaviour of mine_freq is

	type mine_state is ( 	mine,
				no_mine,
				reset_mine,
				count_mine,
				count_no_mine,
				count_reset_mine,
				count_reset_no_mine
				);
	signal state, new_state : mine_state;
	signal mine_count, new_mine_count	: unsigned(19 downto 0);

begin
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				state <= reset_mine; 
			else
				state <= new_state;
			end if ;
		end if ;
	end process ;

	process (state, mine_sensor, clk)
	begin
		case state is
			when reset_mine =>
				mine_count <= (others => '0');
				mine_detect <= '0';
				new_state <=	count_no_mine;
			when count_no_mine =>
				mine_count <= new_mine_count;
				mine_detect <= '0';
				if (mine_sensor = '1' and unsigned(mine_count) > 5000) then
					new_state <=	mine;
				elsif (mine_sensor = '1' and unsigned(mine_count) <= 5000) then
					new_state <=	no_mine;
				else
					new_state <=	count_no_mine;
				end if;
			when count_mine =>
				mine_count <= new_mine_count;
				mine_detect <= '1';
				if (mine_sensor = '1' and unsigned(mine_count) > 5000) then
					new_state <=	mine;
				elsif (mine_sensor = '1' and unsigned(mine_count) <= 5000) then
					new_state <=	no_mine;
				else
					new_state <=	count_mine;
				end if;
			when no_mine =>
				mine_detect <= '0';
				if (mine_sensor ='0') then
					mine_count <= (others => '0');
					new_state <= count_reset_no_mine;
				else
					new_state <=	no_mine;
				end if;
			when count_reset_no_mine =>
				mine_detect <= '0';
				mine_count <= (others => '0');
				new_state <=	count_no_mine;
			when mine =>
				mine_detect <= '1';
				if (mine_sensor ='0') then
					mine_count <= (others => '0');
					new_state <= count_reset_mine;
				else
					new_state <=	mine;
				end if;
			when count_reset_mine =>
				mine_detect <= '1';
				mine_count <= (others => '0');
				new_state <=	count_mine;
		end case;
	end process;

	process(mine_count)
	begin
		new_mine_count <= mine_count + 1;
	end process;
end architecture behaviour;