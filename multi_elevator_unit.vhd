LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity multi_elevator_unit is
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
	up_array, down_array: std_logic_vector(top_floor downto 0);
	request_floor : in unsigned(floor_wide-1 downto 0);  -- floor address being requested
	door, req_ack : out std_logic;  --open or closed
	dir : out std_logic_vector(1 downto 0);  -- up or down or idle
	current_floor : out unsigned(floor_wide-1 downto 0);  --displays current floor
	stop_map	: out std_logic_vector(top_floor downto 0); --displays stop map
	current_state : out std_logic_vector(1 downto 0)
	);
end;

architecture multi_elevator_unit1 of multi_elevator_unit is
	subtype elevator_state is std_logic_vector(1 downto 0);
	constant idle : std_logic_vector(1 downto 0) := "00";
	constant up : std_logic_vector(1 downto 0) := "01";
	constant down : std_logic_vector(1 downto 0) := "10";
	constant door_open : std_logic_vector(1 downto 0) := "11";
	signal state, next_state: elevator_state := idle;
	signal i_status : std_logic := '1';
	signal i_door : std_logic := '0';
	signal i_req_ack : std_logic := '0';
	signal door_state : std_logic := '0';
	signal i_dir, prev_dir : std_logic_vector(1 downto 0) := idle; 
	signal i_current_floor: unsigned(floor_wide-1 downto 0) := (others => '0'); 
	signal i_target_floor : unsigned (floor_wide-1 downto 0) := (others => '0');
	signal prev_next_floor,i_next_floor : unsigned(floor_wide-1 downto 0) := (others => '0');
	signal u_target_vector, d_target_vector, i_target_vector : unsigned(floor_wide downto 0) := (others => '0');
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
			prev_next_floor <= i_next_floor;
		end if;
	end process;

	NS: process (state, up_array, i_req_ack, u_target_vector, d_target_vector, i_dir, down_array, prev_dir, prev_next_floor, i_stop_map, i_target_vector, i_door, i_status, i_target_floor, i_current_floor, i_next_floor ) begin
		next_state <= state;
		i_req_ack <= '0';
		u_target_vector(floor_wide) <= '1';
		u_target_vector(floor_wide-1 downto 0) <= (others => '0');
		d_target_vector(floor_wide) <= '1';
		d_target_vector(floor_wide-1 downto 0) <= (others => '0');
		i_target_vector(floor_wide) <= '1';
		i_target_vector(floor_wide-1 downto 0) <= (others => '0');
		i_target_floor <= (others=> '0');
		i_status <= '1';
		i_next_floor <= prev_next_floor;
		i_dir <= prev_dir;
		
		case state is
			when idle =>
				i_dir <= idle;
				i_target_vector <= set_target(top_floor, idle, i_stop_map);
				i_target_floor <= i_target_vector(floor_wide-1 downto 0);
				i_status <= i_target_vector(floor_wide);
				
				u_target_vector <= set_target(top_floor, idle, up_array);
				if i_status = '1' then
					i_target_floor <= u_target_vector(floor_wide-1 downto 0);
				   i_status <= u_target_vector(floor_wide);
				end if;
				
				d_target_vector <= set_target(top_floor, idle, down_array);
				if i_status = '1' then
					i_target_floor <= d_target_vector(floor_wide-1 downto 0);
					i_status <= d_target_vector(floor_wide);
				end if;
				
				if i_status = '0' then
					if i_target_floor > i_current_floor then
						i_dir <= up;
						if i_stop_map(to_integer(i_current_floor)) = '1' or
							up_array(to_integer(i_current_floor)) = '1' then
								next_state <= door_open;
						else
							next_state <= up;
						end if;
					elsif i_target_floor < i_current_floor then
						i_dir <= down;
						if i_stop_map(to_integer(i_current_floor)) = '1' or
							down_array(to_integer(i_current_floor)) = '1' then
								next_state <= door_open;
						else
							next_state <= down;
						end if;
					else
						next_state <= door_open;
					end if;
				else
					next_state <= idle;
				end if;
						
					
		
			when up =>
				i_dir <= up;
				d_target_vector <= set_target(top_floor, up, down_array);
				i_status <= d_target_vector(floor_wide);
				i_target_floor<= d_target_vector(floor_wide-1 downto 0);
				if i_target_vector(floor_wide) = '0' then
					if i_current_floor = i_target_floor then
						i_dir <= down;
					end if;
				end if;
				
				i_target_vector <= set_target(top_floor, up, i_stop_map);
				if i_target_vector(floor_wide) = '0' then
					if i_status = '1' then
						i_status <= '0';
						i_target_floor <= i_target_vector(floor_wide-1 downto 0);
					elsif i_target_vector(floor_wide-1 downto 0) > i_target_floor then
						i_target_floor <= i_target_vector(floor_wide-1 downto 0);
						i_dir <= up;
					end if;
				end if;
				
				u_target_vector <= set_target(top_floor, up, up_array);
				if u_target_vector(floor_wide) = '0' then
					if i_status = '1' then
						i_status <= '0';
						i_target_floor <= u_target_vector(floor_wide-1 downto 0);
					elsif u_target_vector(floor_wide-1 downto 0) >= i_target_floor then
						i_target_floor <= u_target_vector(floor_wide-1 downto 0);
						i_dir <= up;
					end if;
				end if;
				
				
				if i_status = '0' then
					if i_stop_map(to_integer(i_current_floor)) = '1' or
					   up_array(to_integer(i_current_floor)) = '1' then
						next_state <= door_open;
					
					elsif i_target_floor > i_current_floor then
						i_next_floor <= i_current_floor + 1;
					
					elsif i_target_floor < i_current_floor then
						next_state <= down;
					end if;
				else
					next_state <= idle;
				end if;
		
			when down =>
				i_dir <= down;
				u_target_vector <= set_target(top_floor, down, up_array);
				i_status <= u_target_vector(floor_wide);
				i_target_floor<= u_target_vector(floor_wide-1 downto 0);
				if i_target_vector(floor_wide) = '0' then
					if i_current_floor = i_target_floor then
						i_dir <= up;
					end if;
				end if;
				
				i_target_vector <= set_target(top_floor, down, i_stop_map);
				if i_target_vector(floor_wide) = '0' then
					if i_status = '1' then
						i_status <= '0';
						i_target_floor <= i_target_vector(floor_wide-1 downto 0);
					elsif i_target_vector(floor_wide-1 downto 0) < i_target_floor then
						i_target_floor <= i_target_vector(floor_wide-1 downto 0);
						i_dir <= down;
					end if;
				end if;
				
				d_target_vector <= set_target(top_floor, down, down_array);
				if d_target_vector(floor_wide) = '0' then
					if i_status = '1' then
						i_status <= '0';
						i_target_floor <= d_target_vector(floor_wide-1 downto 0);
					elsif i_target_vector(floor_wide-1 downto 0) <= i_target_floor then
						i_target_floor <= d_target_vector(floor_wide-1 downto 0);
						i_dir <= up;
					end if;
				end if;
				
				
				if i_status = '0' then
					if i_stop_map(to_integer(i_current_floor)) = '1' or
					   down_array(to_integer(i_current_floor)) = '1' then
						next_state <= door_open;
					
					elsif i_target_floor < i_current_floor then
						i_next_floor <= i_current_floor - 1;
					
					elsif i_target_floor > i_current_floor then
						next_state <= up;
					end if;
				else
					next_state <= idle;
				end if;
			
			when door_open =>
				if i_dir = up then
					if up_array(to_integer(i_current_floor)) = '1' then
						i_req_ack <= '1';
					end if;
					next_state <= up;
				
				elsif i_dir = down then
					if down_array(to_integer(i_current_floor)) = '1' then
						i_req_ack <= '1';
					end if;
					next_state <= down;
					
				elsif i_door = '1' then
					next_state <= door_open;
					
				else
					next_state <= idle;
				end if;
				
			end case;
		end process;
	
	Oput : process(state, i_dir, i_req_ack, i_current_floor, i_target_floor, i_stop_map, i_door, i_status) begin
		door <= '0';
		current_floor <= i_current_floor;
		stop_map <= i_stop_map;
		door_state <= '0';
		dir <= i_dir;
		req_ack <= i_req_ack;
		current_state <= idle;
		case state is
			when idle =>
			when up =>
				current_state <= up;
			when down =>
				current_state <= down;
			when door_open =>
				current_state <= door_open;
				door_state <= '1';
				door <= '1';
		end case;
	end process;
end;			