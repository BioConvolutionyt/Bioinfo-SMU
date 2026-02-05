# Tidyverse 数据处理

## 1. 引言

在上节内容中，我们学习了 Base R 中的数据结构操作方法。虽然 Base R 功能强大，但在处理复杂数据时，代码往往不够简洁和直观。`tidyverse` 是一个专为数据科学设计的 R 包集合，它提供了一套统一、优雅的语法来进行数据处理和可视化。

本节目标：掌握 `tidyverse` 生态系统中两个最核心的包——`dplyr`（数据操作）和 `tidyr`（数据整理）的基本用法。

<br>

## 2. Tidyverse 概述

### 2.1 什么是 Tidyverse

`tidyverse` 是由 Hadley Wickham 主导开发的一系列 R 包的集合，包括：

- **dplyr**：数据操作（筛选、排序、汇总等）
- **tidyr**：数据整理（长宽格式转换等）
- **ggplot2**：数据可视化
- **readr**：数据读取
- **tibble**：增强型数据框
- **stringr**：字符串处理
- **purrr**：函数式编程
- **forcats**：因子处理

这些包共享统一的设计理念和语法风格，使得数据处理流程更加流畅。

<br>

### 2.2 安装与加载

```r
# 安装整个tidyverse
install.packages("tidyverse")

# 或单独安装
install.packages("dplyr")
install.packages("tidyr")
```

加载 tidyverse 会同时加载核心包：

```r
{if (!requireNamespace("tidyverse", quietly = TRUE))
    install.packages("tidyverse")}
```

<br>

### 2.3 Tibble：增强型数据框

Tibble 是 tidyverse 中的数据框形式，相比传统 `data.frame` 有以下优势：

- 打印时更简洁，只显示前几行和适配屏幕的列
- 不自动将字符串转换为因子(默认`stringsAsFactors==FALSE`)
- 不会自动修改列名
- 子集操作更一致

```r
# 创建 tibble
library(tidyverse)
tb <- tibble(
  sample_id = paste0("S", 1:6),
  group = c("Ctrl", "Ctrl", "Treat", "Treat", "Treat", "Ctrl"),
  age = c(45, 52, 60, 58, NA, 49),
  score = c(85.5, 92.3, 78.1, 88.6, 91.2, 76.8)
)

# 查看 tibble
tb
class(tb)
```

注意表头下方用尖括号标注了数据类型：
- `<chr>` 表示字符型
- `<dbl>` 表示双精度浮点数
- `<int>` 表示整数型

<br>

### 2.4 管道符 |>

管道符是 tidyverse 代码的核心特征，它将前一步的结果作为下一个函数的第一个参数，使代码更具可读性。

R 4.1.0 之后，Base R 提供了原生管道符 `|>`。tidyverse 早期使用的是 `magrittr` 包的 `%>%`，*两者在大多数情况下可以互换*。

```r
# 传统嵌套写法（不简洁）
round(mean(c(1, 2, 3, 4, 5)), 2)

# 管道符写法（清晰直观）
c(1, 2, 3, 4, 5) |> 
  mean() |> 
  round(2)
```

<br>

## 3. dplyr 包：数据操作

`dplyr` 提供了一组"动词"函数来进行数据操作。这些函数有以下共同特点：

- 第一个参数是*数据框*
- 后续参数使用*不带引号*的变量名
- 输出结果是一个新数据框

<br>

### 3.1 准备示例数据

我们使用 `nycflights13` 包中的航班数据作为示例：

```r
# install.packages("nycflights13")
library(nycflights13)

flights
```

该数据集包含 2013 年从纽约市出发的所有 336,776 个航班记录。

<br>

### 3.2 行操作

#### 3.2.1 filter() - 筛选*行*

`filter()` 根据条件筛选数据框中的行：

```r
# 筛选起飞延误超过 120 分钟的航班
flights |> 
  filter(dep_delay > 120)
```

可以使用的比较运算符：
- `>`（大于）、`>=`（大于等于）
- `<`（小于）、`<=`（小于等于）
- `==`（等于）、`!=`（不等于）

多条件筛选：

```r
# 使用 & 表示"与"
flights |> 
  filter(month == 1 & day == 1)

# 使用 | 表示"或"
flights |> 
  filter(month == 1 | month == 2)

# 使用 %in% 简化多值匹配
flights |> 
  filter(month %in% c(1, 2)) # 保留在1月或2月的航班
```

**常见错误**：
- 用 `=` 判断相等，而非 `==`
- 写成 `month == 1 | 2` 而非 `month == 1 | month == 2`

<br>

#### 3.2.2 arrange() - 排序

`arrange()` 根据列值对行进行排序：

```r
# 按年、月、日、起飞时间排序
flights |> 
  arrange(year, month, day, dep_time) # 默认从小到大排列

# 使用 desc() 进行降序排列
flights |> 
  arrange(desc(dep_delay))
```

<br>

#### 3.2.3 distinct() - 去重

`distinct()` 查找唯一行：

```r
# 删除完全重复的行
flights |> 
  distinct()

# 获取所有起点和终点的唯一组合
flights |> 
  distinct(origin, dest)

# 保留其他列信息
flights |> 
  distinct(origin, dest, .keep_all = TRUE)
```

使用 `count()` 统计各组合出现次数：

```r
flights |> 
  count(origin, dest, sort = TRUE)
```

<br>

### 3.3 列操作

#### 3.3.1 select() - 选择列

`select()` 用于选取需要的列：

```r
# 指定列名
flights |> 
  select(year, month, day)

# 选择连续区间
flights |> 
  select(year:day)

# 排除某些列
flights |> 
  select(!year:day)

# 选择字符型列
flights |> 
  select(where(is.character))
```

辅助函数进行模式匹配：

```r
# 以 "dep" 开头的列
flights |> 
  select(starts_with("dep"))

# 以 "time" 结尾的列
flights |> 
  select(ends_with("time"))

# 包含 "arr" 的列
flights |> 
  select(contains("arr"))
```

<br>

#### 3.3.2 mutate() - 创建新列

`mutate()` 基于现有列*创建新列*：

```r
flights |> 
  mutate(
    gain = dep_delay - arr_delay,       # 延误恢复时间
    speed = distance / air_time * 60    # 飞行速度（英里/小时）
  ) |> 
  select(flight, gain, speed)
```

控制新列位置：

```r
# 将新列放在最前面
flights |> 
  mutate(
    speed = distance / air_time * 60,
    .before = 1 # .before控制新列位置
  ) |> 
  select(1:5)

# 只保留参与计算的列
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )
```

<br>

#### 3.3.3 rename() - 重命名列

```r
# 将 tailnum 重命名为 tail_num
flights |> 
  rename(tail_num = tailnum) |> 
  select(tail_num)
```

<br>

#### 3.3.4 relocate() - 调整列位置

```r
# 将 time_hour 和 air_time 移到最前面
flights |> 
  relocate(time_hour, air_time)

# 将 "arr" 开头的列移到 dep_time 之前
flights |> 
  relocate(starts_with("arr"), .before = dep_time)
```

<br>

### 3.4 分组与汇总

#### 3.4.1 group_by() - 分组

`group_by()` 将数据按变量分组，后续操作将以组为单位进行：

```r
flights |> 
  group_by(month)
```

<br>

#### 3.4.2 summarize() - 汇总统计

`summarize()` 计算每组的统计量：

```r
flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    flight_count = n()
  )
```

- `na.rm = TRUE` 用于忽略缺失值
- `n()` 返回当前分组的行数

<br>

#### 3.4.3 多重分组

可以按多个变量分组：

```r
flights |> 
  group_by(year, month, day) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    .groups = "drop"  # 取消分组
  )
```

`.groups` 参数控制输出的分组状态：
- `"drop_last"`：保留上层分组（默认）
- `"drop"`：全部取消分组
- `"keep"`：保留所有分组

<br>

#### 3.4.4 ungroup() - 移除分组

```r
flights |> 
  group_by(month) |> 
  summarize(n = n()) |> 
  ungroup() |> 
  summarize(total = sum(n))
```

<br>

#### 3.4.5 .by 参数（dplyr 1.1.0+）

`.by` 参数提供了更简洁的分组语法，分组仅在当前操作中生效：

```r
# 传统写法
flights |> 
  group_by(month) |> 
  summarize(delay = mean(dep_delay, na.rm = TRUE)) |> 
  ungroup()

# .by 简化写法
flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE),
    .by = month
  )

# 多变量分组
flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE),
    n = n(),
    .by = c(origin, dest)
  )
```

<br>

#### 3.4.6 slice_*() 系列函数

用于提取组内特定行：

```r
# 每个目的地到达延误最长的航班
flights |> 
  group_by(dest) |> 
  slice_max(arr_delay, n = 1) |> 
  relocate(dest, arr_delay)
```

常用函数：
- `slice_head(n = 1)`：每组取最前一行
- `slice_tail(n = 1)`：每组取最后一行
- `slice_max(order_by, n = 1)`：每组取最大值
- `slice_min(order_by, n = 1)`：每组取最小值
- `slice_sample(n = 1)`：每组随机取一行

<br>

### 3.5 综合示例

找出飞往 IAH 的航班中速度最快的几架飞机：

```r
flights |> 
  filter(dest == "IAH") |> 
  mutate(speed = distance / air_time * 60) |> 
  select(year:day, dep_time, carrier, flight, speed) |> 
  arrange(desc(speed)) |> 
  head(10)
```

这段代码的逻辑是：
1. 筛选目的地为 IAH 的航班
2. 计算飞行速度
3. 选择需要的列
4. 按速度降序排列
5. 取前 10 行

<br>

## 4. tidyr 包：数据整理

`tidyr` 专门用于数据的"整理"，即将数据转换为"整洁数据"（tidy data）格式。

### 4.1 整洁数据的定义

整洁数据满足以下三个条件：
1. 每个变量占一列
2. 每个观测占一行
3. 每个值占一个单元格

<br>

### 4.2 长宽格式转换

在实际分析中，数据常常需要在"宽格式"和"长格式"之间转换。

#### 4.2.1 pivot_longer() - 宽转长

将多列合并为一列，增加行数：

```r
# 创建宽格式数据
df_wide <- tibble(
  gene = c("GeneA", "GeneB", "GeneC"),
  sample1 = c(10, 20, 15),
  sample2 = c(12, 18, 22),
  sample3 = c(8, 25, 19)
)

df_wide

# 转换为长格式
df_long <- df_wide |> 
  pivot_longer(
    cols = starts_with("sample"),  # 要转换的列
    names_to = "sample",           # 列名存入的新列
    values_to = "expression"       # 值存入的新列
  )

df_long
```

更复杂的例子：

```r
# 列名包含多个信息
df_complex <- tibble(
  id = 1:3,
  ctrl_day1 = c(1, 2, 3),
  ctrl_day2 = c(4, 5, 6),
  treat_day1 = c(7, 8, 9),
  treat_day2 = c(10, 11, 12)
)

df_complex |> 
  pivot_longer(
    cols = -id,
    names_to = c("group", "time"),
    names_sep = "_",
    values_to = "value"
  )
```

<br>

#### 4.2.2 pivot_wider() - 长转宽

将一列拆分为多列，减少行数：

```r
# 从长格式转回宽格式
df_long |> 
  pivot_wider(
    names_from = sample,       # 从哪列取新的列名
    values_from = expression   # 从哪列取值
  )
```

实际应用示例：

```r
# 汇总数据通常是长格式
summary_data <- flights |> 
  group_by(carrier, month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    .groups = "drop"
  ) |> 
  filter(month <= 3)

summary_data

# 转换为宽格式便于查看
summary_data |> 
  pivot_wider(
    names_from = month,
    values_from = avg_delay,
    names_prefix = "month_"
  )
```

<br>

### 4.3 分离与合并

#### 4.3.1 separate() / separate_wider_delim() - 拆分列

将一列拆分为多列：

```r
# 创建示例数据
df_sep <- tibble(
  id = 1:3,
  date = c("2024-01-15", "2024-02-20", "2024-03-25")
)

# 使用 separate_wider_delim() 拆分
df_sep |> 
  separate_wider_delim(
    cols = date,
    delim = "-",
    names = c("year", "month", "day")
  )
```

按位置拆分：

```r
df_pos <- tibble(
  id = 1:3,
  code = c("AB123", "CD456", "EF789")
)

df_pos |> 
  separate_wider_position(
    cols = code,
    widths = c(letters = 2, numbers = 3)
  )
```

<br>

#### 4.3.2 unite() - 合并列

将多列合并为一列：

```r
df_unite <- tibble(
  year = c(2024, 2024, 2024),
  month = c(1, 2, 3),
  day = c(15, 20, 25)
)

df_unite |> 
  unite(
    col = "date",
    year, month, day,
    sep = "-"
  )
```

<br>

### 4.4 缺失值处理

#### 4.4.1 drop_na() - 删除含缺失值的行

```r
df_na <- tibble(
  x = c(1, 2, NA, 4),
  y = c("a", NA, "c", "d")
)

# 删除任何列有 NA 的行
df_na |> 
  drop_na()

# 只针对特定列
df_na |> 
  drop_na(x)
```

<br>

#### 4.4.2 fill() - 填充缺失值

用前一个或后一个值填充 NA：

```r
df_fill <- tibble(
  group = c("A", NA, NA, "B", NA, "C"),
  value = 1:6
)

# 向下填充
df_fill |> 
  fill(group, .direction = "down")

# 向上填充
df_fill |> 
  fill(group, .direction = "up")
```

<br>

#### 4.4.3 replace_na() - 替换缺失值

```r
df_na |> 
  replace_na(list(x = 0, y = "missing"))
```

<br>

### 4.5 嵌套与展开

#### 4.5.1 nest() - 嵌套数据

将数据按组嵌套为列表列：

```r
flights_nested <- flights |> 
  select(carrier, flight, origin, dest, air_time) |> 
  group_by(carrier) |> 
  nest()

flights_nested
```

<br>

#### 4.5.2 unnest() - 展开嵌套

```r
flights_nested |> 
  unnest(data) |> 
  head(10)
```

<br>

## 5. dplyr 与 tidyr 结合使用

### 5.1 数据清洗完整流程

假设我们有一个基因表达数据集：

```r
# 创建模拟数据
gene_expr <- tibble(
  gene_id = paste0("Gene", 1:5),
  ctrl_rep1 = c(100, 200, 150, NA, 300),
  ctrl_rep2 = c(110, 190, 160, 180, 290),
  treat_rep1 = c(150, 180, 200, 220, 350),
  treat_rep2 = c(140, 175, 210, 215, 340)
)

gene_expr
```

完整的清洗和分析流程：

```r
gene_expr |> 
  # 1. 宽格式转长格式
  pivot_longer(
    cols = -gene_id,
    names_to = "sample",
    values_to = "expression"
  ) |> 
  # 2. 拆分样本信息
  separate_wider_delim(
    cols = sample,
    delim = "_",
    names = c("group", "replicate")
  ) |> 
  # 3. 删除缺失值
  drop_na() |> 
  # 4. 分组汇总
  group_by(gene_id, group) |> 
  summarize(
    mean_expr = mean(expression),
    sd_expr = sd(expression),
    .groups = "drop"
  ) |> 
  # 5. 计算 fold change
  pivot_wider(
    names_from = group,
    values_from = c(mean_expr, sd_expr)
  ) |> 
  mutate(
    fold_change = mean_expr_treat / mean_expr_ctrl,
    log2FC = log2(fold_change)
  ) |> 
  # 6. 按 fold change 排序
  arrange(desc(abs(log2FC)))
```

<br>

### 5.2 表格连接

dplyr 提供了多种表格连接函数，类似于 SQL 的 JOIN 操作：

```r
# 创建示例表
df1 <- tibble(
  id = c(1, 2, 3, 4),
  value1 = c("a", "b", "c", "d")
)

df2 <- tibble(
  id = c(2, 3, 4, 5),
  value2 = c("x", "y", "z", "w")
)
```

```r
# 内连接：只保留两表都有的记录
inner_join(df1, df2, by = "id")

# 左连接：保留左表所有记录
left_join(df1, df2, by = "id")

# 右连接：保留右表所有记录
right_join(df1, df2, by = "id")

# 全连接：保留所有记录
full_join(df1, df2, by = "id")
```

当连接键名称不同时：

```r
df3 <- tibble(
  sample_id = c(2, 3, 4, 5),
  value3 = c("p", "q", "r", "s")
)

left_join(df1, df3, by = c("id" = "sample_id"))
```

<br>

## 6. 实战练习

使用 `flights` 数据集完成以下任务：

### 练习 1：数据筛选与排序

找出 2013 年 7 月从 JFK 机场起飞、延误超过 60 分钟的航班，并按延误时间降序排列：

```r
flights |> 
  filter(
    month == 7,
    origin == "JFK",
    dep_delay > 60
  ) |> 
  arrange(desc(dep_delay)) |> 
  select(month, day, carrier, flight, dep_delay, dest)
```

<br>

### 练习 2：分组汇总

计算每个航空公司的平均延误时间和航班总数，并按平均延误时间排序：

```r
flights |> 
  group_by(carrier) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    total_flights = n(),
    pct_delayed = mean(dep_delay > 0, na.rm = TRUE) * 100
  ) |> 
  arrange(desc(avg_delay))
```

<br>

### 练习 3：数据转换

创建一个按月份和航空公司汇总的宽格式表格：

```r
flights |> 
  group_by(month, carrier) |> 
  summarize(n = n(), .groups = "drop") |> 
  pivot_wider(
    names_from = carrier,
    values_from = n,
    values_fill = 0
  )
```

<br>

---

## 总结

本节介绍了 tidyverse 生态系统中两个最重要的包：

1. **dplyr**：提供了一套直观的"动词"函数进行数据操作
   - 行操作：`filter()`、`arrange()`、`distinct()`
   - 列操作：`select()`、`mutate()`、`rename()`、`relocate()`
   - 分组汇总：`group_by()`、`summarize()`、`slice_*()`
   - 表格连接：`*_join()` 系列函数

2. **tidyr**：专注于数据整理和格式转换
   - 长宽转换：`pivot_longer()`、`pivot_wider()`
   - 列的分离合并：`separate_*()`、`unite()`
   - 缺失值处理：`drop_na()`、`fill()`、`replace_na()`
   - 嵌套操作：`nest()`、`unnest()`
