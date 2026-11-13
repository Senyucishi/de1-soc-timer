library ieee;
use ieee.std_logic_1164.all;

-- Weekday, Monday = 1 through Sunday = 7. 2000-01-01 was a Saturday.
entity weekday_counter is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        tick     : in  std_logic;
        load     : in  std_logic;
        preset   : in  natural range 1 to 7;
        value    : out natural range 1 to 7;
        carry    : out std_logic
    );
end entity;

architecture rtl of weekday_counter is
    signal count : natural range 1 to 7 := 6;
begin
    value <= count;
    -- Carry enables the next counter on the same clock edge.
    carry <= '1' when tick = '1' and count = 7 and load = '0' and reset = '0'
             else '0';

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= 6;
            elsif load = '1' then
                count <= preset;
            elsif tick = '1' then
                if count = 7 then
                    count <= 1;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
