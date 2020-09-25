library IEEE;
use IEEE.std_logic_1164.all;

entity LSB_Converter_tb is
end LSB_Converter_tb;

architecture Test of LSB_Converter_tb is
    
    constant N_BIT : positive := 4;   -- Number of bits of the input

    signal input_tb : std_logic_vector (N_BIT - 1 downto 0) := "1101";
    signal output_tb : std_logic_vector ((N_BIT + 13) downto 0);


    component LSB_Converter is
        generic (Nbit : positive);
        port (
            input : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector ((Nbit + 13) downto 0)  -- Output on Nbit + 14 bits.
        );
    end component;

begin

    lsb_conv: LSB_Converter
        generic map (Nbit => N_BIT)
        port map (
            input => input_tb,
            output => output_tb
        );

end Test;