library IEEE;
use IEEE.std_logic_1164.all;

entity d_ff is
	port (	clk	: in std_logic;
		D	: in std_logic;
		Q	: out std_logic
	     );
end entity d_ff;

architecture behaviour of d_ff is
begin
	process (clk)
	begin
		if(clk'event and clk='1') then
			Q<=D;
		end if;
	end process;
end behaviour;

library IEEE;
use IEEE.std_logic_1164.all;

entity register_4 is
	port (	clk		: in	std_logic;

		l_input		: in	std_logic;
		m_input		: in	std_logic;
		r_input		: in	std_logic;
		mine_input	: in	std_logic;

		l_output	: out	std_logic;
		m_output	: out	std_logic;
		r_output	: out	std_logic;
		mine_output	: out	std_logic
	);
end entity register_4;

architecture structural of register_4 is
	component d_ff is
		port (	clk	: in std_logic;
			D	: in std_logic;
			Q	: out std_logic
	     	);
	end component;
begin
L1: d_ff port map (clk=>clk, D=>l_input, Q=>l_output);
L2: d_ff port map (clk=>clk, D=>m_input, Q=>m_output);
L3: d_ff port map (clk=>clk, D=>r_input, Q=>r_output);
L4: d_ff port map (clk=>clk, D=>mine_input, Q=>mine_output);
end structural;

library IEEE;
use IEEE.std_logic_1164.all;

entity inputbuffer is
	port (	clk			: in	std_logic;

		sensor_l_in		: in	std_logic;
		sensor_m_in		: in	std_logic;
		sensor_r_in		: in	std_logic;
		mine_sensor_in		: in	std_logic;

		sensor_l_out		: out	std_logic;
		sensor_m_out		: out	std_logic;
		sensor_r_out		: out	std_logic;
		mine_sensor_out		: out	std_logic
	);
end entity inputbuffer;

architecture structural of inputbuffer is
	component register_4 is
		port (	clk		: in	std_logic;

			l_input		: in	std_logic;
			m_input		: in	std_logic;
			r_input		: in	std_logic;
			mine_input	: in	std_logic;

			l_output	: out	std_logic;
			m_output	: out	std_logic;
			r_output	: out	std_logic;
			mine_output	: out	std_logic
		);
	end component;
	signal l_buff, m_buff, r_buff, mine_buff: std_logic;
begin
L1: register_4 port map (clk=>clk, 
			l_input=>sensor_l_in, 
			m_input=>sensor_m_in, 
			r_input=>sensor_r_in,
			mine_input=>mine_sensor_in, 
			l_output=>l_buff, 
			m_output=>m_buff, 
			r_output=>r_buff,
			mine_output=>mine_buff);
L2: register_4 port map (clk=>clk, 
			l_output=>sensor_l_out, 
			m_output=>sensor_m_out, 
			r_output=>sensor_r_out, 
			mine_output=>mine_sensor_out,
			l_input=>l_buff, 
			m_input=>m_buff, 
			r_input=>r_buff,
			mine_input=>mine_buff);
end structural;

library IEEE;
use IEEE.std_logic_1164.all;

entity inputbuffer_tb is
end entity inputbuffer_tb;

architecture structural of inputbuffer_tb is
	component inputbuffer is
		port (	clk		: in	std_logic;

			sensor_l_in	: in	std_logic;
			sensor_m_in	: in	std_logic;
			sensor_r_in	: in	std_logic;

			sensor_l_out	: out	std_logic;
			sensor_m_out	: out	std_logic;
			sensor_r_out	: out	std_logic
		);
	end component;
	signal clk, sensor_l_in, sensor_m_in, sensor_r_in, sensor_l_out, sensor_m_out, sensor_r_out: std_logic;
begin
	clk <= '1' after 0 ns, '0' after 10 ns when clk/= '0' else '1' after 10 ns;
	sensor_l_in <= '1' after 0 ns, '0' after 15 ns, '1' after 30 ns;
	sensor_m_in <= '1' after 0 ns, '0' after 20 ns;
	sensor_r_in <= '0' after 0 ns;
L1: inputbuffer port map (clk=>clk, 
			sensor_l_out=>sensor_l_out, 
			sensor_m_out=>sensor_m_out, 
			sensor_r_out=>sensor_r_out, 
			sensor_l_in=>sensor_l_in, 
			sensor_m_in=>sensor_m_in, 
			sensor_r_in=>sensor_r_in);
end structural;