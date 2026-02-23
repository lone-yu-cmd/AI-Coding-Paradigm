#!/bin/bash

# =============================================================================
# Playwright Pro - Chrome Debug Mode Launcher
# 
# 功能：启动带有远程调试端口的 Chromium 浏览器（Chrome/Edge/Brave）
# 用途：允许 Playwright 连接到已运行的浏览器实例
# 
# 使用方法：
#   ./launch-chrome.sh [选项]
#   
# 选项：
#   --use-default-profile   复用用户默认的浏览器 profile（保留登录态、书签等）
#   --browser <name>        指定浏览器：chrome（默认）、edge、brave
#   --port <number>         调试端口（默认：9222）
#   --help                  显示帮助信息
#
# 环境变量：
#   DEBUG_PORT   - 调试端口（默认：9222）
#   CHROME_PATH  - 浏览器可执行文件路径（自动检测）
#   BROWSER_TYPE - 浏览器类型：chrome/edge/brave（默认：chrome）
# =============================================================================

# 默认配置
DEBUG_PORT=${DEBUG_PORT:-9222}
BROWSER_TYPE=${BROWSER_TYPE:-chrome}
USE_DEFAULT_PROFILE=false

# =============================================================================
# 参数解析
# =============================================================================

show_help() {
    echo "Playwright Pro - Chrome Debug Mode Launcher"
    echo ""
    echo "用法: ./launch-chrome.sh [选项]"
    echo ""
    echo "选项:"
    echo "  --use-default-profile   复用用户默认 profile（保留登录态、书签、历史记录）"
    echo "  --browser <name>        指定浏览器: chrome (默认), edge, brave"
    echo "  --port <number>         调试端口（默认: 9222）"
    echo "  --help                  显示此帮助信息"
    echo ""
    echo "环境变量:"
    echo "  DEBUG_PORT    调试端口（默认: 9222）"
    echo "  CHROME_PATH   浏览器可执行文件路径（自动检测）"
    echo "  BROWSER_TYPE  浏览器类型: chrome/edge/brave（默认: chrome）"
    echo ""
    echo "示例:"
    echo "  ./launch-chrome.sh                                # 使用独立 profile 启动 Chrome"
    echo "  ./launch-chrome.sh --use-default-profile          # 复用默认 profile"
    echo "  ./launch-chrome.sh --browser edge                 # 使用 Edge"
    echo "  ./launch-chrome.sh --browser brave --port 9333    # Brave + 自定义端口"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --use-default-profile)
            USE_DEFAULT_PROFILE=true
            shift
            ;;
        --browser)
            BROWSER_TYPE="$2"
            shift 2
            ;;
        --port)
            DEBUG_PORT="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            echo "使用 --help 查看帮助"
            exit 1
            ;;
    esac
done

# =============================================================================
# 浏览器检测（支持 Chrome / Edge / Brave）
# =============================================================================

detect_browser_path() {
    local browser="$1"
    
    case "$browser" in
        chrome)
            # macOS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                local p="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
                [[ -f "$p" ]] && echo "$p" && return 0
            fi
            # Linux
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                for cmd in "google-chrome" "google-chrome-stable" "chromium" "chromium-browser"; do
                    command -v "$cmd" &>/dev/null && echo "$cmd" && return 0
                done
            fi
            # Windows (Git Bash / WSL)
            if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
                for p in "/c/Program Files/Google/Chrome/Application/chrome.exe" \
                         "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"; do
                    [[ -f "$p" ]] && echo "$p" && return 0
                done
            fi
            ;;
        edge)
            # macOS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                local p="/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
                [[ -f "$p" ]] && echo "$p" && return 0
            fi
            # Linux
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                for cmd in "microsoft-edge" "microsoft-edge-stable" "microsoft-edge-dev"; do
                    command -v "$cmd" &>/dev/null && echo "$cmd" && return 0
                done
            fi
            # Windows
            if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
                for p in "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
                         "/c/Program Files/Microsoft/Edge/Application/msedge.exe"; do
                    [[ -f "$p" ]] && echo "$p" && return 0
                done
            fi
            ;;
        brave)
            # macOS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                local p="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
                [[ -f "$p" ]] && echo "$p" && return 0
            fi
            # Linux
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                for cmd in "brave-browser" "brave-browser-stable" "brave"; do
                    command -v "$cmd" &>/dev/null && echo "$cmd" && return 0
                done
            fi
            # Windows
            if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
                local p="/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe"
                [[ -f "$p" ]] && echo "$p" && return 0
            fi
            ;;
        *)
            echo ""
            return 1
            ;;
    esac
    
    return 1
}

# 获取浏览器默认 profile 路径
get_default_profile_dir() {
    local browser="$1"
    
    case "$browser" in
        chrome)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "$HOME/Library/Application Support/Google/Chrome"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                echo "$HOME/.config/google-chrome"
            else
                echo "$LOCALAPPDATA/Google/Chrome/User Data"
            fi
            ;;
        edge)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "$HOME/Library/Application Support/Microsoft Edge"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                echo "$HOME/.config/microsoft-edge"
            else
                echo "$LOCALAPPDATA/Microsoft/Edge/User Data"
            fi
            ;;
        brave)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                echo "$HOME/.config/BraveSoftware/Brave-Browser"
            else
                echo "$LOCALAPPDATA/BraveSoftware/Brave-Browser/User Data"
            fi
            ;;
    esac
}

# 获取浏览器显示名称
get_browser_display_name() {
    case "$1" in
        chrome) echo "Google Chrome" ;;
        edge)   echo "Microsoft Edge" ;;
        brave)  echo "Brave Browser" ;;
        *)      echo "$1" ;;
    esac
}

# 获取浏览器进程匹配模式
get_browser_process_pattern() {
    case "$1" in
        chrome) echo "Google Chrome" ;;
        edge)   echo "Microsoft Edge" ;;
        brave)  echo "Brave Browser" ;;
        *)      echo "$1" ;;
    esac
}

# =============================================================================
# 检测与连接逻辑
# =============================================================================

# 检查端口是否被监听
check_port() {
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
        lsof -i :$DEBUG_PORT >/dev/null 2>&1
    else
        netstat -an | grep ":$DEBUG_PORT" >/dev/null 2>&1
    fi
}

# 尝试连接已有的调试端口
try_connect_existing() {
    if check_port; then
        # 验证是否是有效的 CDP 端口
        local response=$(curl -s --connect-timeout 2 "http://127.0.0.1:$DEBUG_PORT/json/version" 2>/dev/null)
        if [[ -n "$response" ]]; then
            local browser_name=$(echo "$response" | grep -o '"Browser":"[^"]*"' | cut -d'"' -f4)
            echo ""
            echo "✅ 检测到已有浏览器调试实例"
            echo "   浏览器: $browser_name"
            echo "   端口: $DEBUG_PORT"
            echo "   可以直接运行分析脚本连接"
            return 0
        fi
    fi
    return 1
}

# =============================================================================
# 主逻辑
# =============================================================================

BROWSER_DISPLAY_NAME=$(get_browser_display_name "$BROWSER_TYPE")
BROWSER_PROCESS=$(get_browser_process_pattern "$BROWSER_TYPE")

# 使用环境变量或自动检测浏览器路径
BROWSER_PATH=${CHROME_PATH:-$(detect_browser_path "$BROWSER_TYPE")}

if [[ -z "$BROWSER_PATH" ]]; then
    echo "❌ 无法找到 $BROWSER_DISPLAY_NAME"
    echo ""
    echo "   可用选项："
    echo "   1. 设置 CHROME_PATH 环境变量指向浏览器可执行文件"
    echo "   2. 使用 --browser 参数选择其他浏览器："
    echo ""
    # 列出可用的浏览器
    for b in chrome edge brave; do
        local_path=$(detect_browser_path "$b" 2>/dev/null)
        if [[ -n "$local_path" ]]; then
            echo "      ✅ --browser $b  →  $local_path"
        else
            echo "      ❌ --browser $b  →  未安装"
        fi
    done
    exit 1
fi

echo "🔧 Playwright Pro - Browser Debug Launcher"
echo "   浏览器: $BROWSER_DISPLAY_NAME"
echo "   路径: $BROWSER_PATH"
echo "   端口: $DEBUG_PORT"
if [[ "$USE_DEFAULT_PROFILE" == true ]]; then
    echo "   配置: 默认 profile（保留登录态和数据）"
else
    echo "   配置: 独立调试 profile"
fi
echo ""

# Step 1: 检查是否已有调试端口可用
if try_connect_existing; then
    exit 0
fi

# Step 2: 检查浏览器是否在运行（但没有调试端口）
if pgrep -f "$BROWSER_PROCESS" > /dev/null 2>&1; then
    echo "⚠️  $BROWSER_DISPLAY_NAME 正在运行，但未开启调试端口"
    echo ""
    
    if [[ "$USE_DEFAULT_PROFILE" == true ]]; then
        echo "⚡ 使用默认 profile 模式需要重启浏览器"
        echo "   重要: 这将关闭所有 $BROWSER_DISPLAY_NAME 窗口/标签页！"
        echo "   （登录态和数据不会丢失，因为使用的是同一个 profile）"
    else
        echo "⚡ 提示: 使用独立 profile 模式"
        echo "   将启动一个新的浏览器窗口，不影响当前运行的实例"
        echo "   但需要先关闭当前浏览器才能使用调试端口"
        echo ""
        echo "   💡 或者使用 --use-default-profile 选项复用当前登录态"
    fi
    
    echo ""
    read -p "❓ 是否要关闭 $BROWSER_DISPLAY_NAME 并以调试模式重启? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🛑 正在关闭 $BROWSER_DISPLAY_NAME 进程..."
        pkill -9 "$BROWSER_PROCESS" 2>/dev/null
        sleep 2
        
        if pgrep -f "$BROWSER_PROCESS" > /dev/null 2>&1; then
            echo "❌ 无法关闭所有进程"
            echo "   请手动运行: killall -9 '$BROWSER_PROCESS'"
            exit 1
        fi
        echo "✅ 所有进程已终止"
    else
        echo "❌ 操作已取消"
        exit 1
    fi
fi

echo ""
echo "🚀 正在以调试模式启动 $BROWSER_DISPLAY_NAME..."

# Step 3: 确定 profile 目录
if [[ "$USE_DEFAULT_PROFILE" == true ]]; then
    PROFILE_DIR=$(get_default_profile_dir "$BROWSER_TYPE")
    echo "📁 使用默认 profile: $PROFILE_DIR"
    echo ""
    echo "⚠️  注意: 使用默认 profile 时，调试工具可以访问您的所有浏览器数据"
    echo "   请确保在受信任的环境中使用"
else
    PROFILE_DIR="$HOME/.playwright-pro-debug-profile-$BROWSER_TYPE"
    mkdir -p "$PROFILE_DIR"
    echo "📁 使用独立 profile: $PROFILE_DIR"
fi

echo ""

# Step 4: 启动浏览器
"$BROWSER_PATH" \
    --remote-debugging-port=$DEBUG_PORT \
    --user-data-dir="$PROFILE_DIR" \
    &

# Step 5: 等待启动
echo "⏳ 等待调试端口就绪..."
for i in {1..15}; do
    sleep 1
    if check_port; then
        echo ""
        echo "✅ $BROWSER_DISPLAY_NAME 启动成功！"
        echo "   调试端口: http://127.0.0.1:$DEBUG_PORT"
        echo ""
        echo "🔗 现在可以运行分析脚本了"
        echo "   例如: node connect-cdp.js"
        if [[ "$USE_DEFAULT_PROFILE" == true ]]; then
            echo ""
            echo "💡 使用默认 profile，所有登录态和扩展均已可用"
        fi
        exit 0
    fi
    echo -n "."
done

echo ""
echo "⚠️  $BROWSER_DISPLAY_NAME 已启动但调试端口 $DEBUG_PORT 未响应"
echo "   可能有其他实例仍在运行"
echo "   请尝试: killall -9 '$BROWSER_PROCESS' && ./launch-chrome.sh"
exit 1
