-- USER_INTERFACE.vhd
-- Interfaccia utente per il controllo del sintetizzatore audio
-- Controllo delle forme d'onda, della frequenza, dell'envelope e del volume
-- Menu di selezione per controllare i vari parametri


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity USER_INTERFACE is
    Port (
        CLOCK_50          : in  STD_LOGIC;
        SW           : in  STD_LOGIC_VECTOR(9 downto 0);
        KEY          : in  STD_LOGIC_VECTOR(1 downto 0);
        GPIO         : out  STD_LOGIC_VECTOR(1 downto 0);
        LEDR          : out STD_LOGIC_VECTOR(9 downto 0);
        HEX0        : out STD_LOGIC_VECTOR(0 to 6);
        HEX1        : out STD_LOGIC_VECTOR(0 to 6);
        HEX2        : out STD_LOGIC_VECTOR(0 to 6);
        HEX3        : out STD_LOGIC_VECTOR(0 to 6);
        HEX4        : out STD_LOGIC_VECTOR(0 to 6);
        HEX5        : out STD_LOGIC_VECTOR(0 to 6)
        -- i display HEX0-HEX5 sono in logica negata
    );
end USER_INTERFACE;

architecture Behavioral of USER_INTERFACE is

    signal AUDIO_SAMPLE : std_logic_vector(9 downto 0);
    signal AUDIO_OUT    : std_logic_vector(9 downto 0);
    signal ENV_OUT    : std_logic_vector(9 downto 0);
    signal FREQ        : std_logic_vector(7 downto 0);
    signal ATTACK : std_logic_vector(7 downto 0);
    signal DECAY : std_logic_vector(7 downto 0);
    signal WAVE : std_logic_vector(1 downto 0);
    signal VOLUME : std_logic_vector(7 downto 0);
    signal ENV : std_logic_vector(7 downto 0);
    signal DATA : std_logic_vector(7 downto 0);

    signal RST : std_logic;
    signal TRIG_KEY : std_logic;
    signal P_TRIG_KEY : std_logic;
    signal TRIG_VALUE : std_logic;
    signal MENU_KEY : std_logic;
    signal P_MENU_KEY : std_logic; 
    signal MENU_VALUE : std_logic;
    

    type STATE_TYPE is (SET_WAVE, SET_FREQ, SET_ATTACK, SET_DECAY, SET_VOLUME);
    signal CS : STATE_TYPE := SET_WAVE;



    component WAVE_GEN is
        Port (
            CLK          : in  STD_LOGIC;
            RESET        : in  STD_LOGIC;
            FREQ_CTRL    : in  STD_LOGIC_VECTOR(7 downto 0);
            SEL          : in  STD_LOGIC_VECTOR(1 downto 0);
            AUDIO_SAMPLE : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

    component ENVELOPE_GEN is
        Port (
            CLK          : in  STD_LOGIC;
            RESET        : in  STD_LOGIC;
            ATTACK_TIME  : in  STD_LOGIC_VECTOR(7 downto 0);
            DECAY_TIME   : in  STD_LOGIC_VECTOR(7 downto 0);
            TRIGGER      : in  STD_LOGIC;
            ENVELOPE_OUT    : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component AMP is
        Port (
            CLK          : in  STD_LOGIC;
            RESET        : in  STD_LOGIC;
            VOLUME       : in  STD_LOGIC_VECTOR(7 downto 0);
            AUDIO_IN     : in  STD_LOGIC_VECTOR(9 downto 0);
            AUDIO_OUT    : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

    component PWM_GEN is
        Port (
            CLK         : in  STD_LOGIC;
            RESET       : in  STD_LOGIC;
            AUDIO_SAMPLE: in  STD_LOGIC_VECTOR(9 downto 0);
            PWM_OUT     : out STD_LOGIC
        );
    end component;

    component DECODER is
        Port (
            CLK         : in  STD_LOGIC;
            RESET       : in  STD_LOGIC;
            DATA        : in  STD_LOGIC_VECTOR(7 downto 0);
            H0          : out STD_LOGIC_VECTOR(6 downto 0);
            H1          : out STD_LOGIC_VECTOR(6 downto 0);
            H2          : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;


    begin

        -- istanziazione dei componenti
        WAVE_GEN1 : WAVE_GEN
        port map (
            CLK => CLOCK_50,
            RESET => RST,
            FREQ_CTRL => FREQ,
            SEL => WAVE,
            AUDIO_SAMPLE => AUDIO_SAMPLE
        );

        ENVELOPE_GEN1 : ENVELOPE_GEN
        port map (
            CLK => CLOCK_50,
            RESET => RST,
            ATTACK_TIME => ATTACK,
            DECAY_TIME => DECAY,
            TRIGGER => TRIG_KEY,
            ENVELOPE_OUT => ENV
        );

        ENV_AMP : AMP
        port map (
            CLK => CLOCK_50,
            RESET => RST,
            VOLUME => ENV,
            AUDIO_IN => AUDIO_SAMPLE,
            AUDIO_OUT => ENV_OUT
        );

        VOLUME_AMP : AMP
        port map (
            CLK => CLOCK_50,
            RESET => RST,
            VOLUME => VOLUME,
            AUDIO_IN => ENV_OUT,
            AUDIO_OUT => AUDIO_OUT
        );

        PWM_GEN1 : PWM_GEN
        port map (
            CLK => CLOCK_50,
            RESET => RST,
            AUDIO_SAMPLE => AUDIO_OUT,
            PWM_OUT => GPIO(0)
        );

        DEC1 : DECODER
        port map (
            CLK => CLOCK_50,          
            RESET => RST,        
            DATA => DATA,         
            H0 => HEX0,         
            H1 => HEX1,        
            H2 => HEX2     
        );
        

    
        

        LEDR <= SW;
        RST <= SW(9);
        TRIG_KEY <= not(KEY(0));
        MENU_KEY <= not(KEY(1));

        -- processo per convertire il segnale gate del pulsante KEY(0) in un segnale di trigger
        process(CLOCK_50, RST)
        begin
            if RST = '1' then
                TRIG_VALUE <= '0';
                P_TRIG_KEY <= '0';
            elsif rising_edge(CLOCK_50) then
                if TRIG_KEY = '1' and P_TRIG_KEY = '0' then
                    TRIG_VALUE <= '1';
                elsif TRIG_KEY = '0' and P_TRIG_KEY = '1' then   
                    TRIG_VALUE <= '0';
                else 
                    TRIG_VALUE <= '0';
                end if;
                P_TRIG_KEY <= TRIG_KEY;
            end if;
        end process;

        

        -- processo per convertire il segnale gate del pulsante KEY(1) in un segnale di trigger
        process(CLOCK_50, RST)
        begin
            if RST = '1' then
                MENU_VALUE <= '0';
                P_MENU_KEY <= '0';
            elsif rising_edge(CLOCK_50) then
                if MENU_KEY = '1' and P_MENU_KEY = '0' then
                    MENU_VALUE <= '1';
                elsif MENU_KEY = '0' and P_MENU_KEY = '1' then   
                    MENU_VALUE <= '0';
                else 
                    MENU_VALUE <= '0';
                end if;
                P_MENU_KEY <= MENU_KEY;
            end if;
        end process;



        -- macchina a stati per il menu di selezione
        -- 0 = forma d'onda
        -- 1 = frequenza
        -- 2 = attack
        -- 3 = decay
        -- 4 = volume
        process (CLOCK_50, RST)
        begin
            if RST = '1' then
                CS <= SET_WAVE;
                FREQ <= "00000010";
                ATTACK <= "10000000";
                DECAY <= "10000000";
                WAVE <= (others => '0');
                VOLUME <= "10000000";
                DATA <= (others => '0');
                HEX5 <= "1111000"; -- Lettera "R"
                HEX4 <= "0100100"; -- Lettera "S"
                HEX3 <= "1110000"; -- Lettera "T"
            elsif rising_edge(CLOCK_50) then
                case CS is
                    when SET_WAVE =>
                        HEX5 <= "0000001"; -- Lettera "O"
                        HEX4 <= "0100100"; -- Lettera "S"
                        HEX3 <= "0110001"; -- Lettera "C"
                        DATA <= "000000" & WAVE;
                        if SW(8) = '1' then
                            WAVE <= SW(1 downto 0);
                        end if;
                        if MENU_VALUE = '1' then
                            CS <= SET_FREQ;
                        end if;
                    when SET_FREQ =>
                        HEX5 <= "0111000"; -- Lettera "F"
                        HEX4 <= "1111000"; -- Lettera "R"
                        HEX3 <= "0110000"; -- Lettera "E"
                        DATA <= FREQ;
                        if SW(8) = '1' then
                            FREQ <= SW(7 downto 0);
                        end if;
                        if MENU_VALUE = '1' then
                            CS <= SET_ATTACK;
                        end if;
                    when SET_ATTACK =>
                        HEX5 <= "0001000"; -- Lettera "A"
                        HEX4 <= "1110000"; -- Lettera "T"
                        HEX3 <= "1110000"; -- Lettera "T"
                        DATA <= ATTACK;
                        if SW(8) = '1' then
                            ATTACK <= SW(7 downto 0);
                        end if;
                        if MENU_VALUE = '1' then
                            CS <= SET_DECAY;
                        end if;
                    when SET_DECAY =>
                        HEX5 <= "1000010"; -- Lettera "D"
                        HEX4 <= "0110000"; -- Lettera "E"
                        HEX3 <= "0110001"; -- Lettera "C"
                        DATA <= DECAY;
                        if SW(8) = '1' then
                            DECAY <= SW(7 downto 0);
                        end if;
                        if MENU_VALUE = '1' then
                            CS <= SET_VOLUME;
                        end if;
                    when SET_VOLUME =>
                        HEX5 <= "1000001"; -- Lettera "V"
                        HEX4 <= "0000001"; -- Lettera "O"
                        HEX3 <= "1110001"; -- Lettera "L"
                        DATA <= VOLUME;
                        if SW(8) = '1' then
                            VOLUME <= SW(7 downto 0);
                        end if;
                        if MENU_VALUE = '1' then
                            CS <= SET_WAVE;
                        end if;
                    when others =>
                        CS <= SET_WAVE;
                end case;
            end if;


            
                    

            
        end process;


end Behavioral;