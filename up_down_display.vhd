--Patrick Gordon
--disply_driver

LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY up_down_display IS
	PORT (
		input : in std_logic_vector(1 downto 0);
		display : out std_logic_vector (6 downto 0)
	);
END up_down_display;

ARCHITECTURE up_down_display1 OF up_down_display IS
BEGIN
	PROCESS (input)
	BEGIN
		display <= "1111111";
		IF (input = "01") then
			display <= "1100011";
		elsif (input = "10") then
			display <= "0100001";
		else 
			display <= "0111111";
		END IF;
	END PROCESS;
END up_down_display1;