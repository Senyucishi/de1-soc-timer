library ieee;
use ieee.std_logic_1164.all;

-- Hours in 24-hour format.
entity hour_counter is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        tick     : in  std_logic;
        load     : in  std_logic;
        preset   : in  natural range 0 to 23;
        value    : out natural range 0 to 23;
        carry    : out std_logic
    );
end entity;

architecture rtl of hour_counter is
    signal count : natural range 0 to 23 := 0;
begin
    value <= count;
    -- Carry enables the next counter on the same clock edge.
    carry <= '1' when tick = '1' and count = 23 and load = '0' and reset = '0'
             else '0';

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= 0;
            elsif load = '1' then
                count <= preset;
            elsif tick = '1' then
                if count = 23 then
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
