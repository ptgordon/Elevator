--Patrick Gordon
--disply_driver

LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY open_close_display IS
	PORT (
		input : in std_logic;
		display : out std_logic_vector (6 downto 0)
	);
END open_close_display;

ARCHITECTURE open_close_display1 OF open_close_display IS
BEGIN
	PROCESS (input)
	BEGIN
		display <= "1111111";
		IF (input = '0') then
			display <= "0100011";
		else
			display <= "0100111";
		END IF;
	END PROCESS;
END open_close_display1;