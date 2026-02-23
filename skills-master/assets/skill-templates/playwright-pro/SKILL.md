---
name: "playwright-pro"
description: "增强版 Playwright 页面分析工具：MUST 通过 CDP 连接本地 Chrome/Edge/Brave（保留登录态和扩展），NEVER 使用原生 Playwright 启动新浏览器实例。一键分析页面 DOM、样式、网络请求、Console 日志和性能指标"
---

# Playwright Pro - 增强版页面分析技能

> **CRITICAL**: 本技能 **MUST** 通过 CDP（Chrome DevTools Protocol）连接用户本地已运行的浏览器。**NEVER** 使用 Playwright 的 `chromium.launch()` 或 `browser.newPage()` 启动新浏览器实例。这样做是为了**保留用户的登录态、账号信息和浏览器扩展**。

---

## 强制约束（NEVER 违反）

以下规则具有最高优先级，**NEVER** 在任何情况下违反：

1. **NEVER** 调用 `playwright.chromium.launch()`、`playwright.firefox.launch()` 或任何 `browser.launch()` 方法
2. **NEVER** 使用 `browser.newContext()` 或 `browser.newPage()` 创建新的浏览器上下文
3. **NEVER** 自行拼接 Chrome/Edge/Brave 启动命令（如 `nohup "/Applications/Google Chrome.app/..." --remote-debugging-port=9222 ...`），因为手动拼接缺少 singleton lock 处理、端口检测、等待逻辑等关键步骤，**极易导致端口始终无法监听等问题**
4. **MUST** 始终使用本技能提供的 `launch-chrome.sh` 脚本启动浏览器（该脚本已处理所有边界情况）
5. **MUST** 始终使用本技能提供的 `connect-cdp.js` 脚本连接浏览器（底层通过 `chromium.connectOverCDP()` 实现）
6. **MUST** 在连接前确认 CDP 端口（默认 9222）可用，如不可用则先用脚本启动调试版浏览器

### 为什么必须用 CDP 连接本地浏览器？

- **保留登录态**：Cookie、Session、Token 等认证信息保存在本地浏览器 Profile 中，CDP 连接直接复用
- **保留账号信息**：Google、GitHub、各类 SaaS 平台登录态均保留
- **保留浏览器扩展**：已安装的扩展在 CDP 连接时保持可用
- **真实用户环境**：分析用户真实浏览环境下的页面，而非无状态的干净浏览器

### 为什么 NEVER 自行拼接 Chrome 启动命令？

手动拼接 `"/Applications/Google Chrome.app/..." --remote-debugging-port=9222` 会遇到以下问题：
- **singleton lock**：Chrome 已有实例运行时，新进程会因 lock 文件而无法正确启用调试端口
- **端口始终不监听**：即使启动命令看起来正确，端口也可能因为 profile 冲突而永远无法就绪
- **缺少等待和重试逻辑**：需要正确等待浏览器初始化完成后端口才可用
- **缺少进程冲突检测**：需要先检测是否有已运行的 Chrome 实例占用资源

`launch-chrome.sh` 脚本已处理以上所有边界情况，**MUST** 使用它来启动浏览器。

---

## Workflow（强制执行流程）

使用本技能时，**MUST** 严格按照以下顺序执行，**NEVER** 跳过任何步骤。

### Step 1: 检查项目是否已安装 playwright-pro 脚本

**MUST** 先检查目标项目中是否存在本技能的脚本文件：

```bash
ls scripts/debug/launch-chrome.sh scripts/debug/connect-cdp.js 2>/dev/null
```

- 如果两个文件都存在 → 跳到 Step 2
- 如果文件不存在 → **MUST** 先运行安装脚本：
  ```bash
  # SKILL_DIR 是本技能的安装目录（如 .codebuddy/skills/playwright-pro 或 .trae/skills/playwright-pro）
  chmod +x ${SKILL_DIR}/scripts/setup.sh && ${SKILL_DIR}/scripts/setup.sh
  ```
  安装脚本会自动：
  - 安装 playwright 依赖
  - 复制 `launch-chrome.sh` 和 `connect-cdp.js` 到项目的 `scripts/debug/` 目录
  - 创建 `debug-output/` 输出目录
  - 添加 `debug:launch-chrome`、`debug:connect` 等 npm scripts 到 `package.json`

### Step 2: 检查 CDP 连接是否可用

**MUST** 检查调试端口是否已就绪：

```bash
curl -s http://localhost:9222/json/version
```

- 如果返回 JSON 数据 → CDP 已就绪，跳到 Step 4
- 如果连接失败 → 进入 Step 3 启动浏览器

### Step 3: 使用脚本启动调试版浏览器

**MUST** 使用本技能提供的 `launch-chrome.sh` 脚本启动浏览器，**NEVER** 自行拼接启动命令：

```bash
# 方式一：默认启动（复用用户 profile，保留登录态、书签、扩展、历史记录）
npm run debug:launch-chrome

# 方式二：使用独立调试 profile（不含登录态和浏览器数据）
npm run debug:launch-isolated

# 方式三：直接调用脚本（默认复用用户 profile）
./scripts/debug/launch-chrome.sh
./scripts/debug/launch-chrome.sh --yes                 # 非交互模式（AI/CI 使用）
./scripts/debug/launch-chrome.sh --isolated-profile    # 独立 profile

# 方式四：使用 Edge 或 Brave
./scripts/debug/launch-chrome.sh --browser edge
./scripts/debug/launch-chrome.sh --browser brave
```

**脚本内置的处理逻辑（这就是为什么 MUST 使用脚本而非手动拼命令）：**
- 自动检测已有调试端口并复用，无需重启浏览器
- 检测 Chrome singleton lock 冲突并正确处理
- 自动关闭无调试端口的 Chrome 实例后重启
- 内置端口就绪等待和重试逻辑（最多等待 15 秒）
- 跨平台浏览器路径自动检测（macOS/Linux/Windows）

**如果脚本因需要交互确认而阻塞**（如提示"是否关闭 Chrome"），使用 `--yes` 参数：
```bash
# npm scripts 已默认带 --yes 参数，不会阻塞
npm run debug:launch-chrome

# 直接调用脚本时加 --yes
./scripts/debug/launch-chrome.sh --yes
```
注意：关闭后仍然 **MUST** 使用脚本重新启动，**NEVER** 自行拼接 Chrome 命令。

**启动后 MUST 验证：**
```bash
curl -s http://localhost:9222/json/version
```

### Step 4: 在浏览器中导航到目标页面

在已启动的调试版浏览器中：
1. 导航到需要分析的目标页面
2. 如需分析扩展，点击扩展图标打开弹窗/侧边栏
3. 确保页面已完全加载

### Step 5: 通过脚本连接 CDP 并分析页面

**MUST** 使用本技能提供的 `connect-cdp.js` 脚本分析页面：

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

### Step 6: 查看分析结果

**输出目录：** `debug-output/`

| 文件名 | 内容 |
|--------|------|
| `screenshot.png` | 当前视口截图 |
| `screenshot-full.png` | 全页面截图 |
| `style-report.md` | 综合分析报告（样式+性能+网络+Console 摘要） |
| `dom-tree.txt` | DOM 结构树 |
| `page-data.json` | 完整页面数据（JSON） |
| `accessibility-snapshot.txt` | 无障碍快照（ARIA） |
| `network-requests.json` | 网络请求日志（含请求/响应/时间线） |
| `console-logs.json` | Console 日志（error/warn/log/info） |
| `performance-metrics.json` | 性能指标（Web Vitals + 资源加载 + 内存） |

---

## 快速命令参考

| 顺序 | 命令 | 说明 |
|------|------|------|
| 0 | `${SKILL_DIR}/scripts/setup.sh` | **首次使用 MUST 执行**：安装脚本到目标项目 |
| 1 | `curl -s http://localhost:9222/json/version` | 检查 CDP 是否就绪 |
| 2 | `npm run debug:launch-chrome` | 启动调试版浏览器（默认复用用户 profile，保留登录态） |
| 2 | `npm run debug:launch-isolated` | 启动调试版浏览器（独立 profile，无登录态） |
| 3 | `npm run debug:connect` | 通过 CDP 完整分析当前页面 |
| 3 | `npm run debug:fast` | 通过 CDP 快速分析（跳过网络和性能） |
| 3 | `npm run debug:styles` | 通过 CDP 仅分析样式 |

---

## 命令行参数

### launch-chrome.sh

| 参数 | 说明 |
|------|------|
| `--isolated-profile` | 使用独立调试 profile（不含登录态和浏览器数据） |
| `--yes`, `-y` | 非交互模式，自动确认所有提示（AI/CI 调用推荐） |
| `--browser <name>` | 指定浏览器：`chrome`（默认）、`edge`、`brave` |
| `--port <number>` | 调试端口（默认：9222） |

> **注意**：默认复用用户的浏览器 profile（保留登录态），无需额外参数。

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
| `CDP_PORT` | `9222` | 浏览器 CDP 调试端口 |
| `CHROME_PATH` | 自动检测 | 浏览器可执行文件路径 |
| `BROWSER_TYPE` | `chrome` | 浏览器类型：chrome/edge/brave |

---

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 脚本不存在 | 未运行 setup.sh | **MUST** 先运行 `${SKILL_DIR}/scripts/setup.sh` 安装脚本到项目 |
| `curl localhost:9222` 无响应 | 浏览器未以调试模式启动 | **MUST** 使用 `launch-chrome.sh` 脚本启动，**NEVER** 手动拼命令 |
| 端口始终不监听 | 手动拼接 Chrome 命令导致 singleton lock | 关闭所有 Chrome 后使用 `launch-chrome.sh` 脚本重新启动 |
| 端口被占用 | 已有浏览器实例占用端口 | 脚本会自动检测已有调试端口并复用 |
| 浏览器未找到 | 非标准安装路径 | 设置 `CHROME_PATH` 或使用 `--browser` 参数 |
| 需要保留登录态 | 默认行为 | 默认已复用用户 profile，无需额外参数 |
| 不需要登录态 | 想用干净浏览器 | 使用 `--isolated-profile` 参数 |
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
# 运行安装脚本（自动配置一切）
chmod +x ${SKILL_DIR}/scripts/setup.sh && ${SKILL_DIR}/scripts/setup.sh
```

安装脚本会自动：
- 安装 playwright 到项目依赖
- 复制 `launch-chrome.sh` 和 `connect-cdp.js` 到 `scripts/debug/` 目录
- 创建 `debug-output/` 输出目录
- 添加 npm scripts 到 `package.json`

---
