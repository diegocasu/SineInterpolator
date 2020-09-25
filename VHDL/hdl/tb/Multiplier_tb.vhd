library IEEE;
use IEEE.std_logic_1164.all;

entity Multiplier_tb is
end Multiplier_tb;

architecture Test of Multiplier_tb is
    
    constant N_BIT_INPUT_X : positive := 4;   -- Number of bits of the input
    constant N_BIT_INPUT_Y : positive := 8;  -- Number of bits of the output

    signal x_tb : std_logic_vector (N_BIT_INPUT_X - 1 downto 0) := "1101";
    signal y_tb : std_logic_vector (N_BIT_INPUT_Y - 1 downto 0) := "10101011";
    signal output_tb : std_logic_vector ((N_BIT_INPUT_X + N_BIT_INPUT_Y - 1) downto 0);


    component Multiplier is
        generic (
            N_bit_input_x : positive;
            N_bit_input_y : positive
        );
        port (
            x : in std_logic_vector (N_bit_input_x - 1 downto 0);
            y : in std_logic_vector (N_bit_input_y - 1 downto 0);
            output : out std_logic_vector ((N_bit_input_x + N_bit_input_y - 1) downto 0)
        );
    end component;

begin

    mul: Multiplier
        generic map (
            N_bit_input_x => N_BIT_INPUT_X,
            N_bit_input_y => N_BIT_INPUT_Y
        )
        port map (
            x => x_tb,
            y => y_tb,
            output => output_tb
        );

end Test;
