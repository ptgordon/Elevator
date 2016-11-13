LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity elevator_unit is
generic (
	floor_wide : positive;
	stop_wide : positive;
	top_floor :positive   -- what is the max value of the counter ( modulus )
	);
port (
	clk,
	reset,
	load_request,
	door_open,
	state_shift: in	std_logic; -- system clock
	request_floor : in std_logic_vector(floor_wide-1 downto 0);
	door : out std_logic_vector;
	dir : out std_logic_vector(1 downto 0);
	current_floor,
	target_floor: out std_logic_vector(floor_wide-1 downto 0);
	stop_map	: out std_logic_vector(stop_wide downto 0)
	);
end;

architecture elevator_unit1 of elevator_unit is
subtype elevator_state is std_logic_vector(1 downto 0);
constant idle := "00";
constant up := "01";
constant down := "10";
constant door_open := "11";
signal state, next_state: elevator_state;
signal i_door std_logic := '0';
signal i_dir std_logic_vector(1 downto 0);
signal i_current_floor, i_target_floor std_logic_vector(floor_wide-1 downto 0);
signal i_stop_map std_logic_vector(stop_wide downto 0);
function set_target(
	top_floor : positive;
	direction : std_logic_vector;
	stop_map : std_logic_vector
	) return std_logic_vector is
	signal target_vector : std_logic_vector
	begin
		target_vector := (others => '0');
		target_vector(floor_wide) := '1';
		for i in 0 to top_floor loop
			if stop_map(i) = '1' then
				target_vector = i;
				if direction = "10" then
					exit;
				end if;
			end if;
		return target_vector;
	end set_target;
	

StateMem: process (clk) begin
	if(rising_edge(clk)) begin
		if (reset = '1') then
			state <= idle;
		else
			state <= next_state;
		end if;
	end if;
end process;

NS: process(state)begin
	case state is
		when idle =>
		when up =>
		when down =>
		when door_open =>
	end;
	
Oput : process(state) begin
	case state is
		when idle =>
		when up =>
		when down =>
		when door_open =>
	end;
			