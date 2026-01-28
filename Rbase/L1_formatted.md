# L1: R basic introduction

> **author**：Nan He，Southern Medical University
> **date**：2026.01.16

---

## 引言

本节主要介绍如何更高效地使用RStudio这个编辑器来进行R分析。主要内容包括：

- 三种常见的R包下载读取方式
- 文件的写入写出操作 
- R不同源文件的使用方法

---

## R包下载、读取和卸载

### R包下载

#### 1. CRAN下载

CRAN是大多数R包寄存的网站，是最基础的安装方式，适用于绝大多数通用的统计绘图包（如 `ggplot2`、`dplyr`）。

```r
## 安装ggplot2包
install.packages("ggplot2")

## 进阶：指定镜像（国内推荐清华或中科大源，速度快）
install.packages("ggplot2", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
```

> **小贴士**：使用国内镜像可以大大提高下载速度！

---

#### 2. Bioconductor下载

Bioconductor生态是R语言关于生物信息学分析的最大生态，绝大多数生信相关的R包都会放在上面。

安装方式与CRAN稍有不同，需要先装一个`BiocManager`的包，再用这个包来安装Bioconductor上的包：

```r
## 先安装BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

## 再用BiocManager安装你需要的包
BiocManager::install("limma")

## 同时也支持安装特定版本的包
BiocManager::install("limma", version = "3.18")
```

> **官方网站**：https://www.bioconductor.org/

---

#### 3. GitHub安装

很多新工具或开发中的包托管在GitHub，尚未发布到CRAN。你需要先安装`devtools`或`remotes`包：

```r
# 这里的 "username/repo" 对应 GitHub 网址末尾的部分
# 例如：https://github.com/tyRa/TCMDATA

# 方法 A: 使用 devtools
library(devtools)
install_github("tyRa/TCMDATA")

# 方法 B: 使用 remotes（更轻量级）
library(remotes)
install_github("tyRa/TCMDATA")
```

> **选择建议**：`remotes`更轻量级，`devtools`功能更全

---

#### 4. 本地源码安装

有时候因为网络问题，可以去GitHub仓库或CRAN里下载源代码文件（通常是`.tar.gz`/`.zip`格式），然后到本地安装：

```r
library(devtools)
install_local("regmedint-master.zip")
```

---

### R包读取

#### R包加载

```r
library(ggplot2)
require(dplyr)

## require一个没有下载的包
require(abcd)
```

> **注意区别**：
> - `library()`：如果包不存在会报错并停止运行
> - `require()`：如果包不存在只会警告，返回FALSE，不会停止运行

---

#### R包移除加载

当加载了太多包，发现函数名冲突时，可以暂时让包"退场"：

```r
# 注意格式：必须写成 "package:包名"
# unload=TRUE 表示彻底从内存中移除
detach("package:ggplot2", unload = TRUE)
```

---

### R包卸载

如果包彻底坏了需要重装，或者再也不用了：

```r
# 这会从你的硬盘上彻底删除该包的文件
remove.packages("ggplot2")
```

> **提示**：如果卸载失败，通常是因为该包正在被使用。请先重启R再运行卸载命令。

---

### 扩展：双冒号与三冒号

#### `::` 双冒号

调用该包对外**公开**的函数，有两个主要用途：

1. **避免函数名冲突**
```r
# 明确指定使用 dplyr 包的 filter 函数
dplyr::filter(mtcars, cyl == 6)
```

2. **节省内存**
```r
# 即使没有 library(dplyr)，这行代码也能跑
dplyr::select(mtcars, mpg, cyl)
```

#### `:::` 三冒号

强行调用该包的**内部/隐藏**函数：

```r
stats:::acf
```

或者使用`getFromNamespace()`：
```r
f <- getFromNamespace("add1", "stats")
f
```

---

## 文件的写入写出

让我们先生成一个示例数据：

```r
test_data <- data.frame(
  GeneID = c("TP53", "EGFR", "KRAS", "BRCA1"),
  LogFC = c(2.5, -1.2, 0.5, 3.1),
  PValue = c(0.001, 0.05, 0.8, 0.0001),
  Group = c("Up", "Down", "Stable", "Up"))

test_data
```

### CSV文件

CSV（逗号分隔值）是生信分析中最常用的交换格式，体积小，任何软件都能打开。

#### 写入CSV
```r
# 重点：row.names = FALSE
# 如果不加这个，R会自动把行号（1,2,3...）写成第一列，导致数据错位
write.csv(test_data, file = "gene_results.csv", row.names = FALSE)
```

#### 读取CSV
```r
df_base <- read.csv("gene_results.csv")

# 或者用readr的read_csv函数，更快
library(readr)
df_tidy <- read_csv("gene_results.csv")
```

---

### Excel文件

虽然分析时尽量不用Excel（容易被Excel自动改格式），但经常需要读取协作者发来的数据。

#### 使用openxlsx包
```r
library(openxlsx)

## 读xlsx
read.xlsx("gene_results.xlsx")

## 写xlsx
write.xlsx(test_data, path = "gene_results.xlsx")
```

#### 使用readxl包
```r
library(readxl)

# 读取第一个Sheet
df_excel <- read_xlsx("gene_results.xlsx")

# 读取指定Sheet（通过名字或索引）
# df_excel_2 <- read_xlsx("gene_results.xlsx", sheet = "Sheet1")
```

---

### TXT文件

很多生信原始数据（如GEO下载的矩阵）是`.txt`或`.tsv`格式。

#### 写入TXT
```r
# sep = "\t" 表示用制表符分隔（即TSV格式）
# quote = FALSE 表示不给字符加双引号（看起来更干净）
write.table(test_data, file = "gene_results.txt", 
            sep = "\t", row.names = FALSE, quote = FALSE)
```

#### 读取TXT
```r
# header = TRUE 表示第一行是列名
# sep = "\t" 必须与写入时一致
df_txt <- read.table("gene_results.txt", header = TRUE, sep = "\t")
```

---

### RDS文件

**这是R的"私有格式"**，可以把任何R对象（不仅仅是表格，还可以是列表、模型结果、Seurat对象等）完整地保存。

#### RDS的优点：

1. **保留属性**：CSV会把Factor变成Character，RDS则原样保存
2. **体积小**：自带压缩
3. **速度快**：读写速度远超CSV

#### 保存RDS
```r
# 保存任何对象
saveRDS(test_data, file = "gene_data.rds")
```

#### 读取RDS
```r
# 注意：readRDS需要赋值给一个变量
my_restored_data <- readRDS("gene_data.rds")
```

> **注意**：`readRDS`不会自动载入原来的变量名，需要手动赋值！

---

## R文件

R中最常见的文件类型：

### `.R` 脚本文件
- 用于写函数和本地开发
- 代码调试
- 服务器批量处理

### `.Rmd` 文档文件  
- 交互式笔记本
- 作业汇报
- 流程展示

### 服务器运行示例

在服务器上通常使用`.R`脚本：

```bash
# 直接运行
Rscript xxx.R

# 后台运行
nohup Rscript xxx.R &
```

---

## 总结

本节课程涵盖了R语言的基础操作：

**R包管理**：CRAN、Bioconductor、GitHub、本地安装  
**文件操作**：CSV、Excel、TXT、RDS格式  
**脚本类型**：`.R`脚本与`.Rmd`文档的区别使用  

> **下一步**：掌握这些基础操作后，就可以开始更复杂的数据分析之旅了！

---

*如有疑问，欢迎与作者交流讨论！*