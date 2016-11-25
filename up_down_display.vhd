--Patrick Gordon
--disply_driver

LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY up_down_display IS
	port (
		clk: in std_logic;
		up_array: in  std_logic_vector(9 downto 0);
		down_array: in std_logic_vector(9 downto 0);
		call: in unsigned(3 downto 0);
		display : out std_logic_vector(6 downto 0)
	);
END up_down_display;

ARCHITECTURE up_down_display1 OF up_down_display IS
signal i_display : std_logic_vector(6 downto 0);
BEGIN
	PROCESS (up_array, down_array, call, i_display, clk) begin
		if rising_edge(clk) then
			i_display <= "1111111";
			if up_array(to_integer(call)) = '0' and down_array(to_integer(call)) = '0' then
				display <= (i_display and "0111111");
			else
				if up_array(to_integer(call)) = '1' then
					display <= (i_display and "1111110");
					i_display <= "1111110";
				end if;
			
				if down_array(to_integer(call)) = '1' then
					display <= (i_display and "1110111");
				end if;
			end if;
		end if;
		
	END PROCESS;
END up_down_display1;