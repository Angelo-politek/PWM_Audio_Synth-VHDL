-- DECODER.vhd
-- Decodifica un segnale a 8 bit per visualizzarlo su 3 display a 7 segmenti
-- Nel formato decimale, range da 0 a 255

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DECODER is
    Port (
        CLK          : in  STD_LOGIC;                   -- Clock principale
        RESET        : in  STD_LOGIC;                   -- Reset
        DATA         : in  STD_LOGIC_VECTOR(7 downto 0); -- Dato da visualizzare (8 bit)
        H0         : out STD_LOGIC_VECTOR(0 to 6);    -- Display HEX0 (cifra unità)
        H1         : out STD_LOGIC_VECTOR(0 to 6);    -- Display HEX1 (cifra decine)
        H2         : out STD_LOGIC_VECTOR(0 to 6)     -- Display HEX2 (cifra centinaia)
    );
end DECODER;

architecture Behavioral of DECODER is
    signal data_int : unsigned(7 downto 0);
    signal unit : unsigned(3 downto 0);
    signal tens : unsigned(3 downto 0);
    signal hundreds : unsigned(3 downto 0);
begin
    data_int <= unsigned(DATA);

    -- Processo per convertire il valore binario in BCD
    process(data_int)
        variable temp : unsigned(7 downto 0);
        variable bcd : unsigned(11 downto 0);
    begin
        bcd := (others => '0');
        temp := data_int;
        
        -- Algoritmo Double Dabble
        for i in 0 to 7 loop
            -- Add 3 to columns if they are >= 5
            if bcd(3 downto 0) >= 5 then
                bcd(3 downto 0) := bcd(3 downto 0) + 3;
            end if;
            if bcd(7 downto 4) >= 5 then
                bcd(7 downto 4) := bcd(7 downto 4) + 3;
            end if;
            if bcd(11 downto 8) >= 5 then
                bcd(11 downto 8) := bcd(11 downto 8) + 3;
            end if;
            -- Shift left one position
            bcd := bcd(10 downto 0) & temp(7);
            temp := temp(6 downto 0) & '0';
        end loop;
        
        unit <= bcd(3 downto 0);
        tens <= bcd(7 downto 4);
        hundreds <= bcd(11 downto 8);
    end process;

    -- Decodifica 7 segmenti per ogni cifra
    process(unit, tens, hundreds)
    begin
        -- Decodifica unità
        case unit is
            when "0000" => H0 <= "0000001"; -- 0
            when "0001" => H0 <= "1001111"; -- 1
            when "0010" => H0 <= "0010010"; -- 2
            when "0011" => H0 <= "0000110"; -- 3
            when "0100" => H0 <= "1001100"; -- 4
            when "0101" => H0 <= "0100100"; -- 5
            when "0110" => H0 <= "0100000"; -- 6
            when "0111" => H0 <= "0001111"; -- 7
            when "1000" => H0 <= "0000000"; -- 8
            when "1001" => H0 <= "0000100"; -- 9
            when others => H0 <= "1111111"; -- off
        end case;

        -- Decodifica decine
        case tens is
            when "0000" => H1 <= "0000001"; -- 0
            when "0001" => H1 <= "1001111"; -- 1
            when "0010" => H1 <= "0010010"; -- 2
            when "0011" => H1 <= "0000110"; -- 3
            when "0100" => H1 <= "1001100"; -- 4
            when "0101" => H1 <= "0100100"; -- 5
            when "0110" => H1 <= "0100000"; -- 6
            when "0111" => H1 <= "0001111"; -- 7
            when "1000" => H1 <= "0000000"; -- 8
            when "1001" => H1 <= "0000100"; -- 9
            when others => H1 <= "1111111"; -- off
        end case;

        -- Decodifica centinaia
        case hundreds is
            when "0000" => H2 <= "0000001"; -- 0
            when "0001" => H2 <= "1001111"; -- 1
            when "0010" => H2 <= "0010010"; -- 2
            when "0011" => H2 <= "0000110"; -- 3
            when "0100" => H2 <= "1001100"; -- 4
            when "0101" => H2 <= "0100100"; -- 5
            when "0110" => H2 <= "0100000"; -- 6
            when "0111" => H2 <= "0001111"; -- 7
            when "1000" => H2 <= "0000000"; -- 8
            when "1001" => H2 <= "0000100"; -- 9
            when others => H2 <= "1111111"; -- off
        end case;
    end process;
end Behavioral;