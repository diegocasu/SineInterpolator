library IEEE;
use IEEE.std_logic_1164.all;

entity Adder_tb is
end Adder_tb;

architecture Test of Adder_tb is
    
    constant N_BIT : positive := 4;   -- Number of bits of the inputs

    signal x_tb : std_logic_vector (N_BIT - 1 downto 0) := "1001";
    signal y_tb : std_logic_vector (N_BIT - 1 downto 0) := "1111";
    signal output_tb : std_logic_vector (N_BIT downto 0);


    component Adder is
        generic (Nbit : positive);
        port (
            x : in std_logic_vector (Nbit - 1 downto 0);
            y : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector (Nbit downto 0)
        );
    end component;

begin

    add: Adder
        generic map (Nbit => N_BIT)
        port map (
            x => x_tb,
            y => y_tb,
            output => output_tb
        );

end Test;
