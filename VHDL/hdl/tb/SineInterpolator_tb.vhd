library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SineInterpolator_tb is
end SineInterpolator_tb;

architecture Test of SineInterpolator_tb is
    
    constant T_CLOCK : time := 10 ns;
    constant T_RESET : time := 20 ns;

    signal clock_tb : std_logic := '0';
    signal reset_tb : std_logic := '1';
    signal input_tb : std_logic_vector (15 downto 0);
    signal output_interpolator_tb : std_logic_vector (23 downto 0);
    signal output_rom_tb : std_logic_vector (23 downto 0);
    signal output_dff_tb : std_logic_vector (23 downto 0);

    -- Difference between the output of the interpolator and the output of the ROM.
    -- Used to check if they are equal (all bits are 0) or not.
    signal difference_tb : std_logic_vector (24 downto 0);

    signal end_sim : std_logic := '0';  -- Active high signal to terminate the simulation

    
    component SineInterpolator is
        port (
            clock : in std_logic;
            reset : in std_logic;   -- Active high asynchronous reset
            input : in std_logic_vector (15 downto 0);
            output : out std_logic_vector (23 downto 0)
        );
    end component;

    -- ROM used to store the outputs of the SineInterpolator simulated in Python.
    component ROM_Test is
        port (
            reset : in std_logic;
            clock : in std_logic;
            address : in std_logic_vector (15 downto 0);
            data : out std_logic_vector (23 downto 0)
        );
    end component;

    -- Flip-flop used to store the output of the ROM. It works as a delay component
    -- synchronizing the outputs of the interpolator and of the ROM for a correct comparation.
    component DFlipFlop is
        generic (Nbit : positive); -- Number of bits to store in the flip-flop
        port (
            reset : in std_logic;  -- Active high asynchronous reset
            clock : in std_logic;
            input : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector (Nbit - 1 downto 0)
        );
    end component;

    -- Compares the output of the interpolator and the output of the ROM.
    -- The subtractor is synchronous, so that the output is stable and
    -- its eventual transitions can be checked easily with the simulation tools.
    component Subtractor is
        generic (Nbit : positive);
        port (
            reset : in std_logic;
            clock : in std_logic;
            x : in std_logic_vector (Nbit - 1 downto 0);
            y : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector (Nbit downto 0)
        );
    end component;


begin

    reset_tb <= '0' after T_RESET;
    clock_tb <= (not(clock_tb) or end_sim) after T_CLOCK/2;

    sine_interpolator: SineInterpolator
        port map (
            clock => clock_tb,
            reset => reset_tb,
            input => input_tb,
            output => output_interpolator_tb
        );

    rom: ROM_Test
        port map (
            reset => reset_tb,
            clock => clock_tb,
            address => input_tb,
            data => output_rom_tb
        );

    dff: DFlipFlop
        generic map (Nbit => 24)
        port map (
            reset => reset_tb,
            clock => clock_tb,
            input => output_rom_tb,
            output => output_dff_tb
        );

    sub: Subtractor
        generic map (Nbit => 24)
        port map (
            clock => clock_tb,
            reset => reset_tb,
            x => output_interpolator_tb,
            y => output_dff_tb,
            output => difference_tb
        );


    test_proc: process(reset_tb, clock_tb)
        variable count : natural := 0;
        begin
            if reset_tb = '1' then
                input_tb <= (others => '0');
            elsif rising_edge(clock_tb) then
                count := count + 1;
		input_tb <= std_logic_vector(unsigned(input_tb) + 1);
                
                if count = 2**16 then
                    end_sim <= '1';
                end if;
            end if;
        end process;

end Test;
