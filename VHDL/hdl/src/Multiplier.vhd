library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Multiplier is
    generic (
        N_bit_input_x : positive;
        N_bit_input_y : positive
    );
    port (
        x : in std_logic_vector (N_bit_input_x - 1 downto 0);
        y : in std_logic_vector (N_bit_input_y - 1 downto 0);
        output : out std_logic_vector ((N_bit_input_x + N_bit_input_y - 1) downto 0)
    );
end Multiplier;

architecture Behaviour of Multiplier is
begin

    output <= std_logic_vector(unsigned(x)*unsigned(y));

end Behaviour;
