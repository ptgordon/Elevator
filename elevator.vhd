LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity elevator is
	port (
		CLOCK_50: in std_logic;
		SW : in unsigned (3 downto 0);
		KEY : in std_logic_vector(1 downto 0);
		LEDR: out std_logic_vector (9 downto 0);
		HEX0: out std_logic_vector (6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0);
		HEX2 : out std_logic_vector(6 downto 0);
		HEX3 : out std_logic_vector(6 downto 0);
		HEX4 : out std_logic_vector(6 downto 0)
	);
end entity elevator;

architecture logic of elevator is
	
	component gen_counter
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
	end component gen_counter;
	
	component display_driver 
		port (
			input : in unsigned (3 downto 0);
			display : out std_logic_vector (6 downto 0)
		);
	end component display_driver;
	
	component open_close_display
		port(
			input : in std_logic;
			display : out std_logic_vector (6 downto 0)
		);
	end component open_close_display;
	
	component up_down_display
		port (
			input : in std_logic_vector(1 downto 0);
			display : out std_logic_vector (6 downto 0)
		);
	end component up_down_display;
	
	component elevator_unit
		generic (
			floor_wide : positive;
			top_floor : positive   -- what is the max value of the counter ( modulus )
			);
		port (
			clk,
			reset,
			load_request,
			state_shift,
			open_req: in	std_logic; -- system clock
			request_floor : in unsigned(floor_wide-1 downto 0);
			door : out std_logic;
			dir : out std_logic_vector(1 downto 0);
			current_floor,
			target_floor: out unsigned(floor_wide-1 downto 0);
			stop_map	: out std_logic_vector(top_floor downto 0)
		);
	end component elevator_unit;
	
	signal state_shift : std_logic;
	signal open_close : std_logic;
	signal up_down : std_logic_vector(1 downto 0);
	signal current_floor : unsigned (3 downto 0);
	signal target_floor : unsigned (3 downto 0);
	
	

begin
	
	u1: gen_counter
		generic map (
			wide => 28,
			max => 100000000
		) port map (
			clk => CLOCK_50,
			inc => '1',
			data => (others => '0'),
			load => '0',
			enable => '1',
			reset => '0',
			count => open,
			term => state_shift
		);
	
	u2: elevator_unit 
		generic map(
			floor_wide => 4,
			top_floor => 9   -- what is the max value of the counter ( modulus )
			)
		port map(
			clk => CLOCK_50,
			reset => '0',
			load_request => KEY(0),
			state_shift => state_shift,
			open_req => KEY(1),
			request_floor => SW,
			door => open_close,
			dir => up_down,
			current_floor=> current_floor,
			target_floor=> target_floor,
			stop_map	=> LEDR
		);
	
	u3: display_driver
		port map (
			input => current_floor,
			display => HEX0
		);
	
	u4: display_driver 
		port map (
			input => SW(3 downto 0),
			display => HEX1
		);
		
	u5: open_close_display
		port map (
			input => open_close,
			display => HEX2
		);
		
	u6: up_down_display
		port map (
			input => up_down,
			display => HEX3
		);
		
	u7: display_driver
		port map (
			input => target_floor,
			display => HEX4
		);
		
end architecture logic;