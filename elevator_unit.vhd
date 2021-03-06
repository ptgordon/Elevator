LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity elevator_unit is
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
	request_floor : in unsigned(floor_wide-1 downto 0);  -- floor address being requested
	door : out std_logic;  --open or closed
	dir : out std_logic_vector(1 downto 0);  -- up or down or idle
	current_floor,  --displays current floor
	target_floor: out unsigned(floor_wide-1 downto 0); --displays target floor
	stop_map	: out std_logic_vector(top_floor downto 0); --displays stop map
	currentstate : out unsigned(3 downto 0)
	);
end;

architecture elevator_unit1 of elevator_unit is
	subtype elevator_state is std_logic_vector(1 downto 0);
	constant idle : std_logic_vector(1 downto 0) := "00";
	constant up : std_logic_vector(1 downto 0) := "01";
	constant down : std_logic_vector(1 downto 0) := "10";
	constant door_open : std_logic_vector(1 downto 0) := "11";
	signal state, next_state: elevator_state := idle;
	signal prev_status, i_status : std_logic := '1';
	signal i_door : std_logic := '0';
	signal door_state : std_logic := '0';
	signal i_dir, prev_dir : std_logic_vector(1 downto 0) := idle;
	signal i_current_floor: unsigned(floor_wide-1 downto 0) := (others => '0'); 
	signal prev_target_floor, i_target_floor : unsigned (floor_wide-1 downto 0) := (others => '0');
	signal prev_next_floor,i_next_floor : unsigned(floor_wide-1 downto 0) := (others => '0');
	signal prev_target_vector, i_target_vector : unsigned(floor_wide downto 0) := (others => '0');
	signal i_stop_map : std_logic_vector(top_floor downto 0) := (others => '0');
	function set_target(
		top_floor : positive;
		direction : std_logic_vector;
		stop_map : std_logic_vector
		) return unsigned is
		variable target_vector : unsigned(floor_wide downto 0);
	begin
		target_vector := (others => '0');
		target_vector(floor_wide) := '1';
		for i in 0 to top_floor loop
			if stop_map(i) = '1' then
				target_vector := to_unsigned(i, floor_wide + 1);
				if direction = "10" then
					exit;
				end if;
			end if;
		end loop;
		return target_vector;
	end set_target;
	
	begin
	
	generate_map: process(clk) begin
		if(rising_edge(clk)) then
			--if direct_load = '1' then
				--stop_map(to_integer(direct_vector)) <= '1';
			--end if;
			if door_state = '1' then
				i_stop_map(to_integer(i_current_floor)) <= '0';
			end if;
			
			if load_request = '0' then
				i_stop_map(to_integer(request_floor)) <= '1';
			end if;
		end if;
	end process;

	StateMem: process (clk) begin
      if (rising_edge(clk)) then
			if reset = '1' THEN
				state <= idle;
			
			else
				if open_req = '0' then
					i_door <= '1';
				end if;
				
				if state_shift = '1' then
					state <= next_state;
					i_current_floor <= i_next_floor;
					i_door <= '0';
				end if;
			end if;
		end if;
	end process;
				
	avoid_latch: process (clk) begin
		if (rising_edge(clk)) then
			prev_dir <= i_dir;
			prev_target_vector <= i_target_vector;
			prev_target_floor <= i_target_floor;
			prev_status <= i_status;
			prev_next_floor <= i_next_floor;
		end if;
	end process;

	NS: process (state, prev_dir, prev_target_vector, prev_target_floor, prev_status, prev_next_floor, i_stop_map, i_target_vector, i_door, i_status, i_target_floor, i_current_floor, i_next_floor ) begin
		next_state <= state;
		i_target_vector <= prev_target_vector;
		i_target_floor <= prev_target_floor;
		i_status <= prev_status;
		i_next_floor <= prev_next_floor;
		i_dir <= prev_dir;
		
		case state is
			when idle =>
				i_target_vector <= set_target(top_floor, idle, i_stop_map);
				i_target_floor <= i_target_vector(floor_wide-1 downto 0);
				i_status <= i_target_vector(floor_wide);
				i_dir <= idle;
				if i_door = '1' then
					next_state <= door_open;
				elsif i_status = '0' then
					if i_target_floor > i_current_floor then
						next_state <= up;
						i_next_floor <= i_current_floor + 1;
					elsif i_target_floor = i_current_floor then
						next_state <= door_open;
					elsif i_target_floor < i_current_floor then
						next_state <= down;
						i_next_floor <= i_current_floor - 1;
					end if;
				end if;
		
			when up =>
				i_target_vector <= set_target(top_floor, up, i_stop_map);
				i_target_floor <= i_target_vector(floor_wide-1 downto 0);
				i_dir <= up;
				if i_stop_map(to_integer(i_current_floor)) = '1' then
					next_state <= door_open;
				else
					i_next_floor <= i_current_floor + 1;
				end if;
		
			when down =>
				i_target_vector <= set_target(top_floor, down, i_stop_map);
				i_target_floor <= i_target_vector(floor_wide-1 downto 0);
				i_dir <= down;
				if i_stop_map(to_integer(i_current_floor)) = '1' then
					next_state <= door_open;
				else
					i_next_floor <= i_current_floor - 1;
				end if;
			
			when door_open =>		
				if i_door = '1' then
					next_state <= door_open;
				elsif i_status = '0' then
					if i_target_floor > i_current_floor then
						next_state <= up;
						--i_next_floor <= i_current_floor + 1;
					elsif i_target_floor < i_current_floor then
						next_state <= down;
						--i_next_floor <= i_current_floor - 1;
					else
						next_state <= idle;
					end if;
				else 
					next_state <= idle;
				end if;
			end case;
		end process;
	
	Oput : process(state, i_dir, i_current_floor, i_target_floor, i_stop_map, i_door, i_status) begin
		door <= '0';
		current_floor <= i_current_floor;
		target_floor <= i_target_floor;
		stop_map <= i_stop_map;
		door_state <= '0';
		dir <= i_dir;
		case state is
			when idle =>
				currentstate <= "0000";
				target_floor <= i_current_floor;
			when up =>
				currentstate <= "0001";
			when down =>
				currentstate <= "0010";
			when door_open =>
				currentstate <= "0011";
				door_state <= '1';
				door <= '1';
				if i_dir = idle then
					target_floor <= i_current_floor;
				end if;
		end case;
	end process;
end;			