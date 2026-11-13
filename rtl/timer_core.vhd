library ieee;
use ieee.std_logic_1164.all;
use work.timer_types.all;

entity timer_core is
    generic (
        CLOCK_HZ : positive := 50_000_000
    );
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        mode_press   : in  std_logic;
        adjust_press : in  std_logic;
        mode         : out adjustment_mode;
        leds         : out std_logic_vector(6 downto 0);
        seconds      : out natural range 0 to 59;
        minutes      : out natural range 0 to 59;
        hours        : out natural range 0 to 23;
        day          : out natural range 1 to 31;
        month        : out natural range 1 to 12;
        year_digits  : out natural range 0 to 99;
        weekday      : out natural range 1 to 7
    );
end entity;

architecture structural of timer_core is
    signal current_mode : adjustment_mode;
    signal count_enable, adjust, finish_edit : std_logic;
    signal tick_second, tick_minute, tick_hour, tick_day, tick_month, tick_year : std_logic;

    signal seconds_value, seconds_preset : natural range 0 to 59;
    signal minutes_value, minutes_preset : natural range 0 to 59;
    signal hours_value, hours_preset : natural range 0 to 23;
    signal day_value, day_preset : natural range 1 to 31;
    signal month_value, month_preset : natural range 1 to 12;
    signal year_value, year_preset : natural range 0 to 99;
    signal weekday_value, weekday_preset : natural range 1 to 7;
    signal month_days : natural range 28 to 31;
    signal load_seconds, load_minutes, load_hours, load_day : std_logic;
    signal load_month, load_year, load_weekday : std_logic;
begin
    mode        <= current_mode;
    seconds     <= seconds_value;
    minutes     <= minutes_value;
    hours       <= hours_value;
    day         <= day_value;
    month       <= month_value;
    year_digits <= year_value;
    weekday     <= weekday_value;

    adjustment_control : entity work.tzkzq
        port map (clk => clk, reset => reset, mode_press => mode_press,
                  adjust_press => adjust_press, mode => current_mode,
                  count_enable => count_enable, adjust => adjust, finish_edit => finish_edit,
                  leds => leds);

    clock_divider : entity work.second_tick
        generic map (CLOCK_HZ => CLOCK_HZ)
        port map (clk => clk, reset => reset, enable => count_enable, tick => tick_second);

    calendar_limit : entity work.month_length
        port map (year_digits => year_value, month => month_value, days => month_days);

    load_seconds <= adjust when current_mode = set_second else '0';
    load_minutes <= adjust when current_mode = set_minute else '0';
    load_hours   <= adjust when current_mode = set_hour else '0';
    load_month   <= adjust when current_mode = set_month else '0';
    load_year    <= adjust when current_mode = set_year else '0';
    load_weekday <= adjust when current_mode = set_weekday else '0';

    -- Edits affect only the selected field. On exit, clamp any invalid date.
    load_day <= adjust when current_mode = set_day else
                finish_edit when day_value > month_days else '0';

    seconds_preset <= 0 when seconds_value = 59 else seconds_value + 1;
    minutes_preset <= 0 when minutes_value = 59 else minutes_value + 1;
    hours_preset   <= 0 when hours_value = 23 else hours_value + 1;
    month_preset   <= 1 when month_value = 12 else month_value + 1;
    year_preset    <= 0 when year_value = 99 else year_value + 1;
    weekday_preset <= 1 when weekday_value = 7 else weekday_value + 1;
    day_preset     <= day_value when finish_edit = '1' else
                      1 when day_value >= month_days else day_value + 1;

    count_seconds : entity work.second_counter
        port map (clk => clk, reset => reset, tick => tick_second, load => load_seconds,
                  preset => seconds_preset, value => seconds_value, carry => tick_minute);

    count_minutes : entity work.minute_counter
        port map (clk => clk, reset => reset, tick => tick_minute, load => load_minutes,
                  preset => minutes_preset, value => minutes_value, carry => tick_hour);

    count_hours : entity work.hour_counter
        port map (clk => clk, reset => reset, tick => tick_hour, load => load_hours,
                  preset => hours_preset, value => hours_value, carry => tick_day);

    count_day : entity work.day_counter
        port map (clk => clk, reset => reset, tick => tick_day, month_days => month_days,
                  load => load_day, preset => day_preset, value => day_value, carry => tick_month);

    count_month : entity work.month_counter
        port map (clk => clk, reset => reset, tick => tick_month, load => load_month,
                  preset => month_preset, value => month_value, carry => tick_year);

    count_year : entity work.year_counter
        port map (clk => clk, reset => reset, tick => tick_year, load => load_year,
                  preset => year_preset, value => year_value, carry => open);

    count_weekday : entity work.weekday_counter
        port map (clk => clk, reset => reset, tick => tick_day, load => load_weekday,
                  preset => weekday_preset, value => weekday_value, carry => open);
end architecture;
