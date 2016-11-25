LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity multi_elevator is
	port (
		CLOCK_50: in std_logic;
		SW : in unsigned (9 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		LEDR: out unsigned(9 downto 0);
		HEX0: out std_logic_vector (6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0);
		HEX2 : out std_logic_vector(6 downto 0);
		HEX3 : out std_logic_vector(6 downto 0);
		HEX4 : out std_logic_vector(6 downto 0);
		HEX5 : out std_logic_vector(6 downto 0)
	);
end entity multi_elevator;

architecture logic of multi_elevator is
	
	component modified_counter
		generic (
			wide : positive;
			idle_max : positive;
			up_down_max : positive;
			open_max : positive
			);
		port (
			clk : in std_logic;
			inc : in std_logic;
			data : in std_logic_vector(wide-1 downto 0);
			state_read : in std_logic_vector(1 downto 0);
			load : in std_logic;
			enable : in std_logic;
			reset : in std_logic;
			count : out std_logic_vector(wide-1 downto 0);
			term : out std_logic
			);
	end component modified_counter;
	
	component generic_multiplexer
		generic (
			input_width : positive;  --calculated as number of elevators *(floor wide + stop wide + 2)
			select_width : positive;
			output_width : positive --calculated as(floor wide + stop wide + 2)
		);
	port (
			clk : in std_logic;
			input_array : in unsigned(input_width-1 downto 0);
			input_sel : in unsigned(select_width-1 downto 0);
			output : out unsigned(output_width-1 downto 0)
		);
	end component generic_multiplexer;
	
	component button_decoder is
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
	end component button_decoder;

	
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
			clk: in std_logic;
			up_array: in  std_logic_vector(9 downto 0);
			down_array: in std_logic_vector(9 downto 0);
			call: in unsigned(3 downto 0);
			display : out std_logic_vector(6 downto 0)
		);
	end component up_down_display;
	
	component elevator_unit_v1
		generic (
			floor_wide : positive;  --how many bits to support counter
			top_floor :positive   -- what is the max value of the counter ( modulus )
		);
	port (
		clk,  --system clock
		reset,  -- not used
		load_request,  --button that loads the request
		state_shift,  --commands shift change
		open_req: in	std_logic; -- system clock
		up_array, 
		down_array: unsigned(top_floor downto 0);
		request_floor : in unsigned(floor_wide-1 downto 0);  -- floor address being requested
		door, 
		req_ack : out std_logic;  --open or closed
		dir : out std_logic_vector(1 downto 0);  -- up or down or idle
		current_floor: out unsigned(floor_wide-1 downto 0);  --displays current floor
		stop_map	: out unsigned(top_floor downto 0); --displays stop map
		current_state : out std_logic_vector(1 downto 0)
		);
	end component elevator_unit_v1;
	
	component elevator_cortex is
		generic (
			top_floor : positive;
			elevators : positive;
			floor_width : positive;
			floor_array_width : positive;
			dir_array_width : positive
		);
		port (
			clk : in std_logic;
			up_button, down_button : in std_logic;
			call_floor : in unsigned(floor_width-1 downto 0);
			floor_array : in unsigned(floor_array_width-1 downto 0);
			dir_array : in std_logic_vector(dir_array_width-1 downto 0);
			elevator_ready : in std_logic_vector(elevators-1 downto 0);
			up_array, 
			down_array : out std_logic_vector(top_floor-1 downto 0)
		);
	end component elevator_cortex;
	
	signal state_shift1, state_shift2, open_req1, open_req2 : std_logic;
	signal open_close, open_close1, open_close2 : std_logic;
	signal up_down : std_logic_vector(1 downto 0);
	signal current_floor1, current_floor2, current_floor : unsigned (3 downto 0);
	signal target_floor : unsigned (3 downto 0);
	signal current_state1, current_state2 : std_logic_vector(1 downto 0);
	signal current_state :  unsigned(1 downto 0);
	signal req_ack1, req_ack2: std_logic;
	signal up_array, down_array: std_logic_vector(8 downto 0);
	signal dir1, dir2: std_logic_vector(1 downto 0);
	signal load_request1, load_request2: std_logic;
	signal stop_map1, stop_map2: unsigned(9 downto 0);

begin

	rdecoder: button_decoder
		generic map (
			select_width => 1,
			output_width => 2 
		) port map (
			clk => ClOCK_50,
			input => KEY(0),
			output_sel => SW(8 downto 8),
			output_array(1) => load_request2,
			output_array(0) => load_request1
		);
		
	odecoder: button_decoder
		generic map (
			select_width => 1,
			output_width => 2 
		) port map (
			clk => CLOCK_50,
			input => KEY(1),
			output_sel => SW(8 downto 8),
			output_array(1) => open_req2,
			output_array(0) => open_req1
		);
	
	counter1: modified_counter
		generic map (
			wide => 28,
			idle_max => 5000000,
			up_down_max => 100000000,
			open_max => 150000000
		) port map (
			clk => CLOCK_50,
			inc => '1',
			data => (others => '0'),
			state_read => current_state1,
			load => '0',
			enable => '1',
			reset => '0',
			count => open,
			term => state_shift1
		);
		
	counter2: modified_counter
		generic map (
			wide => 28,
			idle_max => 5000000,
			up_down_max => 100000000,
			open_max => 150000000
		) port map (
			clk => CLOCK_50,
			inc => '1',
			data => (others => '0'),
			state_read => current_state2,
			load => '0',
			enable => '1',
			reset => '0',
			count => open,
			term => state_shift2
		);
	
	ev1: elevator_unit_v1
		generic map (
			floor_wide => 4, --how many bits to support counter
			top_floor => 9   -- what is the max value of the counter ( modulus )
			) port map (
			clk => CLOCK_50,  --system clock
			reset => '0',  -- not used
			load_request => load_request1,  --button that loads the request
			state_shift => state_shift1,  --commands shift change
			open_req => open_req1,
			up_array(9) => '0',
			up_array(8 downto 0) => unsigned(up_array),
			down_array(9 downto 1) => unsigned(down_array),
			down_array(0) => '0',
			request_floor => SW(3 downto 0),  -- floor address being requested
			door => open_close1, 
			req_ack => req_ack1,  --open or closed
			dir => dir1,  -- up or down or idle
			current_floor => current_floor1,  --displays current floor
			stop_map	=> stop_map1, --displays stop map
			current_state => current_state1
			);
		
	ev2: elevator_unit_v1
		generic map (
			floor_wide => 4, --how many bits to support counter
			top_floor => 9   -- what is the max value of the counter ( modulus )
			) port map (
			clk => CLOCK_50,  --system clock
			reset => '0',  -- not used
			load_request => load_request2,  --button that loads the request
			state_shift => state_shift2,  --commands shift change
			open_req => open_req2,
			up_array(9) => '0',
			up_array(8 downto 0) => unsigned(up_array),
			down_array(9 downto 1) => unsigned(down_array),
			down_array(0) => '0',
			request_floor => SW(3 downto 0),  -- floor address being requested
			door => open_close2, 
			req_ack => req_ack2,  --open or closed
			dir => dir2,  -- up or down or idle
			current_floor => current_floor2,  --displays current floor
			stop_map	=> stop_map2, --displays stop map
			current_state => current_state2
			);
		
	cfmultiplexer: generic_multiplexer
		generic map(
			input_width => 8,
			select_width => 1,
			output_width => 4 
		) port map(
			clk => ClOCK_50,
			input_array (7 downto 4) => current_floor2,
			input_array (3 downto 0) => current_floor1,
			input_sel => SW(8 downto 8),
			output => current_floor
		);
		
		
	ocmultiplexer: generic_multiplexer
		generic map (
			input_width => 2,
			select_width => 1,
			output_width => 1 
		) port map (
			clk => CLOCK_50,
			input_array (1) => open_close2,
			input_array (0) => open_close1,
			input_sel => SW(8 downto 8),
			output(0) => open_close
		);
		
	smmultiplexer: generic_multiplexer
		generic map (
			input_width => 20,
			select_width => 1,
			output_width => 10 
		) port map (
			clk => CLOCK_50,
			input_array (19 downto 10) => unsigned(stop_map2),
			input_array(9 downto 0) => unsigned(stop_map1),
			input_sel => SW(8 downto 8),
			output => LEDR
		);
	
	cortex: elevator_cortex
		generic map (
			top_floor => 9,
			elevators => 2,
			floor_width => 4,
			floor_array_width => 8,
			dir_array_width => 4
		) port map (
			clk => CLOCK_50,
			up_button => KEY(3), 
			down_button => KEY(2),
			call_floor => SW(7 downto 4),
			floor_array(7 downto 4) => current_floor2,
			floor_array(3 downto 0) => current_floor1,
			dir_array(3 downto 2) => dir2,
			dir_array(1 downto 0) => dir1,
			elevator_ready(0) => req_ack1,
			elevator_ready(1) => req_ack2,
			up_array => up_array,
			down_array => down_array
		);
	
	current_display: display_driver
		port map (
			input => current_floor,
			display => HEX0
		);
	
	door_display: open_close_display 
		port map (
			input => open_close,
			display => HEX1
		);
		
	request_display: display_driver
		port map (
			input => SW(3 downto 0),
			display => HEX2
		);
		
	call_display: display_driver
		port map (
			input => SW(7 downto 4),
			display => HEX3
		);
		
	elevator_number: display_driver
		port map (
			input(3 downto 1) => (others => '0'),
			input(0) => sw(8),
			display => HEX4
		);
		
	uddisplay: up_down_display
		port map (
			clk => CLOCK_50,
			up_array(9) => '0',
			up_array(8 downto 0) => up_array,
			down_array(9 downto 1) => down_array,
			down_array(0) => '0',
			call => SW(7 downto 4),
			display => HEX5
		);
		
end architecture logic;