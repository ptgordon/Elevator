LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity modified_multiplexer is
	generic (
		input_width : positive;  
		output_width : positive 
		);
	port (
		input_array : in unsigned(input_width-1 downto 0);
		input_sel : in std_logic;
		output : out unsigned(output_width-1 downto 0)
		);
	end;

architecture modified_multiplexer1 of modified_multiplexer is
	signal i_input : unsigned(input_width-1 downto 0);
	begin
		i_input <= input_array srl (to_integer(input_sel)*output_width);
		output <= i_input(output_width-1 downto 0);
	end;