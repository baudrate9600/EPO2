library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
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
end uart;

architecture structural of uart is 
component uart_rx is
   port(
      clk, reset: in std_logic;
      rx: in std_logic; -- icoming serial bit stream
      s_tick: in std_logic; -- sampling tick from baud rate generator
      rx_done_tick: out std_logic; -- data frame completion tick
      dout: out std_logic_vector(7 downto 0) -- data byte
   );
end component;
component uart_tx is
   port(
      clk, reset: in std_logic;
      tx_start: in std_logic; -- if '1' transmission starts
      s_tick: in std_logic; -- sampling tick from baud rate generator
      din: in std_logic_vector(7 downto 0); -- incoming data byte
      tx_done_tick: out std_logic; -- data frame completion tick 
      tx: out std_logic -- outcoming bit stream
   );
end component;
component buf_reg is
   port(
      clk, reset: in std_logic;
      clr_flag, set_flag: in std_logic; 
      din: in std_logic_vector(7 downto 0);
      dout: out std_logic_vector(7 downto 0);
      flag: out std_logic
   );
end component;
component baud_gen is
   generic(
      M: integer := 326 -- baud rate divisor M = 50M/(16*9600)
  );
   port(
      clk, reset: in std_logic;
      s_tick: out std_logic -- sampling tick
   );
end component;
signal s_tick_buf, rx_done_tick_buf, tx_done_tick, flag_buf_tx, tx_done_tick_buf: std_logic;
signal dout_rx, din_tx : std_logic_vector(7 downto 0);
begin
U1: uart_rx port map (clk => clk, reset=> reset, rx=>rx,s_tick=> s_tick_buf, rx_done_tick=> rx_done_tick_buf, dout=> dout_rx);
U2: uart_tx port map (clk=> clk, reset=> reset, tx_start=> flag_buf_tx, s_tick => s_tick_buf, din => din_tx, tx_done_tick=> tx_done_tick_buf, tx=> tx);
U3rx: buf_reg port map(clk=>clk, reset=> reset, clr_flag=> read_data, set_flag=>rx_done_tick_buf, din=> dout_rx, dout=>data_out, flag =>new_data);
U4tx: buf_reg port map (clk=> clk, reset=> reset, clr_flag=> tx_done_tick_buf, set_flag => write_data, din=> data_in, dout=> din_tx, flag=> flag_buf_tx);
U5: baud_gen port map (clk=>clk, reset => reset, s_tick =>s_tick_buf);
end structural;