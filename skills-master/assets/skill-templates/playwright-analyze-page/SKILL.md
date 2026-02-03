---
name: "playwright-analyze-page"
description: "连接调试版Chrome浏览器，分析当前页面的DOM结构、交互元素和CSS样式信息"
---

# Playwright 页面分析技能

通过 Playwright 连接调试版 Chrome 浏览器，自动捕获并分析当前活动页面的内容、DOM 结构、交互元素和 CSS 样式信息。

---

## When to Use

### 适用场景

| 场景 | 说明 |
|------|------|
| **分析任意网页** | 获取页面的完整 DOM 结构和样式信息 |
| **获取页面视觉快照** | 截取页面截图，提取颜色、字体、元素尺寸等信息 |
| **调试样式问题** | 当需要"看到"页面的真实视觉效果来诊断问题 |
| **验证 UI 实现** | 确认 UI 组件是否按设计稿正确渲染 |
| **分析浏览器扩展** | 检查扩展页面的视觉样式、布局和交互元素 |

---

## Workflow（执行流程）

### Step 1: 环境准备（首次使用）

如果尚未安装依赖，运行一键安装脚本：

```bash
# 进入技能目录执行安装
chmod +x scripts/setup.sh && ./scripts/setup.sh
```

安装完成后，会在当前项目创建 `scripts/debug/` 目录，包含所需的脚本文件。

---

### Step 2: 启动调试版 Chrome

**在新终端中执行：**
```bash
# 方式一：使用 npm script（推荐）
npm run debug:launch-chrome

# 方式二：直接执行脚本
./scripts/debug/launch-chrome.sh
```

**预期行为：**
- 启动 Chrome 浏览器
- 监听远程调试端口 9222
- 保留已安装的扩展配置

**验证启动成功：**
```bash
curl -s http://localhost:9222/json/version
```

---

### Step 3: 在 Chrome 中打开目标页面

在已启动的调试版 Chrome 中：
1. 导航到需要分析的目标页面
2. 如需分析扩展，点击扩展图标打开弹窗/侧边栏
3. 确保页面已完全加载

---

### Step 4: 执行页面分析

```bash
# 分析当前活动页面
npm run debug:connect

# 或指定特定标签页索引（默认为 0）
node scripts/debug/connect-cdp.js 0

# 分析特定元素的样式
node scripts/debug/connect-cdp.js 0 ".my-class" "#my-id"
```

---

### Step 5: 查看分析结果

**输出目录：** `debug-output/`

**生成的文件：**

| 文件名 | 内容 |
|--------|------|
| `screenshot.png` | 当前视口截图 |
| `screenshot-full.png` | 全页面截图 |
| `style-report.md` | 样式分析报告（人类可读） |
| `dom-tree.txt` | DOM 结构树 |
| `page-data.json` | 完整页面数据（JSON） |
| `accessibility-snapshot.json` | 无障碍快照 |

---

## 快速命令参考

| 命令 | 说明 |
|------|------|
| `npm run debug:launch-chrome` | 启动调试版 Chrome |
| `npm run debug:connect` | 连接并分析当前页面 |
| `npm run debug:styles` | 分析页面样式 |

---

## 环境变量配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DEBUG_OUTPUT_DIR` | `./debug-output` | 输出目录路径 |
| `CDP_PORT` | `9222` | Chrome 调试端口 |
| `CHROME_PATH` | 自动检测 | Chrome 可执行文件路径 |

---

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 端口被占用 | 已有 Chrome 实例 | `pkill -f "Google Chrome"` 后重试 |
| Chrome 未找到 | 非标准安装路径 | 设置 `CHROME_PATH` 环境变量 |
| 连接失败 | Chrome 未以调试模式启动 | 先运行 `debug:launch-chrome` |

---

## Installation（安装指南）

### 依赖要求

- Node.js 18+
- Google Chrome 浏览器
- npm / pnpm / yarn

### 安装步骤

```bash
# 1. 安装 playwright
npm install -D playwright

# 2. 运行安装脚本（自动配置）
chmod +x scripts/setup.sh && ./scripts/setup.sh
```

安装脚本会自动：
- 复制核心脚本到 `scripts/debug/` 目录
- 创建 `debug-output/` 输出目录
- 添加 npm scripts 到 `package.json`

---