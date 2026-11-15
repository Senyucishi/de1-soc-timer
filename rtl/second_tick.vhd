library ieee;
use ieee.std_logic_1164.all;

entity second_tick is
    generic (
        CLOCK_HZ : positive := 50_000_000
    );
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        tick   : out std_logic
    );
end entity;

architecture rtl of second_tick is
    signal cycles : natural range 0 to CLOCK_HZ - 1 := 0;
begin
    -- All counters use clk. This pulse is a clock enable.
    tick <= '1' when cycles = CLOCK_HZ - 1 and enable = '1' and reset = '0' else '0';

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cycles <= 0;
            elsif enable = '1' then
                if cycles = CLOCK_HZ - 1 then
                    cycles <= 0;
                else
                    cycles <= cycles + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
