entity month_length is
    port (
        year_digits : in  natural range 0 to 99;
        month       : in  natural range 1 to 12;
        days        : out natural range 28 to 31
    );
end entity;

architecture rtl of month_length is
begin
    process (year_digits, month)
    begin
        case month is
            when 2 =>
                -- In 2000..2099, every year divisible by four is a leap year.
                if year_digits mod 4 = 0 then
                    days <= 29;
                else
                    days <= 28;
                end if;
            when 4 | 6 | 9 | 11 =>
                days <= 30;
            when others =>
                days <= 31;
        end case;
    end process;
end architecture;
