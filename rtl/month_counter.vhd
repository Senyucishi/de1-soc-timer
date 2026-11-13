library ieee;
use ieee.std_logic_1164.all;

-- Months, January through December.
entity month_counter is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        tick     : in  std_logic;
        load     : in  std_logic;
        preset   : in  natural range 1 to 12;
        value    : out natural range 1 to 12;
        carry    : out std_logic
    );
end entity;

architecture rtl of month_counter is
    signal count : natural range 1 to 12 := 1;
begin
    value <= count;
    -- Carry enables the next counter on the same clock edge.
    carry <= '1' when tick = '1' and count = 12 and load = '0' and reset = '0'
             else '0';

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= 1;
            elsif load = '1' then
                count <= preset;
            elsif tick = '1' then
                if count = 12 then
                    count <= 1;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
