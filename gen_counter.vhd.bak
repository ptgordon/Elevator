LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity gen_counter is
generic (
		max :positive   -- what is the max value of the counter ( modulus )
		);
port (
		clk		:in	std_logic; -- system clock
		--data	:in std_logic_vector( 3 downto 0 ); -- data in for parallel load, use unsigned(data) to cast to unsigned
		--load	:in std_logic; -- signal to load data into i_count i_count <= unsigned(data);
		enable	:in std_logic; -- clock enable
		--reset	:in std_logic; -- reset to zeros use i_count <= (others => '0' ) since size depends on generic
		count	:out std_logic_vector( 3 downto 0 ); -- count out
		term	:out std_logic -- maximum count is reached
		);
	end;
	
architecture rtl of gen_counter is
-- use a signal of type unsigned for counting
signal  i_count	:unsigned ( 3 downto 0) := "0000";
signal  i_term :std_logic := 0;

begin
cnt: process( clk ) begin
	if ( rising_edge(clk) ) then
		if 
		
	end if;
end process;

-- I always like to use a seperate process to generate the terminal count
chk: process (i_count) begin
		-- if-then-else statements to generate terminal count go here
		
		
end process;

-- this is how we drive the count to the output.
if enable = '1' then
	count <= std_logic_vector( i_count );
end if;

term  <= i_term;

end;
				
		