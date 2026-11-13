library ieee;
use ieee.std_logic_1164.all;

-- Minutes, 00 through 59.
entity minute_counter is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        tick     : in  std_logic;
        load     : in  std_logic;
        preset   : in  natural range 0 to 59;
        value    : out natural range 0 to 59;
        carry    : out std_logic
    );
end entity;

architecture rtl of minute_counter is
    signal count : natural range 0 to 59 := 0;
begin
    value <= count;
    -- Carry enables the next counter on the same clock edge.
    carry <= '1' when tick = '1' and count = 59 and load = '0' and reset = '0'
             else '0';

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= 0;
            elsif load = '1' then
                count <= preset;
            elsif tick = '1' then
                if count = 59 then
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
