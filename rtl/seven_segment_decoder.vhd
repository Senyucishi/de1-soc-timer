library ieee;
use ieee.std_logic_1164.all;
use work.timer_types.all;

entity seven_segment_decoder is
    port (
        clk   : in  std_logic;
        digit : in  bcd_digit;
        hex_n : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of seven_segment_decoder is
    signal segments : std_logic_vector(6 downto 0) := (others => '1');
begin
    hex_n <= segments;

    -- DTTIMES/DISPLAY.vhd patterns. HEX(6..0) corresponds to g..a, active low.
    -- All six instances register their new pattern on the same clock edge.
    process (clk)
    begin
        if rising_edge(clk) then
            case digit is
                when "0000"       => segments <= "1000000";
                when "0001"       => segments <= "1111001";
                when "0010"       => segments <= "0100100";
                when "0011"       => segments <= "0110000";
                when "0100"       => segments <= "0011001";
                when "0101"       => segments <= "0010010";
                when "0110"       => segments <= "0000010";
                when "0111"       => segments <= "1111000";
                when "1000"       => segments <= "0000000";
                when "1001"       => segments <= "0010000";
                when DISPLAY_DASH => segments <= "0111111";
                when others       => segments <= "1111111";
            end case;
        end if;
    end process;
end architecture;
