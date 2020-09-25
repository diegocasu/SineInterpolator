library IEEE;
use IEEE.std_logic_1164.all;

entity DFlipFlop is
    generic (Nbit : positive); -- Number of bits to store in the flip-flop
    port (
        reset : in std_logic;  -- Active high asynchronous reset
        clock : in std_logic;
        input : in std_logic_vector (Nbit - 1 downto 0);
        output : out std_logic_vector (Nbit - 1 downto 0)
    );
end DFlipFlop;

architecture Behaviour of DFlipFlop is
begin

    dff_process: process(reset, clock)
    begin
        if reset = '1' then
            output <= (others => '0');
        elsif rising_edge(clock) then
            output <= input;
        end if;
    end process;

end Behaviour;
