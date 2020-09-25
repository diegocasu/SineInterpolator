library IEEE;
use IEEE.std_logic_1164.all;

entity DFlipFlop_tb is
end DFlipFlop_tb;

architecture Test of DFlipFlop_tb is
    
    constant T_CLOCK : time := 10 ns;
    constant T_RESET : time := 20 ns;
    constant N_BIT : positive := 3;   -- Number of bits to store in the flip-flop

    signal clock_tb : std_logic := '0';
    signal reset_tb : std_logic := '1';
    signal input_tb : std_logic_vector (N_BIT - 1 downto 0) := "111";
    signal output_tb : std_logic_vector (N_BIT - 1 downto 0);

    signal end_sim : std_logic := '0';  -- Active high signal to terminate the simulation

    
    component DFlipFlop is
        generic (Nbit : positive); -- Number of bits to store in the flip-flop
        port (
            reset : in std_logic;  -- Active high asynchronous reset
            clock : in std_logic;
            input : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector (Nbit - 1 downto 0)
        );
    end component;

begin

    reset_tb <= '0' after T_RESET;
    clock_tb <= (not(clock_tb) or end_sim) after T_CLOCK/2;
    end_sim <= '1' after 10*T_CLOCK;

    dff: DFlipFlop
        generic map (Nbit => N_BIT)
        port map (
            reset => reset_tb,
            clock => clock_tb,
            input => input_tb,
            output => output_tb
        );

    test_process: process(reset_tb, clock_tb)
        variable counter : natural := 0;
        begin
            if reset_tb  = '1' then
                input_tb <= "000";
            elsif rising_edge(clock_tb) then
                case counter is
                    when 0 => input_tb <= "011";
                    when 1 => input_tb <= "001";
                    when 3 => input_tb <= "000";
                    when others => null;
                end case;
                counter := counter + 1;
            end if;
        end process;

end Test;
