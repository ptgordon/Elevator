LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity elevator_cortex is
generic (
	floor_array_width	: positive;
	dir_array_width : positive;
	stop_array_width : positive;
	number_elevators : positive;
	floor_width : positive;  --how many bits to support counter
	top_floor :positive   -- what is the max value of the counter ( modulus )
	);
port (
	up_button, down_button : in std_logic;
	source_floor : in std_logic_vector(floor_width-1 downto 0);
	current_floor_array : in std_logic_vector(floor_array_width-1 downto 0);
	target_floor_array : in std_logic_vector(floor_array_width-1 downto 0);
	dir_array : in std_logic_vector(dir_array_width-1 downto 0); 
	stop_array : in std_logic_vector(stop_array_width-1 downto 0);
	source_select : out std_logic_vector(number_elevators-1 downto 0);
	source_out : out std_logic_vector(floor_width-1 downto 0);
	push_source : out std_logic;
	pipeline_select : out std_logic_vector(number_elevators-1 downto 0);
	pipeline_out : out std_logic_vector(top_floor downto 0);
	push_pipeline : out std_logic;
	);
end;

architecture elevator_unit1 of elevator_unit is
	constant idle : std_logic_vector(1 downto 0) := "00";
	constant up : std_logic_vector(1 downto 0) := "01";
	constant down : std_logic_vector(1 downto 0) := "10";
	constant door_open : std_logic_vector(1 downto 0) := "11";
	function set_target(
		lower : std_logic_vector;
		upper : std_logic_vector;
		direction : std_logic_vector;
		stop_map : std_logic_vector
		) return unsigned is
		variable target_vector : unsigned(floor_wide downto 0);
	begin
		target_vector := (others => '0');
		target_vector(floor_wide) := '1';
		for i in lower to upper loop
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