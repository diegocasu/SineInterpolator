library IEEE;
use IEEE.std_logic_1164.all;

entity Complementer is
    generic (Nbit : positive);  -- Number of bits in input
    port (
        enable : in std_logic;  -- Active high enable signal
        input : in std_logic_vector (Nbit - 1 downto 0);
        output : out std_logic_vector (Nbit - 1 downto 0)
    );
end Complementer;

architecture Behaviour of Complementer is
begin

    compl_process: process(enable, input)
    begin
        if enable = '1' then
            output <= not(input);  -- Bit-wise complement of the input if enable is active
        else
            output <= input;
        end if;
    end process;

end Behaviour;