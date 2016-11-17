LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity elevator_cortex is
generic (
	floors : positive;
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
	up_array, down_array : out std_logic_vector(floors downto 0)
	);
end;

architecture elevator_cortex1 of elevator_cortex is
	constant up : std_logic_vector(1 downto 0) := "01";
	constant down : std_logic_vector(1 downto 0) := "10";
	begin
		
	call_control: process(clk,elevator_ready) begin
		if rising_edge(clk) then
			if elevator_ready /= (others => '0') then
				for i in 0 to elevators-1 loop
					if elevator_ready(i) = '1' then
						if dir_array(i*2+1 downto i*2) = up then
							up_array(to_integer(floor_array((i+1)*floor_width-1 downto i*floor_width)))<='0';
						elsif dir_array(i*2+1 downto i*2) = down then
							down_array(to_integer(floor_array((i+1)*floor_width-1 downto i*floor_width)))<='0';
						end if;
					end if;
				end loop;
			end if;
			
			if up_button = '0' then
				up_array(to_integer(call_floor)) <= '1';
			end if;
				
			if down_button = '0' then
				down_array(to_integer(call_floor)) <= '1';
			end if;
		end if;
	end process;
end;	