# Playwright Pro - 前置准备指南

通过 CDP 连接本地浏览器进行页面分析，保留登录态、扩展和用户数据。

---

## 前置要求

| 依赖 | 最低版本 | 检查命令 |
|------|---------|---------|
| Node.js | 18+ | `node -v` |
| Chrome / Edge / Brave | 任意 | 已安装即可 |
| npm / pnpm / yarn | 任意 | `npm -v` 或 `pnpm -v` |
| jq（可选，推荐） | 任意 | `jq --version` |

> `jq` 用于自动修改 `package.json` 和 MCP 配置。如未安装，脚本会给出手动配置指引。

---

## 安装步骤

### 1. 将 playwright-pro 技能安装到 IDE

通过 skills-master 安装：

```bash
python3 skills/skills-master/scripts/install.py --name playwright-pro
```

安装后技能位于 `.codebuddy/skills/playwright-pro/`（或 `.trae/skills/playwright-pro/`）。

### 2. 在目标项目中运行 setup.sh

进入**你要分析的项目目录**（必须包含 `package.json`），执行：

```bash
chmod +x .codebuddy/skills/playwright-pro/scripts/setup.sh
.codebuddy/skills/playwright-pro/scripts/setup.sh
```

setup.sh 会自动完成：
- 安装 `playwright` 到项目的 devDependencies
- 复制 `launch-chrome.sh` 和 `connect-cdp.js` 到项目的 `scripts/debug/`
- 创建 `debug-output/` 输出目录
- 添加以下 npm scripts 到 `package.json`：
  - `debug:launch-chrome` — 启动调试浏览器
  - `debug:connect` — 完整页面分析
  - `debug:fast` — 快速分析（跳过网络和性能）
  - `debug:styles` — 仅样式分析

### 3. 配置 Playwright MCP（推荐）

> `launch-chrome.sh` 在启动成功后会**自动配置** Playwright MCP 的 `--cdp-endpoint`。如果你使用的 IDE 已有 Playwright MCP 配置，通常无需手动操作。

如果需要手动配置，在 IDE 的 MCP 配置文件中添加：

| IDE | 配置文件路径 |
|-----|-------------|
| CodeBuddy | `~/.codebuddy/mcp.json` |
| Cursor | `~/.cursor/mcp.json` |
| Trae | `~/.trae/mcp.json` |
| Windsurf | `~/.windsurf/mcp.json` |
| VS Code | `~/.vscode/mcp.json` |

配置内容：

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--cdp-endpoint",
        "http://localhost:9222"
      ]
    }
  }
}
```

**关键点**：`--cdp-endpoint http://localhost:9222` 让 Playwright MCP 连接到已启动的调试浏览器，而非启动一个无登录态的空白浏览器。

---

## 使用流程

```
setup.sh（首次，安装脚本到项目）
    ↓
launch-chrome.sh（启动带登录态的调试浏览器 + 自动配置 MCP）
    ↓
localhost:9222
    ↙           ↘
Playwright MCP     connect-cdp.js
（页面操作）         （页面分析报告）
导航、点击、输入      DOM、样式、网络、
截图、snapshot       性能、Console
```

### 日常使用三步走

```bash
# 1. 启动调试浏览器（克隆用户 profile，保留登录态）
npm run debug:launch-chrome

# 2. 在浏览器中打开目标页面

# 3. 分析页面
npm run debug:connect          # 完整分析
npm run debug:fast             # 快速分析（跳过网络和性能）
```

分析结果输出到 `debug-output/` 目录。

---

## 验证安装是否正确

```bash
# 1. 检查脚本文件是否存在
ls scripts/debug/launch-chrome.sh scripts/debug/connect-cdp.js

# 2. 启动调试浏览器
npm run debug:launch-chrome

# 3. 验证 CDP 端口可用
curl -s http://localhost:9222/json/version

# 4. 运行分析（应在 debug-output/ 生成报告文件）
npm run debug:connect
```

---

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `scripts/debug/` 下没有文件 | 未运行 setup.sh | 在项目目录中运行 `setup.sh` |
| `curl localhost:9222` 无响应 | 浏览器未以调试模式启动 | 运行 `npm run debug:launch-chrome` |
| 浏览器启动后端口不监听 | Chrome 实例冲突 / singleton lock | 关闭所有 Chrome 窗口后重试 |
| Playwright MCP 打开空白浏览器 | MCP 未配置 `--cdp-endpoint` | 运行 `launch-chrome.sh`（会自动配置），然后重启 IDE 的 MCP |
| `jq: command not found` | 未安装 jq | `brew install jq`（macOS）或按脚本提示手动配置 |
| `playwright` 依赖安装失败 | 网络问题 | 手动运行 `npm install -D playwright` |
