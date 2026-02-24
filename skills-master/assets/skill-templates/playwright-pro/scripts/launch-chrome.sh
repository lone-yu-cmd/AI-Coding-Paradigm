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
#   --profile <name>        指定 profile 目录名（如 "Default", "Profile 1"）
#   --browser <name>        指定浏览器：chrome（默认）、edge、brave
#   --port <number>         调试端口（默认：9222）
#   --yes, -y              非交互模式，自动确认所有提示
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
AUTO_YES=false
PROFILE_NAME=""  # 用户指定的 profile 目录名（如 "Default", "Profile 1"）

# =============================================================================
# 参数解析
# =============================================================================

show_help() {
    echo "Playwright Pro - Chrome Debug Mode Launcher"
    echo ""
    echo "用法: ./launch-chrome.sh [选项]"
    echo ""
    echo "选项:"
    echo "  --profile <name>        指定 profile 目录名（如 'Default', 'Profile 1'）"
    echo "  --browser <name>        指定浏览器: chrome (默认), edge, brave"
    echo "  --port <number>         调试端口（默认: 9222）"
    echo "  --yes, -y               非交互模式，自动确认所有提示（适合 AI/CI 调用）"
    echo "  --help                  显示此帮助信息"
    echo ""
    echo "默认行为："
    echo "  克隆用户的浏览器 profile 启动调试浏览器（保留登录态、书签、扩展、历史记录）"
    echo "  自动检测最近使用的 profile，或通过 --profile 指定"
    echo ""
    echo "环境变量:"
    echo "  DEBUG_PORT    调试端口（默认: 9222）"
    echo "  CHROME_PATH   浏览器可执行文件路径（自动检测）"
    echo "  BROWSER_TYPE  浏览器类型: chrome/edge/brave（默认: chrome）"
    echo ""
    echo "示例:"
    echo "  ./launch-chrome.sh                                # 克隆默认 profile（保留登录态）"
    echo "  ./launch-chrome.sh --profile 'Profile 1'          # 指定特定 profile"
    echo "  ./launch-chrome.sh --yes                          # 非交互模式，自动确认"
    echo "  ./launch-chrome.sh --browser edge                 # 使用 Edge"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --profile)
            PROFILE_NAME="$2"
            shift 2
            ;;
        --yes|-y)
            AUTO_YES=true
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
# Playwright MCP 自动配置
# =============================================================================

# 配置单个 IDE 的 Playwright MCP（添加 --cdp-endpoint）
configure_mcp_file() {
    local mcp_file="$1"
    local ide_name="$2"
    local cdp_url="http://localhost:$DEBUG_PORT"
    
    if [[ ! -f "$mcp_file" ]]; then
        return 1
    fi
    
    if ! command -v jq &>/dev/null; then
        return 2
    fi
    
    # 检查是否存在 playwright server 配置
    local has_playwright=$(jq -r '.mcpServers.playwright // empty' "$mcp_file" 2>/dev/null)
    if [[ -z "$has_playwright" ]]; then
        return 3
    fi
    
    # 检查是否已经配置了 --cdp-endpoint
    local has_cdp=$(jq -r '.mcpServers.playwright.args | if . then map(select(. == "--cdp-endpoint")) | length else 0 end' "$mcp_file" 2>/dev/null)
    if [[ "$has_cdp" -gt 0 ]]; then
        # 已有 --cdp-endpoint，检查端口值是否正确
        local current_url=$(jq -r '
            .mcpServers.playwright.args as $args |
            ($args | to_entries | map(select(.value == "--cdp-endpoint")) | .[0].key) as $idx |
            if $idx then $args[$idx + 1] else "" end
        ' "$mcp_file" 2>/dev/null)
        
        if [[ "$current_url" == "$cdp_url" ]]; then
            echo "   ✅ $ide_name: 已正确配置 (--cdp-endpoint $cdp_url)"
            return 0
        fi
        
        # 更新端口值
        local tmp_file=$(mktemp)
        jq --arg url "$cdp_url" '
            (.mcpServers.playwright.args | to_entries | .[] | select(.value == "--cdp-endpoint").key) as $idx |
            .mcpServers.playwright.args[$idx + 1] = $url
        ' "$mcp_file" > "$tmp_file" 2>/dev/null
        
        if [[ -s "$tmp_file" ]] && jq empty "$tmp_file" 2>/dev/null; then
            mv "$tmp_file" "$mcp_file"
            echo "   ✅ $ide_name: 已更新端口 → $cdp_url"
            return 0
        fi
        rm -f "$tmp_file"
        return 4
    fi
    
    # 没有 --cdp-endpoint，添加到 args 数组
    local tmp_file=$(mktemp)
    jq --arg url "$cdp_url" '
        .mcpServers.playwright.args += ["--cdp-endpoint", $url]
    ' "$mcp_file" > "$tmp_file" 2>/dev/null
    
    if [[ -s "$tmp_file" ]] && jq empty "$tmp_file" 2>/dev/null; then
        mv "$tmp_file" "$mcp_file"
        echo "   ✅ $ide_name: 已添加 --cdp-endpoint $cdp_url"
        return 0
    fi
    rm -f "$tmp_file"
    return 4
}

# 配置所有支持的 IDE 的 Playwright MCP
configure_playwright_mcp() {
    local configured=0
    local no_jq=false
    
    echo ""
    echo "🔧 配置 Playwright MCP 连接..."
    
    # 各 IDE 的 MCP 配置文件路径
    declare -a IDE_NAMES=("CodeBuddy" "Cursor" "Trae" "Windsurf" "VS Code")
    declare -a MCP_FILES=(
        "$HOME/.codebuddy/mcp.json"
        "$HOME/.cursor/mcp.json"
        "$HOME/.trae/mcp.json"
        "$HOME/.windsurf/mcp.json"
        "$HOME/.vscode/mcp.json"
    )
    
    for i in "${!MCP_FILES[@]}"; do
        local mcp_file="${MCP_FILES[$i]}"
        local ide_name="${IDE_NAMES[$i]}"
        
        configure_mcp_file "$mcp_file" "$ide_name"
        local result=$?
        
        case $result in
            0) ((configured++)) ;;
            2) no_jq=true ;;
        esac
    done
    
    if [[ "$configured" -eq 0 ]]; then
        if [[ "$no_jq" == true ]]; then
            echo "   ⚠️  未找到 jq，请手动配置 Playwright MCP:"
            echo ""
            echo "   在 IDE 的 MCP 配置中添加 --cdp-endpoint:"
            echo "   {"
            echo "     \"mcpServers\": {"
            echo "       \"playwright\": {"
            echo "         \"command\": \"npx\","
            echo "         \"args\": [\"@playwright/mcp@latest\", \"--cdp-endpoint\", \"http://localhost:$DEBUG_PORT\"]"
            echo "       }"
            echo "     }"
            echo "   }"
        else
            echo "   ℹ️  未检测到 IDE 的 Playwright MCP 配置，跳过"
        fi
    fi
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
            
            # 确保 MCP 配置也是正确的
            configure_playwright_mcp
            
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
echo "   配置: 克隆用户 profile（保留登录态和数据）"
if [[ "$AUTO_YES" == true ]]; then
    echo "   模式: 非交互（自动确认）"
fi
echo ""

# 检查浏览器主进程是否在运行（排除 crashpad_handler 等辅助进程）
is_browser_running() {
    local pattern="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: 使用 pgrep 精确匹配进程名（不匹配命令行参数）
        pgrep -x "$pattern" > /dev/null 2>&1
    else
        # Linux/Windows: 使用 pgrep -f 但排除辅助进程
        pgrep -f "$pattern" 2>/dev/null | while read pid; do
            local cmd=$(ps -o comm= -p "$pid" 2>/dev/null)
            if [[ "$cmd" != *"crashpad"* ]] && [[ "$cmd" != *"helper"* ]]; then
                return 0
            fi
        done
        return 1
    fi
}

# 终止浏览器所有进程（包括辅助进程）
kill_browser() {
    local pattern="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: killall 更可靠（按进程名匹配）
        killall -9 "$pattern" 2>/dev/null
        # 也清理可能残留的 crashpad_handler
        pkill -9 -f "crashpad_handler.*$pattern" 2>/dev/null
    else
        pkill -9 -f "$pattern" 2>/dev/null
    fi
}

# 自动检测最近使用的 profile 目录名
# Chrome 的 user-data-dir 下有 Default、Profile 1、Profile 2 等子目录
# 通过检查 Preferences 文件的修改时间来判断哪个是最近使用的
detect_recent_profile() {
    local user_data_dir="$1"
    local latest_profile=""
    local latest_time=0
    
    # 遍历所有 profile 目录
    for profile_dir in "$user_data_dir"/Default "$user_data_dir"/Profile\ *; do
        if [[ -d "$profile_dir" ]]; then
            local pref_file="$profile_dir/Preferences"
            if [[ -f "$pref_file" ]]; then
                local mod_time
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    mod_time=$(stat -f %m "$pref_file" 2>/dev/null || echo 0)
                else
                    mod_time=$(stat -c %Y "$pref_file" 2>/dev/null || echo 0)
                fi
                if [[ "$mod_time" -gt "$latest_time" ]]; then
                    latest_time=$mod_time
                    latest_profile=$(basename "$profile_dir")
                fi
            fi
        fi
    done
    
    # 如果没有找到任何 profile，默认使用 "Default"
    if [[ -z "$latest_profile" ]]; then
        latest_profile="Default"
    fi
    
    echo "$latest_profile"
}

# 列出所有可用的 profile
list_profiles() {
    local user_data_dir="$1"
    local count=0
    
    for profile_dir in "$user_data_dir"/Default "$user_data_dir"/Profile\ *; do
        if [[ -d "$profile_dir" ]]; then
            local dirname=$(basename "$profile_dir")
            local name=""
            local pref_file="$profile_dir/Preferences"
            if [[ -f "$pref_file" ]]; then
                # 尝试从 Preferences 中提取 profile 名称
                name=$(grep -o '"name":"[^"]*"' "$pref_file" 2>/dev/null | head -1 | cut -d'"' -f4)
            fi
            if [[ -n "$name" ]]; then
                echo "      [$count] $dirname → $name"
            else
                echo "      [$count] $dirname"
            fi
            ((count++))
        fi
    done
}

# Step 1: 检查是否已有调试端口可用
if try_connect_existing; then
    exit 0
fi

# Step 2: 检查浏览器是否在运行（但没有调试端口）
if is_browser_running "$BROWSER_PROCESS"; then
    echo "⚠️  $BROWSER_DISPLAY_NAME 正在运行，但未开启调试端口"
    echo ""
    
    echo "⚡ 需要重启浏览器以启用调试端口"
    echo "   重要: 这将关闭所有 $BROWSER_DISPLAY_NAME 窗口/标签页！"
    echo "   （登录态和数据不会丢失，会自动克隆用户 profile）"
    
    echo ""
    
    if [[ "$AUTO_YES" == true ]]; then
        echo "🤖 非交互模式：自动确认关闭 $BROWSER_DISPLAY_NAME"
        REPLY="y"
    else
        read -p "❓ 是否要关闭 $BROWSER_DISPLAY_NAME 并以调试模式重启? (y/n) " -n 1 -r
        echo
    fi
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🛑 正在关闭 $BROWSER_DISPLAY_NAME 进程..."
        kill_browser "$BROWSER_PROCESS"
        sleep 2
        
        if is_browser_running "$BROWSER_PROCESS"; then
            # 再试一次
            kill_browser "$BROWSER_PROCESS"
            sleep 2
        fi
        
        if is_browser_running "$BROWSER_PROCESS"; then
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

# Step 3: 克隆用户 profile 并确定启动参数
LAUNCH_ARGS=("--remote-debugging-port=$DEBUG_PORT")

SOURCE_PROFILE_DIR=$(get_default_profile_dir "$BROWSER_TYPE")

# 确定要使用的 profile 子目录
if [[ -n "$PROFILE_NAME" ]]; then
    if [[ ! -d "$SOURCE_PROFILE_DIR/$PROFILE_NAME" ]]; then
        echo "❌ 指定的 profile 不存在: $SOURCE_PROFILE_DIR/$PROFILE_NAME"
        echo ""
        echo "   可用的 profile:"
        list_profiles "$SOURCE_PROFILE_DIR"
        exit 1
    fi
    SELECTED_PROFILE="$PROFILE_NAME"
else
    SELECTED_PROFILE=$(detect_recent_profile "$SOURCE_PROFILE_DIR")
fi

echo "👤 使用 profile: $SELECTED_PROFILE"

# 显示 profile 中的用户名
PREF_FILE="$SOURCE_PROFILE_DIR/$SELECTED_PROFILE/Preferences"
if [[ -f "$PREF_FILE" ]]; then
    PROFILE_USER_NAME=$(grep -o '"name":"[^"]*"' "$PREF_FILE" 2>/dev/null | head -1 | cut -d'"' -f4)
    if [[ -n "$PROFILE_USER_NAME" ]]; then
        echo "   用户: $PROFILE_USER_NAME"
    fi
fi

# Chrome 安全限制：使用默认 data directory 时拒绝启用远程调试端口
# 解决方案：克隆用户 profile 的关键文件到独立 data directory
# 这样既能保留登录态（Cookies、Session 等），又能启用调试端口
CLONE_DIR="$HOME/.playwright-pro-clone-$BROWSER_TYPE"
CLONE_PROFILE_DIR="$CLONE_DIR/Default"

echo ""
echo "📋 正在同步 profile 数据（保留登录态）..."

mkdir -p "$CLONE_PROFILE_DIR"

# 复制关键文件（登录态、扩展、配置等），跳过缓存等大文件
PROFILE_FILES=(
    "Cookies"
    "Login Data"
    "Web Data"
    "Preferences"
    "Secure Preferences"
    "Bookmarks"
    "Local Storage"
    "Session Storage"
    "IndexedDB"
    "Extensions"
    "Extension State"
    "Extension Rules"
    "Extension Scripts"
)

SOURCE_DIR="$SOURCE_PROFILE_DIR/$SELECTED_PROFILE"
COPY_COUNT=0

for f in "${PROFILE_FILES[@]}"; do
    if [[ -e "$SOURCE_DIR/$f" ]]; then
        # 使用 rsync 增量同步（如果可用），否则用 cp
        if command -v rsync &>/dev/null; then
            rsync -a --delete "$SOURCE_DIR/$f" "$CLONE_PROFILE_DIR/" 2>/dev/null
        else
            rm -rf "$CLONE_PROFILE_DIR/$f" 2>/dev/null
            cp -a "$SOURCE_DIR/$f" "$CLONE_PROFILE_DIR/" 2>/dev/null
        fi
        ((COPY_COUNT++))
    fi
done

# 复制 Local State（在 user-data-dir 根目录）
if [[ -f "$SOURCE_PROFILE_DIR/Local State" ]]; then
    cp -a "$SOURCE_PROFILE_DIR/Local State" "$CLONE_DIR/" 2>/dev/null
fi

echo "   ✅ 已同步 $COPY_COUNT 项数据"

LAUNCH_ARGS+=("--user-data-dir=$CLONE_DIR")
LAUNCH_ARGS+=("--profile-directory=Default")

echo ""

# Step 4: 启动浏览器
"$BROWSER_PATH" "${LAUNCH_ARGS[@]}" &

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
        echo ""
        echo "💡 已克隆用户 profile，登录态和扩展均已可用"
        echo "   注意: 在此浏览器中的新登录/修改不会同步回原 profile"
        
        # Step 6: 自动配置 Playwright MCP 的 --cdp-endpoint
        configure_playwright_mcp
        
        exit 0
    fi
    echo -n "."
done

echo ""
echo "⚠️  $BROWSER_DISPLAY_NAME 已启动但调试端口 $DEBUG_PORT 未响应"
echo "   可能有其他实例仍在运行"
echo "   请尝试: killall -9 '$BROWSER_PROCESS' && ./launch-chrome.sh"
exit 1
