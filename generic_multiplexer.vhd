LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity generic_multiplexer is
	generic (
		input_width : positive;  --calculated as number of elevators *(floor wide + stop wide + 2)
		select_width : positive;
		output_width : positive --calculated as(floor wide + stop wide + 2)
		);
	port (
		clk : in std_logic;
		input_array : in unsigned(input_width-1 downto 0);
		input_sel : in unsigned(select_width-1 downto 0);
		output : out unsigned(output_width-1 downto 0)
		);
	end;

architecture generic_multiplexer1 of generic_multiplexer is
	signal i_input : unsigned(input_width-1 downto 0);
	begin
	multiplex : process(clk) begin
		if rising_edge(clk) then
			i_input <= input_array srl (to_integer(input_sel)*output_width);
			output <= i_input(output_width-1 downto 0);
		end if;
	end process;
end;