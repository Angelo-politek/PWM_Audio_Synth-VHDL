library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WAVE_GEN is
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        FREQ_CTRL    : in  STD_LOGIC_VECTOR(13 downto 0);  -- frequenza regolabile nel range 1-16KHz
        SEL          : in  STD_LOGIC_VECTOR(1 downto 0);
        AUDIO_SAMPLE : out STD_LOGIC_VECTOR(9 downto 0)
    );
end WAVE_GEN;

architecture Behavioral of WAVE_GEN is
    -- Segnali per le uscite degli oscillatori
    signal saw_out     : STD_LOGIC_VECTOR(9 downto 0);
    signal square_out  : STD_LOGIC_VECTOR(9 downto 0);
    signal tri_out     : STD_LOGIC_VECTOR(9 downto 0);

    -- Componenti degli oscillatori
    component OSC_SAW
        Port (
            CLK       : in  STD_LOGIC;
            RESET     : in  STD_LOGIC;
            FREQ_CTRL : in  STD_LOGIC_VECTOR(13 downto 0);
            SAW_OUT   : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

    component OSC_SQUARE
        Port (
            CLK       : in  STD_LOGIC;
            RESET     : in  STD_LOGIC;
            FREQ_CTRL : in  STD_LOGIC_VECTOR(13 downto 0);
            SQUARE_OUT: out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

    component OSC_TRI
        Port (
            CLK       : in  STD_LOGIC;
            RESET     : in  STD_LOGIC;
            FREQ_CTRL : in  STD_LOGIC_VECTOR(13 downto 0);
            TRI_OUT   : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

begin
    -- Istanziazione degli oscillatori
    saw_inst: OSC_SAW
        port map (
            CLK       => CLK,
            RESET     => RESET,
            FREQ_CTRL => FREQ_CTRL,
            SAW_OUT   => saw_out
        );

    square_inst: OSC_SQUARE
        port map (
            CLK       => CLK,
            RESET     => RESET,
            FREQ_CTRL => FREQ_CTRL,
            SQUARE_OUT=> square_out
        );

    tri_inst: OSC_TRI
        port map (
            CLK       => CLK,
            RESET     => RESET,
            FREQ_CTRL => FREQ_CTRL,
            TRI_OUT   => tri_out
        );

    -- Selezione della forma d'onda
    process(SEL, saw_out, square_out, tri_out)
    begin
        case SEL is
            when "00" =>  -- Silenzio
                AUDIO_SAMPLE <= (others => '0');
            when "01" =>  -- Onda quadra
                AUDIO_SAMPLE <= square_out;
            when "10" =>  -- Dente di sega
                AUDIO_SAMPLE <= saw_out;
            when others =>  -- Triangolare
                AUDIO_SAMPLE <= tri_out;
        end case;
    end process;

end Behavioral;

