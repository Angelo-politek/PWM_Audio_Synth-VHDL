library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity OSC_SQUARE is
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        FREQ_CTRL    : in  STD_LOGIC_VECTOR(13 downto 0);
        SQUARE_OUT   : out STD_LOGIC_VECTOR(9 downto 0)
    );
end OSC_SQUARE;

architecture Behavioral of OSC_SQUARE is
    signal phase_accumulator : unsigned(31 downto 0) := (others => '0');
    signal freq_step         : unsigned(31 downto 0);

    -- Costante per il clock di riferimento
    constant CLOCK_FREQ : integer := 50_000_000;

begin
    -- Calcolo del passo di fase proporzionale alla frequenza desiderata
    freq_step <= to_unsigned(
        ((to_integer(unsigned(FREQ_CTRL))) * 86),  -- Range di frequenza regolabile
        freq_step'length
    );

    -- Processo per aggiornare l'accumulatore di fase
    process(CLK, RESET)
    begin
        if RESET = '1' then
            phase_accumulator <= (others => '0');
        elsif rising_edge(CLK) then
            phase_accumulator <= phase_accumulator + freq_step;
        end if;
    end process;

    -- Generazione dell'onda quadra
    process(phase_accumulator)
    begin
        if phase_accumulator(31) = '1' then
            SQUARE_OUT <= (others => '1');  -- Livello alto
        else
            SQUARE_OUT <= (others => '0');  -- Livello basso
        end if;
    end process;

end Behavioral;
