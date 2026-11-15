# 基于 FPGA 的综合计时系统

本工程使用 VHDL 在 DE1-SoC（Cyclone V 5CSEMA5F31C6N）上实现 24 小时制日历时钟。系统记录 2000–2099 年的年、月、日、时、分、秒和星期，按平年、闰年和月份天数进位。2099 年 12 月 31 日过后，日期回到 2000 年 1 月 1 日。

## Quartus 工程

1. 打开 [de1_soc_timer.qpf](de1_soc_timer.qpf)。顶层实体为 [de1_soc_timer](rtl/de1_soc_timer.vhd)，管脚分配和 50 MHz 时钟约束分别位于 [de1_soc_timer.qsf](de1_soc_timer.qsf) 和 [de1_soc_timer.sdc](de1_soc_timer.sdc)。
2. 选择 **Processing → Start Compilation**。编译成功后，使用 **Programmer** 通过 USB-Blaster 将 `output_files/de1_soc_timer.sof` 下载到开发板。
3. 按 `KEY[2]` 复位到 2000 年 1 月 1 日 00:00:00，星期六。

## 按键与显示

| 控件 | 操作 |
| --- | --- |
| `KEY[0]` | 依次切换正常 → 秒 → 分 → 时 → 日 → 月 → 年 → 星期 → 正常 |
| `KEY[1]` | 当前字段加 1，达到上限时回到起始值。长按只触发一次 |
| `KEY[2]` | 复位日期、时间、星期和调校模式 |
| `SW[1:0]` | 正常计时时切换显示页 |

板载六位数码管从左到右为 `HEX5` 至 `HEX0`。

| `SW[1:0]` | 显示 | 复位后的示例 |
| --- | --- | --- |
| `00` | 时、分、秒，各两位 | `000000` |
| `01` | 年份后两位、月、日，各两位 | `000101` |
| `10` | 四位年份、短横线、星期。周一为 1，周日为 7 | `2000-6` |
| `11` | 固定测试图样，用于检查六位的顺序和段形 | `123456` |

调校时暂停走时，显示自动切到当前字段所在页。指示灯 `LEDR[6:0]` 依次对应年、月、日、时、分、秒、星期。手动增加字段时，其他字段保持原值。退出调校时，如果日期超过当月天数，日数会修正为该月最后一天。

## VHDL 模块

| 文件 | 功能 |
| --- | --- |
| [second_counter](rtl/second_counter.vhd)、[minute_counter](rtl/minute_counter.vhd)、[hour_counter](rtl/hour_counter.vhd) | 秒、分、时计数和进位 |
| [day_counter](rtl/day_counter.vhd)、[month_counter](rtl/month_counter.vhd)、[year_counter](rtl/year_counter.vhd)、[weekday_counter](rtl/weekday_counter.vhd) | 日、月、年、星期计数和回卷 |
| [month_length](rtl/month_length.vhd) | 根据月份和年份确定当月天数 |
| [second_tick](rtl/second_tick.vhd)、[button_press](rtl/button_press.vhd) | 生成每秒计数使能，处理模式键和调整键的同步与消抖 |
| [tzkzq](rtl/tzkzq.vhd)、[timer_core](rtl/timer_core.vhd) | 调校状态机和计数器连接 |
| [xskzq](rtl/xskzq.vhd)、[seven_segment_decoder](rtl/seven_segment_decoder.vhd) | 选择显示页、生成 BCD 数字并转换为低有效段码 |
| [timer_types](rtl/timer_types.vhd)、[de1_soc_timer](rtl/de1_soc_timer.vhd) | 共用类型和 DE1-SoC 板级顶层 |

所有计数器共用 `CLOCK_50`，以使能信号完成分频和进位。数码管管脚和段码参考课程提供的 DTTIMES 工程。六位数码管独立驱动，在同一个时钟沿更新段码。

## 验证

GHDL 编译、综合检查和仿真已覆盖 1 秒分频、按键消抖、显示切页、跨日、平闰年二月和 2099 年回卷。Quartus 布局布线和实板验证待完成。
