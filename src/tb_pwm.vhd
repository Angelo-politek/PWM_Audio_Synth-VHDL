
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pwm is
end tb_pwm;

architecture Behavioral of tb_pwm is
    component USER_INTERFACE is
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
    end component;

    signal CLK_t : STD_LOGIC := '0';
    signal SW_t : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal KEY_t : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal GPIO_t : STD_LOGIC_VECTOR(1 downto 0);
    signal LEDR_t : STD_LOGIC_VECTOR(9 downto 0);
    signal HEX0_t : STD_LOGIC_VECTOR(0 to 6);
    signal HEX1_t : STD_LOGIC_VECTOR(0 to 6);

begin
    UUT: USER_INTERFACE port map (
        CLOCK_50 => CLK_t,
        SW => SW_t,
        KEY => KEY_t,
        GPIO => GPIO_t,
        LEDR => LEDR_t,
        HEX0 => open,
        HEX1 => open,
        HEX2 => open,
        HEX3 => open,
        HEX4 => open,
        HEX5 => open
    );

    process begin
        CLK_t <= not CLK_t;
        wait for 10 ns;
    end process;

    process 
    begin
        SW_t <= "1000000000";
        KEY_t <= "00";
        wait for 5 us;
	SW_t <= "0000000000";
        KEY_t <= "00";
        wait for 5 us;
        SW_t <= "0000000010";
        wait for 5 us;
        KEY_t <= "10";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        KEY_t <= "10";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        KEY_t <= "10";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        KEY_t <= "10";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        KEY_t <= "01";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        SW_t <= "0000000011";
        wait for 5 us;
        KEY_t <= "10";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        KEY_t <= "10";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        KEY_t <= "10";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        KEY_t <= "10";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 us;
        KEY_t <= "01";
        wait for 5 us;
        KEY_t <= "00";
        wait for 5 ms;
end process;

end Behavioral;
