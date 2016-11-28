LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity button_decoder is
	generic (
		select_width : positive;
		output_width : positive --calculated as(floor wide + stop wide + 2)
		);
	port (
		clk : in std_logic;
		input : in std_logic;
		output_sel : in unsigned(select_width-1 downto 0);
		output_array : out unsigned(output_width-1 downto 0)
		);
	end;

architecture button_decoder1 of button_decoder is
	signal i_output : unsigned(output_width-1 downto 0) := (others=> '1');
	begin
	decode : process(clk) begin
		if rising_edge(clk) then
			i_output <= (others=> '1');
			i_output(0) <= input;
			output_array <= i_output rol (to_integer(output_sel));
		end if;
	end process;
end;