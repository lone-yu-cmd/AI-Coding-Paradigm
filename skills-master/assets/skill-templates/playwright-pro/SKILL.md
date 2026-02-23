---
name: "playwright-pro"
description: "增强版 Playwright 页面分析工具：通过 CDP 连接本地已运行的 Chrome/Edge/Brave，无需新开窗口，保留登录态和扩展，一键分析页面 DOM、样式、网络请求、Console 日志和性能指标"
---

# Playwright Pro - 增强版页面分析技能

通过 CDP 协议连接本地已运行的 Chromium 浏览器（Chrome/Edge/Brave），自动捕获并分析当前活动页面的内容、DOM 结构、交互元素、CSS 样式、网络请求、Console 日志和性能指标。

---

## 相比原生 Playwright 的增强

| 增强点 | 原生 Playwright | Playwright Pro |
|--------|----------------|----------------|
| **浏览器实例** | 每次启动全新的浏览器实例，空白状态 | 通过 CDP 连接本地已运行的浏览器，保留所有标签页和浏览状态 |
| **登录状态** | 新实例无任何登录态，需重新登录所有网站 | 支持复用用户默认 profile（`--use-default-profile`），直接使用现有 Cookie 和 Session |
| **浏览器扩展** | 默认不加载任何扩展，且不支持扩展分析 | 所有已安装的扩展均可用，还支持分析扩展页面的 DOM 和样式 |
| **多浏览器支持** | 仅支持 Chromium/Firefox/WebKit | 支持 Chrome、Edge、Brave 等所有 Chromium 内核浏览器（`--browser` 参数） |
| **使用方式** | 需编写脚本，通过代码控制浏览器导航 | 在浏览器中手动导航到目标页面，一条命令即可分析 |
| **标签页选择** | 需代码逻辑控制 | 支持按索引或 URL 关键字模糊匹配（`--url <keyword>`） |
| **输出能力** | 需手动编写分析逻辑和报告生成代码 | 自动生成截图、DOM 树、样式报告、无障碍快照等多维度输出 |
| **网络请求** | 需手动监听和记录 | 内置网络请求捕获，自动记录所有请求/响应/失败 |
| **Console 日志** | 需手动监听 | 内置 Console 日志捕获，包含 error/warn/log |
| **性能指标** | 需手动编写 Performance API 调用 | 内置 Web Vitals 采集（TTFB/FCP/LCP/CLS）和资源加载分析 |
| **元素分析** | 需手动编写选择器和样式提取逻辑 | 内置智能选择器，自动分析 button/input/header/card 等关键元素 |

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
| **分析需要登录的页面** | 使用 `--use-default-profile` 复用登录态，无需重新登录 |
| **性能诊断** | 获取 Web Vitals（TTFB/FCP/LCP/CLS）、资源加载和内存使用数据 |
| **API 调试** | 捕获页面所有网络请求，查看请求/响应/失败详情 |
| **Console 错误排查** | 捕获页面 Console 日志，快速定位 JS 错误和警告 |

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

### Step 2: 启动调试版浏览器

**在新终端中执行：**
```bash
# 方式一：使用独立 profile（默认，不影响现有浏览器数据）
npm run debug:launch-chrome

# 方式二：复用默认 profile（保留登录态、书签、扩展、历史记录）
npm run debug:launch-default

# 方式三：使用 Edge 或 Brave
./scripts/debug/launch-chrome.sh --browser edge
./scripts/debug/launch-chrome.sh --browser brave

# 方式四：Edge + 默认 profile + 自定义端口
./scripts/debug/launch-chrome.sh --browser edge --use-default-profile --port 9333
```

**预期行为：**
- 如果检测到已有调试端口可用，直接使用，无需重启浏览器
- 如果浏览器正在运行但无调试端口，提示选择重启方式
- 支持 Chrome、Edge、Brave 三种浏览器
- `--use-default-profile` 模式复用所有用户数据

**验证启动成功：**
```bash
curl -s http://localhost:9222/json/version
```

---

### Step 3: 在浏览器中打开目标页面

在已启动的调试版浏览器中：
1. 导航到需要分析的目标页面
2. 如需分析扩展，点击扩展图标打开弹窗/侧边栏
3. 确保页面已完全加载

---

### Step 4: 执行页面分析

```bash
# 完整分析（包含网络请求、Console、性能指标）
npm run debug:connect

# 快速分析（跳过网络请求和性能指标，更快完成）
npm run debug:fast

# 指定标签页索引
node scripts/debug/connect-cdp.js 1

# 按 URL 关键字选择标签页
node scripts/debug/connect-cdp.js --url github

# 按 URL 关键字 + 自定义选择器
node scripts/debug/connect-cdp.js --url "my-app" ".my-class" "#my-id"

# 跳过部分功能
node scripts/debug/connect-cdp.js --no-network --no-console --no-perf

# 自定义网络请求捕获等待时间（默认 5 秒）
node scripts/debug/connect-cdp.js --network-wait 10
```

---

### Step 5: 查看分析结果

**输出目录：** `debug-output/`

**生成的文件：**

| 文件名 | 内容 |
|--------|------|
| `screenshot.png` | 当前视口截图 |
| `screenshot-full.png` | 全页面截图 |
| `style-report.md` | 综合分析报告（样式+性能+网络+Console 摘要） |
| `dom-tree.txt` | DOM 结构树 |
| `page-data.json` | 完整页面数据（JSON） |
| `accessibility-snapshot.json` | 无障碍快照 |
| `network-requests.json` | 网络请求日志（含请求/响应/时间线） |
| `console-logs.json` | Console 日志（error/warn/log/info） |
| `performance-metrics.json` | 性能指标（Web Vitals + 资源加载 + 内存） |

---

## 快速命令参考

| 命令 | 说明 |
|------|------|
| `npm run debug:launch-chrome` | 启动调试版浏览器（独立 profile） |
| `npm run debug:launch-default` | 启动调试版浏览器（复用默认 profile） |
| `npm run debug:connect` | 完整分析当前页面 |
| `npm run debug:fast` | 快速分析（跳过网络和性能） |
| `npm run debug:styles` | 仅分析样式 |

---

## 命令行参数

### launch-chrome.sh

| 参数 | 说明 |
|------|------|
| `--use-default-profile` | 复用用户默认 profile（保留登录态、书签等） |
| `--browser <name>` | 指定浏览器：`chrome`（默认）、`edge`、`brave` |
| `--port <number>` | 调试端口（默认：9222） |

### connect-cdp.js

| 参数 | 说明 |
|------|------|
| `<number>` | 标签页索引（默认：0） |
| `--url <keyword>` | 按 URL 或标题关键字模糊匹配标签页 |
| `--no-network` | 跳过网络请求捕获 |
| `--no-console` | 跳过 Console 日志捕获 |
| `--no-perf` | 跳过性能指标采集 |
| `--network-wait <seconds>` | 网络请求捕获等待时间（默认：5 秒） |

---

## 环境变量配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DEBUG_OUTPUT_DIR` | `./debug-output` | 输出目录路径 |
| `CDP_PORT` | `9222` | 浏览器调试端口 |
| `CHROME_PATH` | 自动检测 | 浏览器可执行文件路径 |
| `BROWSER_TYPE` | `chrome` | 浏览器类型：chrome/edge/brave |

---

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 端口被占用 | 已有浏览器实例 | 脚本会自动检测已有调试端口并复用 |
| 浏览器未找到 | 非标准安装路径 | 设置 `CHROME_PATH` 或使用 `--browser` 参数 |
| 连接失败 | 浏览器未以调试模式启动 | 先运行 `debug:launch-chrome` |
| 想保留登录态 | 使用独立 profile 启动 | 使用 `--use-default-profile` 选项 |
| 标签页太多找不到 | 索引方式不方便 | 使用 `--url <关键字>` 按 URL 匹配 |
| 分析太慢 | 网络请求捕获需刷新页面 | 使用 `debug:fast` 或 `--no-network` |

---

## Installation（安装指南）

### 依赖要求

- Node.js 18+
- Chromium 内核浏览器（Chrome / Edge / Brave）
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
