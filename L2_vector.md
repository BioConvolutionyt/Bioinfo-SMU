# R vector introduction

## 1. 引言
在生信分析中，我们 90% 的时间都在和数据打交道。理解 R 的数据结构，是写出高效、可复现代码的基石。R 的常见数据结构包括：向量（Vector）、矩阵（Matrix）、列表（List）和数据框（Data Frame）。而向量是一切数据结构的基础，比如数据分析最常见的数据框(表格)文件，每一列就可以看作是一个特定类型的向量，所以掌握对向量的操作是很重要的。
本节重点讲解向量：如何创建、查看、索引、运算、处理缺失值，以及常见的向量相关函数。

<br>

## 2. 向量
向量是R中最基本的原子结构，必须包含同一类型的数据（要么全是数字，要么全是字符）。

<br>

### 2.1 向量的类型与长度
向量的类型可以用`typeof()`来求解，长度则是`length()`：

```r
x_num <- c(1, 2, 3)
x_chr <- c("a", "b", "c")
x_lgl <- c(TRUE, FALSE, TRUE)

typeof(x_num)
typeof(x_chr)
typeof(x_lgl)

length(x_num)
```

<br>

## 3. 创建向量
向量的创建是最常用的操作之一。下面按"用途"归纳常见函数。

<br>

### 3.1 直接拼接
最简单就是用`c()`函数来进行向量的生成：

```r
v0 <- c(3, 1, 2, 4)
v0

## 也可以设置混合类型
v00 <- c(3, "c", "FALSE")
v00

typeof(v00) # 统一成字符类型
```

<br>


### 3.2 序列生成
这里介绍一些简单的序列生成函数，可以动手自己运行来体会每个函数的用法。

```r
v1 <- 1:10 # 生成1到10
v2 <- seq(1, 10, by = 2) # by为步长，即间隔长度
v3 <- seq(1, 10, length.out = 5) # 5等分

v4 <- seq_len(10)                 # 用于循环计数
v5 <- seq_along(c(3, 1, 2, 4))    # 用于索引

v1; v2; v3; v4; v5
```

<br>

### 3.3 重复生成

```r
rep(1, 10)
rep(1:3, times = 2)  # 1 2 3 1 2 3
rep(1:3, each = 2)   # 1 1 2 2 3 3
```

<br>

### 3.4 字符向量拼接
如果需要进行字符串的拼接，比如生成gene1，gene2等，一个一个打会很麻烦，可以考虑使用：

```r
v_char1 <- paste("char", 1:10, sep = "")
v_char2 <- paste("gene", 1:5, sep = "_")
v_char3 <- paste0("cell", 1:5)
v_char4 <- sprintf("char%02d", 1:10)  # 01, 02, ... 10

v_char1; v_char2; v_char3; v_char4
```

<br>

### 3.5 分割字符串
注意：`strsplit()` 返回的是列表（因为每个字符串分割后可能长度不同）。

```r
v_split <- strsplit("a,b,c", ",")
v_split

# 取出第一个元素
v_split[[1]]
```

<br>


### 3.6 随机向量
因为向量是随机生成的，为了保证可复现性，引入随机种子来保证每次运行的结果是一致的：

```r
set.seed(2026) # 生成随机数种子 

runif(5)               # 均匀分布
rnorm(5, 0, 1)         # 正态分布
rbinom(10, 1, 0.3)      # 二项分布（0/1）

## 放回抽样
sample(1:10, 8, replace = TRUE)

## 不放回抽样
sample(1:10, 8, replace = FALSE) 
```

<br>

## 4. 查看与检索向量
有时候一个向量很长，不可能全部看完。这时候可以通过观察这个向量的一些基本特征，从而来了解向量元素的分布：

```r
v <- c(10, 20, 30, 40, 50)

v
head(v, 3) # 前3个
tail(v, 2) # 后2个

length(v) # 长度
typeof(v) # 精确类型
class(v) # 粗糙类型
str(v) # 结构
```

<br>

## 5. 索引与子集
R 中向量索引主要有三种：位置索引、逻辑索引、名称索引。

<br>

### 5.1 位置索引
即通过位置来取出向量的数据。

```r
v <- c(10, 20, 30, 40, 50)

v[1]
v[2:4]
v[c(1, 3, 5)]
v[-1]      # 去掉第一个
v[-c(2, 4)]
```

<br>

### 5.2 逻辑索引
通常我们需要取出满足一定条件的向量中的元素，这个时候就需要使用逻辑索引：

```r
v <- c(10, 20, 30, 40, 50)

v[v > 25] # 取出大于25的元素
v[v %% 20 == 0]  # 取出能被20整除的元素
```


<br>


### 5.3 名称索引
给向量加上`names`后，可以用名字索引，非常直观。

```r
v_named <- c(A = 10, B = 20, C = 30)
v_named
names(v_named)

v_named["B"]
v_named[c("A", "C")]
```

<br>

## 6. 向量运算
R中关于向量的很多运算默认是逐元素（element-wise），无需写循环就能高效计算。

```r
a <- 1:5
b <- 6:10

a + b
a * 2
a^2
sqrt(a)

mean(a)
sum(a)
sd(a)
```

<br>

### 6.1 广播
当两个向量长度不同，短向量会被"回收"重复使用：

```r
1:6 + c(10, 100)
```

这里后面的向量只有两个元素，而前面的向量有6个元素，所以短向量会被循环使用，即先自我复制，从而使两个向量的长度相等，再相加。

<br>

## 7. 缺失值处理
生信数据中 NA 很常见（测序深度不足、检测不到表达等）。很多函数默认遇到 NA 会返回 NA，需要显式处理。

```r
x <- c(1, 2, NA, 4, NA, 6)

is.na(x) # 返回每个元素是否为NA的逻辑值
sum(is.na(x)) # 返回该向量中为NA的元素个数

mean(x)                 # 会得到 NA
mean(x, na.rm = TRUE)   # 忽略 NA

x[!is.na(x)]            # 去掉 NA
na.omit(x)
```

<br>

## 8. 常用向量的处理函数
### 8.1 排序与去重
这一部分中，我最常用的函数就是`unique()`，使用这个函数可以看到该向量中有哪些唯一值，，在data.frame中（后面会提到），这样能够看到某个变量的取值情况，因为df的一个变量其实就是一个向量。

```r
x <- c(3, 1, 2, 2, 5, 1)

sort(x)
order(x)     # 返回排序后的索引
x[order(x)]

unique(x) # 看x中有哪些唯一值
```

<br>

当然，还可以用`summary()`和`table()`函数来看向量的分布情况，以及向量中某些元素出现的次数。如果在一个df中，这样就能最简单地来看某个变量的取值情况。比如，我想看一个数据库中人群年龄的分布情况：

```r
## 生成100个从40岁到80岁的年龄
age <- runif(n = 100, min = 40, max = 80) |> round(0)

summary(age)
table(age)
```

<br>


### 8.2 匹配与定位
比如我们要定位一个基因是否在某个基因向量里：

```r
genes <- c("TP53", "EGFR", "BRCA1", "MYC")
target <- c("EGFR", "MYC")

target %in% genes
which(genes %in% target)

match(target, genes)
```

<br>


### 8.3 集合运算

```r
a <- c("A", "B", "C")
b <- c("B", "C", "D")

intersect(a, b)  # 交集
union(a, b)      # 并集
setdiff(a, b)    # a 中有但 b 中没有
```

<br>

## 9. 综合思考题

### 题目：基因表达数据分析

假设你从一个RNA-seq实验中获得了一组基因的表达量数据（TPM值），请完成以下任务：

**背景数据：**

```r
set.seed(2026)

# 20个基因的表达量数据（含缺失值）
gene_names <- paste0("Gene", sprintf("%02d", 1:20))
expression <- c(runif(15, 0, 100), NA, NA, runif(3, 0, 100))
names(expression) <- gene_names

# 感兴趣的目标基因列表
target_genes <- c("Gene05", "Gene10", "Gene15", "Gene25")

# 已知的高表达基因阈值
high_expr_threshold <- 50
```

**请回答以下问题：**

1. **数据概览**：这个表达向量中有多少个缺失值？非缺失值的均值和标准差分别是多少？

2. **索引操作**：
   - 提取第3到第8个基因的表达量
   - 提取所有表达量大于`high_expr_threshold`（高表达阈值）的基因名称
   - 提取"Gene05"、"Gene12"和"Gene18"这三个基因的表达量

3. **缺失值处理**：创建一个新的向量`expression_clean`，去除所有缺失值，并将表达量从高到低排序

4. **匹配与定位**：
   - 判断`target_genes`中哪些基因存在于我们的数据中
   - 找出目标基因在原向量中的位置索引

5. **集合运算**：假设另一个实验的高表达基因为`c("Gene03", "Gene07", "Gene10", "Gene15", "Gene22")`，请找出：
   - 两个实验共有的高表达基因
   - 只在本实验中高表达的基因

6. **综合应用**：将所有非缺失表达量标准化到0-1范围（最小值变为0，最大值变为1），公式为：$x_{norm} = \frac{x - x_{min}}{x_{max} - x_{min}}$

<br>

**参考答案：**

```r
set.seed(2026)

# 数据准备
gene_names <- paste0("Gene", sprintf("%02d", 1:20))
expression <- c(runif(15, 0, 100), NA, NA, runif(3, 0, 100))
names(expression) <- gene_names
target_genes <- c("Gene05", "Gene10", "Gene15", "Gene25")
high_expr_threshold <- 50

# 1. 数据概览
sum(is.na(expression))
mean(expression, na.rm = TRUE)
sd(expression, na.rm = TRUE)

# 2. 索引操作
expression[3:8]
names(expression)[which(expression > high_expr_threshold)]
expression[c("Gene05", "Gene12", "Gene18")]

# 3. 缺失值处理与排序
expression_clean <- sort(na.omit(expression), decreasing = TRUE)
expression_clean

# 4. 匹配与定位
target_genes %in% names(expression)
match(target_genes[target_genes %in% names(expression)], names(expression))

# 5. 集合运算
my_high_genes <- names(expression)[which(expression > high_expr_threshold)]
other_high_genes <- c("Gene03", "Gene07", "Gene10", "Gene15", "Gene22")

intersect(my_high_genes, other_high_genes)
setdiff(my_high_genes, other_high_genes)

# 6. 标准化
expr_no_na <- expression[!is.na(expression)]
expr_normalized <- (expr_no_na - min(expr_no_na)) / (max(expr_no_na) - min(expr_no_na))
round(expr_normalized, 3)
```