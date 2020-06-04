entity uart is
	port (
		clk, reset: in std_logic;
		rx: in std_logic; -- input bit stream
		tx: out std_logic; -- output bit stream
		data_in: in std_logic_vector(7 downto 0); -- byte to be sent
		data_out: out std_logic_vector(7 downto 0); -- received byte
		write_data: in std_logic; -- write to transmitter buffer 
		read_data: in std_logic; -- read from receiver buffer 
		new_data: out std_logic; -- new data available
	);
end uart;