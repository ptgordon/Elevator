LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity pulse is
	port (
		clk : in std_logic;
		input : in std_logic;
		output : out std_logic
		);
	end;

architecture pulse1 of pulse is
	signal i_input : std_logic := '0';
	begin
	pulsor: process(clk) begin
		if rising_edge(clk) then
			if input /= i_input then
				i_input <= input;
				output <= input;
			else 
				output <= '0';
			end if;
		end if;
	end process;
end;