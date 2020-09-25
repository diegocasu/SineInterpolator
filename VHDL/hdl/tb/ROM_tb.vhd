library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ROM_tb is
end ROM_tb;

architecture Test of ROM_tb is

    constant T_CLOCK : time := 10 ns;
    constant T_RESET : time := 20 ns;
    constant N_BIT_ADDRESS : positive := 10;
    constant N_BIT_DATA : positive := 8;

    signal clock_tb : std_logic := '0';
    signal reset_tb : std_logic := '1';
    signal end_sim : std_logic := '0';  -- Active high signal to end the simulation.

    -- Signals for ROM 1
    signal address_1_tb : std_logic_vector (N_BIT_ADDRESS - 1 downto 0) := "1111010100";
    signal data_1_tb : std_logic_vector (N_BIT_DATA - 1 downto 0);

    -- Signals for ROM 2
    signal address_2_tb : std_logic_vector (N_BIT_ADDRESS - 1 downto 0) := "1111010100";
    signal data_2_tb : std_logic_vector (N_BIT_DATA - 1 downto 0);


    component ROM_1 is
        port (
            reset : in std_logic;
            clock : in std_logic;
            address : in std_logic_vector (9 downto 0);
            data : out std_logic_vector (7 downto 0)
        );
    end component;

    component ROM_2 is
        port (
            address : in std_logic_vector (9 downto 0);
            data : out std_logic_vector (7 downto 0)
        );
    end component;


begin

    reset_tb <= '0' after T_RESET;
    clock_tb <= (not(clock_tb) or end_sim) after T_CLOCK/2;

    rom1: ROM_1
        port map (
            reset => reset_tb,
            clock => clock_tb,
            address => address_1_tb,
            data => data_1_tb
        );

    rom2: ROM_2
        port map (
            address => address_2_tb,
            data => data_2_tb
        );


    test_proc: process(reset_tb, clock_tb)
        variable count : natural := 0;
        begin
            if reset_tb = '1' then
                address_1_tb <= (others => '0');
                address_2_tb <= (others => '0');
            elsif rising_edge(clock_tb) then
                count := count + 1;
		address_1_tb <= std_logic_vector(unsigned(address_1_tb) + 1);
		address_2_tb <= std_logic_vector(unsigned(address_2_tb) + 1);

                if count = 2**N_BIT_ADDRESS then
                    end_sim <= '1';
                end if;
            end if;
        end process;

end Test;
