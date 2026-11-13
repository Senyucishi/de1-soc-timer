library ieee;
use ieee.std_logic_1164.all;
use work.timer_types.all;

entity tzkzq is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        mode_press   : in  std_logic;
        adjust_press : in  std_logic;
        mode         : out adjustment_mode;
        count_enable : out std_logic;
        adjust       : out std_logic;
        finish_edit  : out std_logic;
        leds         : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of tzkzq is
    signal current_mode : adjustment_mode := running;
begin
    mode <= current_mode;
    -- A mode change takes priority when the two buttons arrive together.
    count_enable <= '1' when current_mode = running and mode_press = '0' else '0';
    adjust <= adjust_press when current_mode /= running and mode_press = '0' else '0';
    finish_edit <= mode_press when current_mode = set_weekday else '0';

    -- From LEDR[6] to LEDR[0]: year, month, day, hour, minute, second, weekday.
    with current_mode select leds <=
        "1000000" when set_year,
        "0100000" when set_month,
        "0010000" when set_day,
        "0001000" when set_hour,
        "0000100" when set_minute,
        "0000010" when set_second,
        "0000001" when set_weekday,
        "0000000" when running;

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_mode <= running;
            elsif mode_press = '1' then
                case current_mode is
                    when running     => current_mode <= set_second;
                    when set_second  => current_mode <= set_minute;
                    when set_minute  => current_mode <= set_hour;
                    when set_hour    => current_mode <= set_day;
                    when set_day     => current_mode <= set_month;
                    when set_month   => current_mode <= set_year;
                    when set_year    => current_mode <= set_weekday;
                    when set_weekday => current_mode <= running;
                end case;
            end if;
        end if;
    end process;
end architecture;
