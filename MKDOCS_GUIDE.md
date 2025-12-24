# MkDocs 文档网站使用指南

本仓库使用 MkDocs Material 构建文档网站。

## 本地预览

### 1. 安装依赖

```bash
pip install -r requirements.txt
```

或者单独安装：

```bash
pip install mkdocs mkdocs-material
```

### 2. 本地运行

在项目根目录运行：

```bash
mkdocs serve
```

然后在浏览器中访问 http://127.0.0.1:8000

### 3. 构建静态文件

```bash
mkdocs build
```

生成的静态文件会保存在 `site/` 目录下。

## 部署到 GitHub Pages

### 自动部署

推送到 `main` 分支后，GitHub Actions 会自动构建并部署文档到 GitHub Pages。

部署完成后，文档会发布到：https://hinna0818.github.io/Bioinfo-SMU/

### 手动部署

也可以手动部署：

```bash
mkdocs gh-deploy
```

## 文档结构

```
docs/
├── index.md                  # 首页
├── learning-path.md          # 学习路线
├── contributing.md           # 贡献指南
├── about.md                  # 关于
├── tools.md                  # 常用工具
├── resources.md              # 参考资料
├── Grade4/                   # 大四课程
│   ├── index.md
│   ├── computational_biology/
│   │   ├── index.md
│   │   ├── exp1.md
│   │   ├── exp2.md
│   │   ├── exp3.md
│   │   └── exp4.md
│   ├── CADD/
│   │   └── index.md
│   └── computational_molecular_biology/
│       └── index.md
└── javascripts/
    └── mathjax.js           # 数学公式支持
```

## 添加新页面

1. 在 `docs/` 目录下创建新的 `.md` 文件
2. 在 `mkdocs.yml` 的 `nav` 部分添加导航项

例如：

```yaml
nav:
  - 首页: index.md
  - 新页面: new-page.md
```

## Markdown 扩展

支持的 Markdown 扩展包括：

- 代码高亮
- 数学公式（LaTeX）
- Admonitions（提示框）
- 表格
- Emoji

详见 MkDocs Material 文档：https://squidfunk.github.io/mkdocs-material/

## 常见问题

### Q: 本地预览时修改不生效？

A: MkDocs 支持热重载，保存文件后会自动刷新。如果没有生效，尝试重启 `mkdocs serve`。

### Q: GitHub Pages 没有更新？

A: 检查 GitHub Actions 的运行状态，确保构建成功。也可能需要等待几分钟才能看到更新。

### Q: 数学公式不显示？

A: 确保在 `mkdocs.yml` 中启用了 `pymdownx.arithmatex` 扩展，并正确配置了 MathJax。
