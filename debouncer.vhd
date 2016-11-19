LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity signal_debouncer is
	port (
		clk : in std_logic;
		input_signal : in std_logic;
		debounced_signal : out std_logic
		);
	end;

architecture signal_debouncer1 of signal_debouncer is
	signal i_last_signal : std_logic := '1';
	signal i_track : std_logic := '0';
	signal i_count : unsigned(9 downto 0) := (others => '0');
	begin
	debounce: process(clk) begin
		if rising_edge(clk) then
			
			if input_signal /= i_last_signal then
				i_track <= '1';
				i_last_signal <= input_signal;
			end if;
			
			if i_track = '1' then 
				i_count <= i_count + 1;
			end if;
			
			if i_count = "1111111111" then
				i_count <= (others => '0');
				if input_signal = i_last_signal then
					i_track <= '0';
				end if;
			end if;
			
			if i_track = '0' then
				debounced_signal <= input_signal;
			end if;
		end if;			
	end process;
end;