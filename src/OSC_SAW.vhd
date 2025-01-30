library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity OSC_SAW is
    Port ( 
        CLK       : in  STD_LOGIC;
        RESET     : in  STD_LOGIC;
        FREQ_CTRL : in  STD_LOGIC_VECTOR(13 downto 0); -- range di frequenze tra 1 e 16KHz
        SAW_OUT   : out STD_LOGIC_VECTOR(9 downto 0)
    );
end OSC_SAW;

architecture Behavioral of OSC_SAW is
    signal phase_accumulator : unsigned(31 downto 0) := (others => '0');
    signal freq_step        : unsigned(31 downto 0);
    
    -- Constants for frequency calculation
    constant CLOCK_FREQ : real := 50_000_000.0;  -- 50MHz

begin
    freq_step <= to_unsigned(
        ((to_integer(unsigned(FREQ_CTRL))) * 86),  -- Range di frequenza regolabile
        freq_step'length
    );

    process(CLK, RESET)
    begin
        if RESET = '1' then
            phase_accumulator <= (others => '0');
        elsif rising_edge(CLK) then
            phase_accumulator <= phase_accumulator + freq_step;
        end if;
    end process;

    SAW_OUT <= std_logic_vector(phase_accumulator(31 downto 22));

end Behavioral;