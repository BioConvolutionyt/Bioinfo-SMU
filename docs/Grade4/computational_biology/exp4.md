# 实验四：qPCR 数据分析

## 📖 实验简介

qPCR（实时荧光定量 PCR）是分子生物学中常用的基因表达定量技术。本实验学习如何处理和分析 qPCR 数据。

---

## 🎯 实验目的

- 理解 qPCR 原理和数据格式
- 掌握 Ct 值的处理方法
- 学会相对表达量的计算（ΔΔCt 方法）
- 进行统计检验和可视化

---

## 📚 理论背景

### qPCR 原理

实时荧光定量 PCR 通过实时监测 PCR 反应中荧光信号的变化来定量 DNA/RNA 模板。

### Ct 值

**Ct (Cycle threshold)**：荧光信号达到设定阈值时的循环数。

- Ct 值越小，表示起始模板量越多
- Ct 值与起始模板量呈对数关系

### ΔΔCt 方法

相对定量的标准方法：

$$
\Delta Ct = Ct_{目标基因} - Ct_{内参基因}
$$

$$
\Delta\Delta Ct = \Delta Ct_{实验组} - \Delta Ct_{对照组}
$$

$$
相对表达量 = 2^{-\Delta\Delta Ct}
$$

---

## 💻 实验步骤

### 1. 数据导入和检查

```r
library(ggplot2)
library(dplyr)
library(tidyr)

# 读取数据
qpcr_data <- read.csv("qPCR_data.csv")

# 查看数据结构
head(qpcr_data)
str(qpcr_data)

# 数据格式示例：
# Sample    Gene      Ct    Group
# Sample1   GAPDH     18.5  Control
# Sample1   Gene1     22.3  Control
# ...
```

### 2. 数据质控

```r
# 检查技术重复的一致性
qpcr_summary <- qpcr_data %>%
  group_by(Sample, Gene, Group) %>%
  summarise(
    mean_Ct = mean(Ct, na.rm = TRUE),
    sd_Ct = sd(Ct, na.rm = TRUE),
    cv = sd_Ct / mean_Ct * 100,  # 变异系数
    .groups = "drop"
  )

# 标记CV过大的数据点（通常>2%需要注意）
qpcr_summary$qc_flag <- ifelse(qpcr_summary$cv > 2, "Check", "Pass")

# 可视化技术重复的一致性
ggplot(qpcr_summary, aes(x = Gene, y = cv, fill = qc_flag)) +
  geom_bar(stat = "identity") +
  geom_hline(yintercept = 2, linetype = "dashed", color = "red") +
  labs(title = "Coefficient of Variation for Technical Replicates",
       x = "Gene",
       y = "CV (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

### 3. 计算 ΔCt

```r
# 分离内参基因（假设为 GAPDH）
housekeeping_gene <- "GAPDH"

# 获取每个样本的内参 Ct 值
hk_ct <- qpcr_summary %>%
  filter(Gene == housekeeping_gene) %>%
  select(Sample, Group, hk_Ct = mean_Ct)

# 计算 ΔCt
delta_ct <- qpcr_summary %>%
  filter(Gene != housekeeping_gene) %>%
  left_join(hk_ct, by = c("Sample", "Group")) %>%
  mutate(delta_Ct = mean_Ct - hk_Ct)

head(delta_ct)
```

### 4. 计算 ΔΔCt 和相对表达量

```r
# 计算对照组的平均 ΔCt
control_delta_ct <- delta_ct %>%
  filter(Group == "Control") %>%
  group_by(Gene) %>%
  summarise(control_mean_delta_Ct = mean(delta_Ct), .groups = "drop")

# 计算 ΔΔCt
ddct_data <- delta_ct %>%
  left_join(control_delta_ct, by = "Gene") %>%
  mutate(
    delta_delta_Ct = delta_Ct - control_mean_delta_Ct,
    relative_expression = 2^(-delta_delta_Ct)
  )

head(ddct_data)
```

### 5. 统计检验

```r
# t检验比较实验组和对照组
stat_results <- ddct_data %>%
  group_by(Gene) %>%
  summarise(
    control_mean = mean(relative_expression[Group == "Control"]),
    treatment_mean = mean(relative_expression[Group == "Treatment"]),
    fold_change = treatment_mean / control_mean,
    p_value = t.test(relative_expression ~ Group)$p.value,
    .groups = "drop"
  ) %>%
  mutate(
    significant = ifelse(p_value < 0.05, "Yes", "No"),
    regulation = case_when(
      fold_change > 1.5 & p_value < 0.05 ~ "Up",
      fold_change < 0.67 & p_value < 0.05 ~ "Down",
      TRUE ~ "No change"
    )
  )

print(stat_results)
```

### 6. 数据可视化

#### 条形图

```r
# 计算均值和标准误
plot_data <- ddct_data %>%
  group_by(Gene, Group) %>%
  summarise(
    mean_expr = mean(relative_expression),
    se = sd(relative_expression) / sqrt(n()),
    .groups = "drop"
  )

# 绘制条形图
ggplot(plot_data, aes(x = Gene, y = mean_expr, fill = Group)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_errorbar(aes(ymin = mean_expr - se, ymax = mean_expr + se),
                position = position_dodge(width = 0.9),
                width = 0.25) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
  labs(title = "Relative Gene Expression",
       x = "Gene",
       y = "Relative Expression (2^-ΔΔCt)",
       fill = "Group") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

#### 箱线图

```r
ggplot(ddct_data, aes(x = Gene, y = relative_expression, fill = Group)) +
  geom_boxplot() +
  geom_jitter(position = position_jitterdodge(jitter.width = 0.2),
              alpha = 0.5, size = 1) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
  labs(title = "Relative Gene Expression Distribution",
       x = "Gene",
       y = "Relative Expression (2^-ΔΔCt)",
       fill = "Group") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

#### 火山图（如果有多个基因）

```r
ggplot(stat_results, aes(x = log2(fold_change), y = -log10(p_value))) +
  geom_point(aes(color = regulation), size = 3) +
  scale_color_manual(values = c("Up" = "red", "Down" = "blue", "No change" = "gray")) +
  geom_vline(xintercept = c(-log2(1.5), log2(1.5)), linetype = "dashed") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
  geom_text(aes(label = Gene), vjust = -0.5, size = 3) +
  labs(title = "Volcano Plot",
       x = "log2(Fold Change)",
       y = "-log10(p-value)",
       color = "Regulation") +
  theme_minimal()
```

---

## 📊 结果解释

### 相对表达量

- **= 1**：表达量与对照组相同
- **> 1**：表达上调
- **< 1**：表达下调

### Fold Change

- **FC > 1.5 且 p < 0.05**：显著上调
- **FC < 0.67 且 p < 0.05**：显著下调

---

## 🔍 注意事项

!!! warning "实验设计"
    - 确保技术重复（至少3次）
    - 生物学重复建议≥3个
    - 选择合适稳定的内参基因

!!! warning "数据质控"
    - Ct > 35 通常认为不可靠
    - 技术重复的 CV 应 < 2%
    - 内参基因在不同组间应稳定

!!! tip "内参基因选择"
    常用内参基因：GAPDH、β-actin、18S rRNA
    
    内参基因应：
    - 表达稳定
    - 不受实验条件影响
    - 表达量适中

---

## 📝 作业要求

1. **数据分析**
   - 导入并检查数据
   - 进行质量控制
   - 计算相对表达量

2. **统计分析**
   - 进行 t 检验
   - 判断哪些基因显著差异表达
   - 计算 fold change

3. **结果可视化**
   - 绘制条形图和箱线图
   - 添加误差线和统计显著性标记
   - 图表美观、标注清晰

4. **结果解释**
   - 对差异基因的生物学意义进行讨论
   - 与已知文献比较
   - 提出进一步验证的思路

---

## 📁 文件位置

```
Grade4/computational_biology/experiments/Exp4/
├── Exp4.Rmd          # R Markdown 报告
├── Exp4.html         # 生成的 HTML 报告
└── qPCR_data.csv     # qPCR 数据
```

---

## 📚 参考资料

1. Livak, K. J., & Schmittgen, T. D. (2001). Analysis of relative gene expression data using real-time quantitative PCR and the 2− ΔΔCT method. *Methods*, 25(4), 402-408.

2. Bustin, S. A., et al. (2009). The MIQE guidelines: minimum information for publication of quantitative real-time PCR experiments. *Clinical Chemistry*, 55(4), 611-622.

---

## 💡 提示

!!! tip "PCR 效率"
    本实验假设 PCR 效率为 100%（扩增效率 = 2）。如果效率不是 100%，需要使用修正公式：
    
    $$相对表达量 = E^{-\Delta\Delta Ct}$$
    
    其中 E 是实际的扩增效率。

!!! tip "多重比较校正"
    如果检测多个基因，考虑进行 Bonferroni 或 FDR 校正。

---

[← 上一个实验：MCL & RWR](exp3.md) | [返回课程主页](index.md)
