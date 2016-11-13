LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity elevator is
	port (
		clk: in std_logic;
		request_switches : in std_logic_vector (3 downto 0);
		request_button : in std_logic;
		open_button : in std_logic;
		stop_map: out std_logic_vector (9 downto 0);
		request_display : out std_logic_vector (6 downto 0);
		current_floor_display : out std_logic_vector(6 downto 0);
		direction_display : out std_logic_vector(6 downto 0);
		target_display : out std_logic_vector(6 downto 0);
		door_state_display out std_logic_vector(6 downto 0)
	);
end entity elevator;

architecture logic of elevator is
	
	component seconds_clock
		port (
			clk : in STD_LOGIC;
			seconds_clk: out std_logic
		);
	end component seconds_clock;
	
	component counter
		generic (
			count_max : unsigned
		);
		PORT (
			clk : in STD_LOGIC;
			increment : in std_logic;
			enable : in STD_LOGIC;
			max : out std_logic;
			count_out : out unsigned (3 downto 0)
		);
	end component counter;
	
	component display_driver
		PORT (
			input : in unsigned (3 downto 0);
			display : out std_logic_vector (6 downto 0)
		);
	end component display_driver;
	
	signal seconds : std_logic;
	signal count_out : unsigned (3 downto 0);

begin
	
	u1: seconds_clock port map (
		clk => clk,
		seconds_clk => seconds
	);
	
	u2: counter 
	generic map (
		count_max => "1001"
	)
	port map (
		clk => clk,
		increment => seconds,
		enable => enable,
		max => max,
		count_out => count_out
	);	
	
	u3: display_driver port map (
		input => count_out,
		display => display
	);
	
end architecture logic;