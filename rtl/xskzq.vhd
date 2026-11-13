library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.timer_types.all;

entity xskzq is
    port (
        page_select : in  std_logic_vector(1 downto 0);
        mode        : in  adjustment_mode;
        seconds     : in  natural range 0 to 59;
        minutes     : in  natural range 0 to 59;
        hours       : in  natural range 0 to 23;
        day         : in  natural range 1 to 31;
        month       : in  natural range 1 to 12;
        year_digits : in  natural range 0 to 99;
        weekday     : in  natural range 1 to 7;
        digits      : out bcd_digits(5 downto 0)
    );
end entity;

architecture rtl of xskzq is
    constant BLANK : bcd_digit := "1111";
    constant BLANK_PAIR : bcd_digits(1 downto 0) := (others => BLANK);

    function bcd_pair(number : natural) return bcd_digits is
        constant TEN : unsigned(6 downto 0) := to_unsigned(10, 7);
        variable binary : unsigned(6 downto 0);
        variable pair : bcd_digits(1 downto 0);
    begin
        binary  := to_unsigned(number, binary'length);
        pair(1) := std_logic_vector(resize(binary / TEN, 4));
        pair(0) := std_logic_vector(resize(binary mod TEN, 4));
        return pair;
    end function;

    signal page : std_logic_vector(1 downto 0);
begin
    with mode select page <=
        "00"        when set_second | set_minute | set_hour,
        "01"        when set_day | set_month,
        "10"        when set_year | set_weekday,
        page_select when running;

    -- Board digits have separate segment lines. Digits run from HEX5 to HEX0.
    process (page, seconds, minutes, hours, day, month, year_digits, weekday)
    begin
        case page is
            when "01" =>
                digits <= BLANK_PAIR & bcd_pair(month) & bcd_pair(day);
            when "10" | "11" =>
                digits <= bcd_pair(20) & bcd_pair(year_digits) & BLANK &
                          std_logic_vector(to_unsigned(weekday, 4));
            when others =>
                digits <= bcd_pair(hours) & bcd_pair(minutes) & bcd_pair(seconds);
        end case;
    end process;
end architecture;
