library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LSB_Converter is
    generic (Nbit : positive);  -- Number of bits of the input
    port (
        input : in std_logic_vector (Nbit - 1 downto 0);
        output : out std_logic_vector ((Nbit + 13) downto 0)  -- Output on Nbit + 14 bits.
    );
end LSB_Converter;

architecture Behaviour of LSB_converter is

    -- Converting ratio LSB_start/LSB_end = 1/LSB_input = 10430.
    constant LSB_ratio : std_logic_vector (13 downto 0) := "10100010111110"; 

begin

    -- LSB conversion done scaling by a constant pre-established factor.
    output <= std_logic_vector(unsigned(input)*unsigned(LSB_ratio));

end Behaviour;