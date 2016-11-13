--Patrick Gordon
--disply_driver

LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY display_driver IS
	PORT (
		input : in unsigned (3 downto 0);
		display : out std_logic_vector (6 downto 0)
	);
END display_driver;

ARCHITECTURE display_driver1 OF display_driver IS
BEGIN
	PROCESS (input)
	BEGIN
		display <= "0000000";
		IF (input = "0000") then
			display <= "1111110";
		ELSIF (input = "0001") then
			display <= "0110000";
		ELSIF (input = "0010") then
			display <= "1101101";
		ELSIF (input = "0011") then
			display <= "1111001";
		elsif (input = "0100") then
			display <= "0110011";
		elsif (input = "0101") then
			display <= "1011011";
		elsif (input = "0110") then
			display <= "1011111";
		elsif (input = "0111") then
			display <= "1110000";
		elsif (input = "1000") then
			display <= "1111111";
		elsif (input = "1001") then
			display <= "1111011";
		else
			display <= "1001111";
		END IF;
	END PROCESS;
END display_driver1;