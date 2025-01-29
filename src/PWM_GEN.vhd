-- PWM_GEN.vhd
-- Generatore di segnale audio PWM con risoluzione a 10 bit
-- Frequenza del PWM > 48.8 KHz


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_GEN is
    Port (
        CLK         : in  STD_LOGIC;
        RESET       : in  STD_LOGIC;
        AUDIO_SAMPLE: in  STD_LOGIC_VECTOR(9 downto 0); -- Valore di 10 bit
        PWM_OUT     : out STD_LOGIC
    );
end PWM_GEN;

architecture Behavioral of PWM_GEN is
    signal counter      : unsigned(9 downto 0) := (others => '0'); -- Contatore a 10 bit
    signal pwm_threshold: unsigned(9 downto 0); -- Soglia PWM
begin
    -- Assegna il valore dell'input AUDIO_SAMPLE al segnale pwm_threshold
    process(CLK, RESET)
    begin
        if RESET = '1' then
            pwm_threshold <= (others => '0');
        elsif rising_edge(CLK) then
            pwm_threshold <= unsigned(AUDIO_SAMPLE);
        end if;
    end process;

    -- Contatore PWM
    process(CLK, RESET)
    begin
        if RESET = '1' then
            counter <= (others => '0');
        elsif rising_edge(CLK) then
            if counter = "1111111111" then -- Massimo valore del contatore a 10 bit (1023)
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Generazione del segnale PWM
    PWM_OUT <= '1' when counter < pwm_threshold else '0';

end Behavioral;
