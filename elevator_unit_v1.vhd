LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity elevator_unit_v1 is
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
end;

architecture elevator_unit_v1_1 of elevator_unit_v1 is
	subtype elevator_state is std_logic_vector(1 downto 0);
	constant idle : std_logic_vector(1 downto 0) := "00";
	constant up : std_logic_vector(1 downto 0) := "01";
	constant down : std_logic_vector(1 downto 0) := "10";
	constant door_open : std_logic_vector(1 downto 0) := "11";
	constant check_bit : positive := 1;
	signal state, 
			 next_state: elevator_state := idle;
	signal door_state,
			 i_door, 
			 i_req_ack : std_logic := '0';
	signal prev_dir, i_dir : std_logic_vector(1 downto 0):= "00";
	signal i_current_floor,
			 i_next_floor,
			 prev_next_floor: unsigned(floor_wide-1 downto 0) := (others => '0');
	signal i_stop_map,
			 i_stop_mask,
			 prev_stop_map: unsigned(top_floor downto 0):=(others => '0'); 
	begin
	
	generate_map: process (clk) begin
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
					i_door <= '0';
					i_current_floor <= i_next_floor;
					state <= next_state;
				end if;
			end if;
		end if;
	end process;
				
	avoid_latch: process (clk) begin
		if (rising_edge(clk)) then
			prev_next_floor <= i_next_floor;
			prev_dir <= i_dir;
		end if;
	end process;

	NS: process (state, prev_dir, i_stop_map, i_dir, i_stop_mask, i_door, prev_next_floor, up_array, i_current_floor, down_array) begin
		next_state <= state;
		i_dir <= prev_dir;
		i_next_floor <= prev_next_floor;
		i_req_ack <= '0';
		i_stop_mask <= (others=> '0');
		i_stop_mask(to_integer(i_current_floor)-1 downto 0) <= (others => '1');
		case state is
			when idle =>
				i_dir <= idle;
				if i_door = '1' then
					next_state <= door_open;
						
				elsif i_stop_map(to_integer(i_current_floor)) = '1' then
					next_state <= door_open;
				
				elsif up_array(to_integer(i_current_floor)) = '1' then
					i_dir <= up;
					next_state <= door_open;
					
				elsif down_array(to_integer(i_current_floor)) = '1' then
					i_dir <= down;
					next_state<= door_open;
				
				elsif (i_stop_map /= 0 and i_stop_map < i_stop_mask) or 
				      (up_array /= 0 and up_array < i_stop_mask) or 
						(down_array /= 0 and down_array < i_stop_mask) then
					next_state <= down; 
				
				elsif i_stop_map /= 0 or up_array /= 0 or down_array /= 0 then
					next_state <= up;
					
				else
					next_state <= idle;
				end if;
				
			when up =>
				i_dir <= up;
				
				if i_stop_map(to_integer(i_current_floor)) = '1' or
					up_array(to_integer(i_current_floor)) = '1' then
					next_state <= door_open; 
				
				elsif i_stop_map > i_stop_mask or 
						up_array > i_stop_mask or 
						down_array > (i_stop_mask + (to_unsigned(check_bit, top_floor) sll to_integer(i_current_floor)) then
					i_next_floor <= i_current_floor + 1;
					
				elsif (i_stop_map /= 0) or 
				      (up_array /= 0) or 
						(down_array /= 0) then
					next_state <= down; 
				
				else
					next_state <= idle;
				end if;
					
			when down =>
				i_dir <= down;
				
				if i_stop_map(to_integer(i_current_floor)) = '1' or
					down_array(to_integer(i_current_floor)) = '1' then
					next_state <= door_open;
				
				elsif ((i_stop_map and i_stop_mask) /= 0) or 
						((down_array and i_stop_mask) /= 0) or
						((up_array and i_stop_mask) /= 0) then
					i_next_floor <= i_current_floor-1;
				
				elsif i_stop_map /= 0 or up_array /= 0 or down_array /= 0 then
					next_state <= up;
				
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
	
	Oput : process(i_current_floor, i_req_ack, state, i_dir, i_stop_map) begin
		dir <= i_dir;
		door <= '0';
		current_floor <= i_current_floor;
		stop_map <= i_stop_map;
		door_state <= '0';
		req_ack <= i_req_ack;
		case state is
			when idle =>
				current_state <= idle;
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