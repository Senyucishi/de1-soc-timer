library ieee;
use ieee.std_logic_1164.all;

package timer_types is
    type adjustment_mode is (
        running, set_second, set_minute, set_hour, set_day, set_month, set_year, set_weekday
    );
    subtype bcd_digit is std_logic_vector(3 downto 0);
    type bcd_digits is array (natural range <>) of bcd_digit;
    constant DISPLAY_DASH : bcd_digit := "1010";
end package;
