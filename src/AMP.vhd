-- AMP.vhd
-- Amplificatore audio per segnali a 10 bit
-- Controllo del volume tramite un segnale a 8 bit
-- "11111111" = +0dB, "00000000" = -64dB


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity AMP is
    Port (
        CLK          : in  STD_LOGIC;                   -- Clock principale
        RESET        : in  STD_LOGIC;                   -- Reset
        VOLUME       : in  STD_LOGIC_VECTOR(7 downto 0); -- Controllo volume (8 bit)
        AUDIO_IN     : in  STD_LOGIC_VECTOR(9 downto 0); -- Segnale audio in ingresso (10 bit)
        AUDIO_OUT    : out STD_LOGIC_VECTOR(9 downto 0)  -- Segnale audio in uscita (10 bit)
    );
end AMP;


architecture Behavioral of AMP is
    signal volume_data : unsigned(7 downto 0);
    signal audio_in_data : unsigned(9 downto 0);
    signal audio_out_data : unsigned(9 downto 0);
    signal mult_result : unsigned(17 downto 0); -- 10 bit + 8 bit = 18 bit
begin
    volume_data <= unsigned(VOLUME);
    audio_in_data <= unsigned(AUDIO_IN);

    process(CLK, RESET)
    begin
        if RESET = '1' then
            audio_out_data <= (others => '0');
        elsif rising_edge(CLK) then
            -- Moltiplica il segnale audio per il volume (considerato come frazione)
            mult_result <= audio_in_data * volume_data;
            -- Prendi i bit più significativi del risultato, shiftando di 8 posizioni
            -- Questo effettivamente divide per 256 (2^8), scalando il volume tra 0 e 1
            audio_out_data <= mult_result(17 downto 8);
        end if;
    end process;

    AUDIO_OUT <= std_logic_vector(audio_out_data);
end Behavioral;