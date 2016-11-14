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
		display <= "1111111";
		IF (input = "0000") then
			display <= "1000000";
		ELSIF (input = "0001") then
			display <= "1111001";
		ELSIF (input = "0010") then
			display <= "0100100";
		ELSIF (input = "0011") then
			display <= "0110000";
		elsif (input = "0100") then
			display <= "0011001";
		elsif (input = "0101") then
			display <= "0010010";
		elsif (input = "0110") then
			display <= "0000010";
		elsif (input = "0111") then
			display <= "1111000";
		elsif (input = "1000") then
			display <= "0000000";
		elsif (input = "1001") then
			display <= "0010000";
		else
			display <= "0000110";
		END IF;
	END PROCESS;
END display_driver1;