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
    subtype decimal_value is natural range 0 to 99;
    subtype bcd_pair is bcd_digits(1 downto 0);

    function to_bcd_pair(number : decimal_value) return bcd_pair is
        constant TEN : unsigned(6 downto 0) := to_unsigned(10, 7);
        variable binary : unsigned(6 downto 0);
    begin
        binary := to_unsigned(number, binary'length);
        return (
            1 => std_logic_vector(resize(binary / TEN, 4)),
            0 => std_logic_vector(resize(binary mod TEN, 4))
        );
    end function;

    signal page : std_logic_vector(1 downto 0);
begin
    with mode select page <=
        "00"        when set_second | set_minute | set_hour,
        "01"        when set_day | set_month,
        "10"        when set_year | set_weekday,
        page_select when running;

    process (page, seconds, minutes, hours, day, month, year_digits, weekday)
        variable left_value, middle_value, right_value : decimal_value;
        variable left_digits, middle_digits, right_digits : bcd_pair;
    begin
        -- Select values before conversion. Each pair drives one group on the board.
        case page is
            when "01" =>   -- YY MM DD
                left_value   := year_digits;
                middle_value := month;
                right_value  := day;
            when "10" =>   -- YYYY-W
                left_value   := 20;
                middle_value := year_digits;
                right_value  := weekday;
            when "11" =>   -- Fixed pattern for checking the board's digit order.
                left_value   := 12;
                middle_value := 34;
                right_value  := 56;
            when others =>
                left_value   := hours;
                middle_value := minutes;
                right_value  := seconds;
        end case;

        left_digits   := to_bcd_pair(left_value);
        middle_digits := to_bcd_pair(middle_value);
        right_digits  := to_bcd_pair(right_value);
        if page = "10" then
            right_digits(1) := DISPLAY_DASH;
        end if;

        -- The indices match the HEX port numbers. HEX5 is leftmost.
        digits <= (
            5 => left_digits(1),   4 => left_digits(0),
            3 => middle_digits(1), 2 => middle_digits(0),
            1 => right_digits(1),  0 => right_digits(0)
        );
    end process;
end architecture;
