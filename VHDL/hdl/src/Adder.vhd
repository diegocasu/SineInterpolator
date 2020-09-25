library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Adder is
    generic (Nbit : positive);
    port (
        x : in std_logic_vector (Nbit - 1 downto 0);
        y : in std_logic_vector (Nbit - 1 downto 0);
        output : out std_logic_vector (Nbit downto 0)
    );
end Adder;

architecture Behaviour of Adder is
begin

    output <= std_logic_vector(unsigned('0' & x) + unsigned('0' & y));

end Behaviour;