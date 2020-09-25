library IEEE;
use IEEE.std_logic_1164.all;

entity SineInterpolator is
    port (
        clock : in std_logic;
        reset : in std_logic;   -- Active high asynchronous reset
        input : in std_logic_vector (15 downto 0);
        output : out std_logic_vector (23 downto 0)
    );
end SineInterpolator;

architecture Behaviour of SineInterpolator is

    ----------- SIGNALS -----------

    -- Output of the flip-flop saving the sign bit. 
    -- It is a vector due to the general structure of the flip-flop.
    signal sign : std_logic_vector (0 downto 0);

    -- Output of the complementer.
    signal out_complementer : std_logic_vector (13 downto 0);

    -- Output of the ROMs.
    signal out_rom1 : std_logic_vector (7 downto 0);
    signal out_rom2 : std_logic_vector (7 downto 0);

    -- Output of the flip-flop saving the less significant bits of the output of the complementer.
    -- They will be multiplied by the output of ROM 1.
    signal low_out_complementer : std_logic_vector (3 downto 0);

    -- Output of the multiplier. The extended version is used as input of the adder.
    signal out_multiplier : std_logic_vector (11 downto 0);
    signal out_multiplier_extended : std_logic_vector (21 downto 0);

    -- Output of the LSB converter.
    signal out_LSB_converter : std_logic_vector (21 downto 0);

    -- Output of the adder.
    signal out_adder : std_logic_vector (22 downto 0);

    -- Signal for the final result (combination of sign and out_adder).
    -- It will be the input of the flip-flop providing the output.
    signal sine : std_logic_vector (23 downto 0);


    ----------- COMPONENTS -----------
 
    component DFlipFlop is
        generic (Nbit : positive); -- Number of bits to store in the flip-flop
        port (
            reset : in std_logic;  -- Active high asynchronous reset
            clock : in std_logic;
            input : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector (Nbit - 1 downto 0)
        );
    end component;

    component Complementer is
        generic (Nbit : positive);  -- Number of bits in input
        port (
            enable : in std_logic;  -- Active high enable signal
            input : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector (Nbit -1 downto 0)
        );
    end component;

    component ROM_1 is
        port (
            reset : in std_logic;
            clock : in std_logic;
            address : in std_logic_vector (9 downto 0);
            data : out std_logic_vector (7 downto 0)
        );
    end component;

    component ROM_2 is
        port (
            reset : in std_logic;
            clock : in std_logic;
            address : in std_logic_vector (9 downto 0);
            data : out std_logic_vector (7 downto 0)
        );
    end component;

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

    component LSB_Converter is
        generic (Nbit : positive);  -- Number of bits of the input
        port (
            input : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector ((Nbit + 13) downto 0)  -- Output on Nbit + 14 bits.
        );
    end component;

    component Adder is
        generic (Nbit : positive);
        port (
            x : in std_logic_vector (Nbit - 1 downto 0);
            y : in std_logic_vector (Nbit - 1 downto 0);
            output : out std_logic_vector (Nbit downto 0)
        );
    end component;


    ----------- WIRING AND BEHAVIOUR -----------

begin

    -- Flip-flop saving the sign bit sampled directly from the input.
    sign_dff: DFlipFlop
        generic map (Nbit => 1)
        port map (
            reset => reset,
            clock => clock,
            input => input(15 downto 15),
            output => sign
        );

    -- Complementer implementing the phase shifting from [pi/2, pi] to [0, pi/2], if enabled.
    compl: Complementer
        generic map (Nbit => 14)  -- Number of bits in input
        port map (
            enable => input(14),
            input => input(13 downto 0),
            output => out_complementer
        );

    -- ROMs implementing the lookup tables storing the pre-computed values for the sine interpolation.
    -- Addressed by the 10 most significant bits of the output of the complementer.
    rom1: ROM_1
        port map (
            reset => reset,
            clock => clock,
            address => out_complementer(13 downto 4),
            data => out_rom1
        );

    rom2: ROM_2
        port map (
            reset => reset,
            clock => clock,
            address => out_complementer(13 downto 4),
            data => out_rom2
        );

    -- Flip-flop storing the 4 less significant bits of the output of the complementer.
    low_out_compl_dff: DFlipFlop
        generic map (Nbit => 4)
        port map (
            reset => reset,
            clock => clock,
            input => out_complementer(3 downto 0),
            output => low_out_complementer
        );

    -- Multiplication between the output of ROM 1 and the less significant bits of the output of the complementer.
    mul: Multiplier
        generic map (
            N_bit_input_x => 4,
            N_bit_input_y => 8
        )
        port map (
            x => low_out_complementer,
            y => out_rom1,
            output => out_multiplier
        );

    -- LSB conversion of the output of ROM 2 to use an LSB equal to LSB_INPUT*LSB_ROM.
    lsb_conv: LSB_Converter
        generic map (Nbit => 8)
        port map (
            input => out_rom2,
            output => out_lsb_converter
        );

    -- Sum of the output of the LSB converter, i.e. the output of ROM 2, and the output of the multiplier.
    add: Adder
        generic map (Nbit => 22)
        port map (
            x => out_multiplier_extended,
            y => out_lsb_converter,
            output => out_adder
        );

    -- Flip-flop storing the final result.
    dff_output: DFlipFlop
        generic map (Nbit => 24)
        port map (
            reset => reset,
            clock => clock,
            input => sine,
            output => output
        );

    -- Extension of the output of the multiplier to 22 bits from the starting 12 bits.
    out_multiplier_extended <= "0000000000" & out_multiplier;

    -- Merging of the sign and magnitude signals to generate the sine signal.
    sine <= sign & out_adder;
    

end Behaviour;