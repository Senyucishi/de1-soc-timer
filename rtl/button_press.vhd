library ieee;
use ieee.std_logic_1164.all;

entity button_press is
    generic (
        STABLE_CYCLES : positive := 500_000
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        key_n     : in  std_logic;
        pressed   : out std_logic
    );
end entity;

architecture rtl of button_press is
    signal key_meta, key_sync : std_logic := '1';
    signal stable_key : std_logic := '1';
    signal cycles : natural range 0 to STABLE_CYCLES - 1 := 0;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            key_meta <= key_n;
            key_sync <= key_meta;
            pressed  <= '0';

            if reset = '1' then
                stable_key <= '1';
                cycles     <= 0;
            elsif key_sync = stable_key then
                cycles <= 0;
            elsif cycles = STABLE_CYCLES - 1 then
                stable_key <= key_sync;
                cycles     <= 0;
                if key_sync = '0' then
                    pressed <= '1';
                end if;
            else
                cycles <= cycles + 1;
            end if;
        end if;
    end process;
end architecture;
