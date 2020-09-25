library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Subtractor is
    generic (Nbit : positive);
    port (
        reset : in std_logic;
        clock : in std_logic;
        x : in std_logic_vector (Nbit - 1 downto 0);
        y : in std_logic_vector (Nbit - 1 downto 0);
        output : out std_logic_vector (Nbit downto 0)
    );
end Subtractor;

architecture Behaviour of Subtractor is
begin


    sub_process: process(reset, clock)
    begin
        if reset = '1' then
            output <= (others => '0');
        elsif rising_edge(clock) then
            output <= std_logic_vector(unsigned('0' & x) - unsigned('0' & y));
        end if;
    end process;
    

end Behaviour;
