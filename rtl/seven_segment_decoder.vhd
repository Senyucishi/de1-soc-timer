library ieee;
use ieee.std_logic_1164.all;
use work.timer_types.all;

entity seven_segment_decoder is
    port (
        digit : in  bcd_digit;
        hex_n : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of seven_segment_decoder is
begin
    -- Active-low gfedcba patterns from DTTIMES/DISPLAY.vhd.
    with digit select hex_n <=
        "1000000" when "0000",
        "1111001" when "0001",
        "0100100" when "0010",
        "0110000" when "0011",
        "0011001" when "0100",
        "0010010" when "0101",
        "0000010" when "0110",
        "1111000" when "0111",
        "0000000" when "1000",
        "0010000" when "1001",
        "1111111" when others;
end architecture;
