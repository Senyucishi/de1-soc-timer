library ieee;
use ieee.std_logic_1164.all;

entity day_counter is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        tick       : in  std_logic;
        month_days : in  natural range 28 to 31;
        load       : in  std_logic;
        preset     : in  natural range 1 to 31;
        value      : out natural range 1 to 31;
        carry      : out std_logic
    );
end entity;

architecture rtl of day_counter is
    signal count : natural range 1 to 31 := 1;
begin
    value <= count;
    carry <= '1' when tick = '1' and count >= month_days and load = '0' and reset = '0'
             else '0';

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= 1;
            elsif load = '1' then
                if preset > month_days then
                    count <= month_days;
                else
                    count <= preset;
                end if;
            elsif tick = '1' then
                if count >= month_days then
                    count <= 1;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
