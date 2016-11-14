LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity elevator_unit is
generic (
	floor_wide : positive;
	top_floor :positive   -- what is the max value of the counter ( modulus )
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
end;

architecture elevator_unit1 of elevator_unit is
	subtype elevator_state is std_logic_vector(1 downto 0);
	constant idle : std_logic_vector(1 downto 0) := "00";
	constant up : std_logic_vector(1 downto 0) := "01";
	constant down : std_logic_vector(1 downto 0) := "10";
	constant door_open : std_logic_vector(1 downto 0) := "11";
	signal state, next_state: elevator_state;
	signal i_status : std_logic := '1';
	signal i_door : std_logic := '0';
	signal door_state : std_logic := '0';
	signal i_current_floor, i_target_floor, i_next_floor : unsigned(floor_wide-1 downto 0);
	signal i_target_vector : unsigned(floor_wide downto 0);
	signal i_stop_map : std_logic_vector(top_floor downto 0);
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
				i_door <= open_req;
				if state_shift = '1' then
					state <= next_state;
					i_door <= '1';
				end if;
			end if;
		end if;
	end process;
	
	dir_set: process (clk) begin
		if (rising_edge(clk)) then
			if i_target_floor > i_current_floor then
				dir <= up;
			elsif i_target_floor < i_current_floor then
				dir <= down;
			else
				dir <= idle;
			end if;
		end if;
	end process;
				

	NS: process (state) begin
		next_state <= state;
		case state is
			when idle =>
				i_target_vector <= set_target(top_floor, idle, i_stop_map);
				i_target_floor <= i_target_vector(floor_wide-1 downto 0);
				i_status <= i_target_vector(floor_wide);
				if i_door = '0' then
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
				if i_stop_map(to_integer(i_current_floor)) = '1' then
					next_state <= door_open;
				else
					i_next_floor <= i_current_floor + 1;
				end if;
		
			when down =>
				i_target_vector <= set_target(top_floor, down, i_stop_map);
				i_target_floor <= i_target_vector(floor_wide-1 downto 0);
				if i_stop_map(to_integer(i_current_floor)) = '1' then
					next_state <= door_open;
				else
					i_next_floor <= i_current_floor - 1;
				end if;
			
			when door_open =>
				if i_door = '1' then
					if i_target_floor = i_current_floor then
						i_target_vector <= set_target(top_floor, door_open, i_stop_map);
						i_target_floor <= i_target_vector(floor_wide-1 downto 0);
						i_status <= i_target_vector(floor_wide);
					end if;
			
					if i_target_floor < i_current_floor then
						if i_target_floor > i_current_floor then
							next_state <= up;
							i_next_floor <= i_current_floor + 1;
						elsif i_status = '1' then
							next_state <= idle;
						elsif i_target_floor < i_current_floor then
							next_state <= down;
							i_next_floor <= i_current_floor - 1;
						end if;
					end if;
				end if;
			end case;
		end process;
	
	Oput : process(state) begin
		door <= '0';
		door_state <= '0';
		current_floor <= i_current_floor;
		target_floor <= i_target_floor;
		stop_map <= i_stop_map;
		case state is
			when idle =>
			when up =>
			when down =>
			when door_open =>
				door_state <= '1';
		end case;
	end process;
end;			