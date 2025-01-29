-- ENVELOPE_GEN.vhd
-- Generatore di envelope con attacco, decadimento e sustain
-- Controllo dell'attacco e del decadimento tramite segnali a 8 bit
-- Trigger di input 
-- Output envelope a 8 bit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ENVELOPE_GEN is
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        ATTACK_TIME  : in  STD_LOGIC_VECTOR(7 downto 0);
        DECAY_TIME   : in  STD_LOGIC_VECTOR(7 downto 0);
        TRIGGER      : in  STD_LOGIC;
        ENVELOPE_OUT : out STD_LOGIC_VECTOR(7 downto 0)
    );
end ENVELOPE_GEN;

architecture Behavioral of ENVELOPE_GEN is
    type STATE_TYPE is (IDLE, ATTACK, DECAY);
    signal state : STATE_TYPE := IDLE;
    signal envelope : unsigned(7 downto 0) := (others => '0');
    -- Contatore a 20 bit per divisione di clock più precisa
    signal counter : unsigned(19 downto 0) := (others => '0');
    -- Rate control per attack e decay
    signal attack_rate : unsigned(19 downto 0);
    signal decay_rate : unsigned(19 downto 0);
    -- Aggiunto segnale per trigger precedente
    signal prev_trigger : std_logic := '0';
begin
    -- Calcolo dei rate basati sui tempi di input
    -- Più alto è il valore di input, più lungo sarà il tempo
    attack_rate <= unsigned(ATTACK_TIME) & x"FFF";
    decay_rate <= unsigned(DECAY_TIME) & x"FFF";

    process(CLK, RESET)
    begin
        if RESET = '1' then
            state <= IDLE;
            envelope <= (others => '0');
            counter <= (others => '0');
            prev_trigger <= '0';
        elsif rising_edge(CLK) then
            -- Memorizza il trigger precedente
            prev_trigger <= TRIGGER;
            
            counter <= counter + 1;
            
            case state is
                when IDLE =>
                    -- Rileva fronte di salita del trigger
                    if TRIGGER = '1' and prev_trigger = '0' then
                        state <= ATTACK;
                        envelope <= (others => '0');
                        counter <= (others => '0');
                    end if;
                    
                when ATTACK =>
                    if counter >= attack_rate then
                        counter <= (others => '0');
                        if envelope /= x"FF" then
                            envelope <= envelope + 1;
                        end if;
                    end if;
                    -- Rileva fronte di discesa del trigger
                    if TRIGGER = '0' and prev_trigger = '1' then
                        state <= DECAY;
                        counter <= (others => '0');
                    -- Riavvia attack se arriva nuovo trigger durante decay
                    elsif TRIGGER = '1' and prev_trigger = '0' then
                        state <= ATTACK;
                        counter <= (others => '0');
                    end if;
                    
                when DECAY =>
                    if counter >= decay_rate then
                        counter <= (others => '0');
                        if envelope > 0 then
                            envelope <= envelope - 1;
                        else
                            state <= IDLE;
                        end if;
                    end if;
                    -- Riavvia attack se arriva nuovo trigger durante decay
                    if TRIGGER = '1' and prev_trigger = '0' then
                        state <= ATTACK;
                        counter <= (others => '0');
                    end if;
                    
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    ENVELOPE_OUT <= std_logic_vector(envelope);
end Behavioral;
