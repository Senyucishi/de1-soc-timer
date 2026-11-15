library ieee;
use ieee.std_logic_1164.all;
use work.timer_types.all;

entity de1_soc_timer is
    generic (
        CLOCK_HZ        : positive := 50_000_000;
        DEBOUNCE_CYCLES : positive := 500_000
    );
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(2 downto 0);
        SW       : in  std_logic_vector(1 downto 0);
        LEDR     : out std_logic_vector(6 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0)
    );
end entity;

architecture structural of de1_soc_timer is
    signal reset_meta, reset : std_logic := '0';
    signal sw_meta, sw_sync : std_logic_vector(1 downto 0) := "00";
    signal mode_press, adjust_press : std_logic;
    signal mode : adjustment_mode;
    signal seconds, minutes : natural range 0 to 59;
    signal hours : natural range 0 to 23;
    signal day : natural range 1 to 31;
    signal month : natural range 1 to 12;
    signal year_digits : natural range 0 to 99;
    signal weekday : natural range 1 to 7;
    signal digits : bcd_digits(5 downto 0);
begin
    process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            reset_meta <= not KEY(2);
            reset      <= reset_meta;
            sw_meta    <= SW;
            sw_sync    <= sw_meta;
        end if;
    end process;

    mode_button : entity work.button_press
        generic map (STABLE_CYCLES => DEBOUNCE_CYCLES)
        port map (clk => CLOCK_50, reset => reset, key_n => KEY(0), pressed => mode_press);

    adjust_button : entity work.button_press
        generic map (STABLE_CYCLES => DEBOUNCE_CYCLES)
        port map (clk => CLOCK_50, reset => reset, key_n => KEY(1), pressed => adjust_press);

    timekeeping : entity work.timer_core
        generic map (CLOCK_HZ => CLOCK_HZ)
        port map (clk => CLOCK_50, reset => reset, mode_press => mode_press,
                  adjust_press => adjust_press, mode => mode, leds => LEDR,
                  seconds => seconds, minutes => minutes, hours => hours, day => day,
                  month => month, year_digits => year_digits, weekday => weekday);

    display_control : entity work.xskzq
        port map (page_select => sw_sync, mode => mode, seconds => seconds, minutes => minutes,
                  hours => hours, day => day, month => month, year_digits => year_digits,
                  weekday => weekday, digits => digits);

    decode_hex0 : entity work.seven_segment_decoder
        port map (clk => CLOCK_50, digit => digits(0), hex_n => HEX0);
    decode_hex1 : entity work.seven_segment_decoder
        port map (clk => CLOCK_50, digit => digits(1), hex_n => HEX1);
    decode_hex2 : entity work.seven_segment_decoder
        port map (clk => CLOCK_50, digit => digits(2), hex_n => HEX2);
    decode_hex3 : entity work.seven_segment_decoder
        port map (clk => CLOCK_50, digit => digits(3), hex_n => HEX3);
    decode_hex4 : entity work.seven_segment_decoder
        port map (clk => CLOCK_50, digit => digits(4), hex_n => HEX4);
    decode_hex5 : entity work.seven_segment_decoder
        port map (clk => CLOCK_50, digit => digits(5), hex_n => HEX5);
end architecture;
