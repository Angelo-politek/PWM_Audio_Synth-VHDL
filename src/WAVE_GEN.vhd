library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WAVE_GEN is
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        FREQ_CTRL    : in  STD_LOGIC_VECTOR(7 downto 0);
        SEL          : in  STD_LOGIC_VECTOR(1 downto 0);
        AUDIO_SAMPLE : out STD_LOGIC_VECTOR(9 downto 0)
    );
end WAVE_GEN;

architecture Behavioral of WAVE_GEN is
    -- Phase accumulator a 32 bit per una risoluzione migliore
    signal phase : unsigned(31 downto 0) := (others => '0');
    signal wave_out : unsigned(9 downto 0) := (others => '0');
    
    -- Costante per il calcolo della frequenza (50MHz clock)
    constant CLOCK_FREQ : integer := 50_000_000;
    -- Il passo di fase è calcolato come: (2^32 * desired_freq) / clock_freq
    signal freq_step : unsigned(31 downto 0);
begin
    -- Calcolo del passo di fase
    freq_step <= to_unsigned(
        (to_integer(unsigned(FREQ_CTRL)) * 1000),  -- Range da 0 a 255kHz
        freq_step'length
    );

    -- Processo accumulatore di fase
    process(CLK, RESET)
    begin
        if RESET = '1' then
            phase <= (others => '0');
        elsif rising_edge(CLK) then
            phase <= phase + freq_step;
        end if;
    end process;

    -- Generazione forme d'onda
    process(phase, SEL)
    begin
        case SEL is
            when "00" => -- Silenzio
                wave_out <= (others => '0');
                
            when "01" => -- Onda quadra
                if phase(31) = '1' then
                    wave_out <= "1111111111";
                else
                    wave_out <= "0000000000";
                end if;
                
            when "10" => -- Dente di sega
                wave_out <= phase(31 downto 22);
                
            when others => -- Triangolare
                if phase(31) = '0' then
                    -- Rampa ascendente - scala da 0 a 1023
                    wave_out <= '0' & phase(30 downto 22);  -- Prende 9 bit e aggiunge uno zero in testa
                else
                    -- Rampa discendente - scala da 1023 a 0
                    wave_out <= '1' & (not phase(30 downto 22));  -- Prende 9 bit negati e aggiunge un uno in testa
                end if;
        end case;
    end process;

    AUDIO_SAMPLE <= std_logic_vector(wave_out);
end Behavioral;
