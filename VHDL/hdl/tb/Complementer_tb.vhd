library IEEE;
use IEEE.std_logic_1164.all;

entity Complementer_tb is
end Complementer_tb;

architecture Test of Complementer_tb is
    
    constant T_ENABLE : time := 10 ns;
    constant N_BIT : positive := 3;   -- Number of bits of the input

    signal enable_tb : std_logic := '0';
    signal input_tb : std_logic_vector (N_BIT - 1 downto 0) := "101";
    signal output_tb : std_logic_vector (N_BIT - 1 downto 0);

    signal end_sim : std_logic := '0';  -- Active high signal to terminate the simulation


    component Complementer is
        generic (Nbit : positive);  -- Number of bits in input
        port (
            enable : in std_logic;  -- Active high enable signal
            input : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector (Nbit - 1 downto 0)
        );
    end component;

begin

    enable_tb <= (not(enable_tb) and not(end_sim)) after T_ENABLE/2;
    end_sim <= '1' after 10*T_ENABLE;

    comp: Complementer
        generic map (Nbit => N_BIT)
        port map (
            enable => enable_tb,
            input => input_tb,
            output => output_tb
        );

end Test;
