LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity gen_counter is
	generic (
		wide : positive;
		max: positive
		);
	port (
		clk : in std_logic;
		inc : in std_logic;
		data : in std_logic_vector(wide-1 downto 0);
		load : in std_logic;
		enable : in std_logic;
		reset : in std_logic;
		count : out std_logic_vector(wide-1 downto 0);
		term : out std_logic
		);
end;

architecture rtl of gen_counter is
	signal i_count : unsigned(wide-1 downto 0) := (others => '0');
	signal i_term :std_logic := '0';
	
	begin
		reset_load: process(clk, load, reset, data, inc) begin
			if (rising_edge(clk)) then 
				if (reset = '1') then
					i_count <= (others => '0');
					i_term <= '0';
				elsif load = '1' then
					i_count <= unsigned(data);
					i_term <= '0';
				elsif (inc = '1') and (i_count < max) then
					i_count <= i_count + 1;
					i_term <= '0';
				elsif (inc = '1') and (i_count = max) then
					i_count <= (others => '0');
					i_term <= i_term;
				end if;
				
				term <= i_term;
				
				if (enable = '1') then
					count <= std_logic_vector(i_count);
				else
					count <= (others => 'Z');
				end if;
				
			end if;
		end process;
end;
				
		