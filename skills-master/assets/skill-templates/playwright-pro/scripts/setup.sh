#!/bin/bash

# =============================================================================
# Playwright Pro - 一键安装脚本
# 
# 功能：自动安装和配置 Playwright Pro 所需的所有依赖和脚本
# 
# 使用方法：
#   chmod +x setup.sh && ./setup.sh
#   
# 支持的项目：
#   - 任何包含 package.json 的 Node.js 项目
#
# 特性：
#   - 自动检测项目根目录
#   - 跨平台路径兼容（macOS/Linux/Windows）
#   - 支持从任意目录执行
#   - 支持 Chrome/Edge/Brave 多浏览器
# =============================================================================

set -e

# 颜色定义（跨平台兼容）
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# =============================================================================
# 路径处理函数（跨平台兼容）
# =============================================================================

# 获取脚本所在目录（跨平台）
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    while [ -h "$source" ]; do
        local dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done
    cd -P "$(dirname "$source")" && pwd
}

# 规范化路径
normalize_path() {
    local path="$1"
    path="${path//\\//}"
    if [ -d "$path" ]; then
        (cd "$path" && pwd)
    elif [ -f "$path" ]; then
        local dir=$(dirname "$path")
        local file=$(basename "$path")
        echo "$(cd "$dir" && pwd)/$file"
    else
        echo "$path"
    fi
}

# 获取脚本所在目录
SCRIPT_DIR="$(get_script_dir)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Playwright Pro - 安装向导                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "📍 技能目录: ${YELLOW}$SKILL_DIR${NC}"
echo ""

# =============================================================================
# 环境检查
# =============================================================================

check_requirements() {
    echo -e "${YELLOW}🔍 检查系统环境...${NC}"
    
    # 检测操作系统
    local os_type="unknown"
    case "$OSTYPE" in
        darwin*)  os_type="macOS" ;;
        linux*)   os_type="Linux" ;;
        msys*|cygwin*|mingw*) os_type="Windows" ;;
    esac
    echo -e "   ${GREEN}✓${NC} 操作系统: $os_type"
    
    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ 未找到 Node.js，请先安装 Node.js 18+${NC}"
        exit 1
    fi
    
    local node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$node_version" -lt 18 ]; then
        echo -e "${RED}❌ Node.js 版本过低（当前: $(node -v)），请升级到 18+${NC}"
        exit 1
    fi
    echo -e "   ${GREEN}✓${NC} Node.js $(node -v)"
    
    # 检查包管理器
    if command -v pnpm &> /dev/null; then
        PKG_MANAGER="pnpm"
        PKG_ADD_CMD="pnpm add -D"
        echo -e "   ${GREEN}✓${NC} pnpm $(pnpm -v)"
    elif command -v yarn &> /dev/null; then
        PKG_MANAGER="yarn"
        PKG_ADD_CMD="yarn add -D"
        echo -e "   ${GREEN}✓${NC} yarn $(yarn -v)"
    elif command -v npm &> /dev/null; then
        PKG_MANAGER="npm"
        PKG_ADD_CMD="npm install -D"
        echo -e "   ${GREEN}✓${NC} npm $(npm -v)"
    else
        echo -e "${RED}❌ 未找到包管理器（pnpm/yarn/npm）${NC}"
        exit 1
    fi
    
    # 检查 Chrome
    local chrome_found=false
    case "$OSTYPE" in
        darwin*)
            if [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
                chrome_found=true
            fi
            ;;
        linux*)
            for cmd in "google-chrome" "google-chrome-stable" "chromium" "chromium-browser"; do
                if command -v "$cmd" &> /dev/null; then
                    chrome_found=true
                    break
                fi
            done
            ;;
        msys*|cygwin*|mingw*)
            if [ -f "/c/Program Files/Google/Chrome/Application/chrome.exe" ] || \
               [ -f "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" ]; then
                chrome_found=true
            fi
            ;;
    esac
    
    if [ "$chrome_found" = true ]; then
        echo -e "   ${GREEN}✓${NC} Google Chrome"
    else
        echo -e "   ${YELLOW}⚠️${NC} 未找到 Google Chrome（使用时需要安装）"
    fi
    
    echo ""
}

# =============================================================================
# 项目检测
# =============================================================================

# 查找项目根目录
find_project_root() {
    local current_dir="$1"
    local max_depth=10
    local depth=0
    
    while [ "$current_dir" != "/" ] && [ $depth -lt $max_depth ]; do
        if [ -f "$current_dir/package.json" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
        ((depth++))
    done
    
    return 1
}

# 检测项目目录
detect_project() {
    echo -e "${YELLOW}🔍 检测项目...${NC}"
    
    # 从当前工作目录开始查找
    PROJECT_ROOT=$(find_project_root "$(pwd)") || true
    
    if [ -z "$PROJECT_ROOT" ]; then
        echo -e "${RED}❌ 未找到 package.json${NC}"
        echo -e "   请在包含 package.json 的项目目录中运行此脚本"
        exit 1
    fi
    
    PROJECT_ROOT=$(normalize_path "$PROJECT_ROOT")
    echo -e "   ${GREEN}✓${NC} 项目目录: $PROJECT_ROOT"
    echo ""
}

# =============================================================================
# 安装流程
# =============================================================================

# 安装依赖
install_dependencies() {
    echo -e "${YELLOW}📦 安装依赖...${NC}"
    
    cd "$PROJECT_ROOT"
    
    if grep -q '"playwright"' package.json 2>/dev/null; then
        echo -e "   ${GREEN}✓${NC} playwright 已安装"
    else
        echo -e "   ${BLUE}→${NC} 安装 playwright..."
        $PKG_ADD_CMD playwright
        echo -e "   ${GREEN}✓${NC} playwright 安装完成"
    fi
    
    echo ""
}

# 创建脚本目录和文件
setup_scripts() {
    echo -e "${YELLOW}📁 设置脚本文件...${NC}"
    
    # 创建 scripts/debug 目录
    local debug_dir="$PROJECT_ROOT/scripts/debug"
    mkdir -p "$debug_dir"
    
    # 复制核心脚本
    local source_connect="$SKILL_DIR/scripts/connect-cdp.js"
    local source_launch="$SKILL_DIR/scripts/launch-chrome.sh"
    
    if [ -f "$source_connect" ]; then
        cp "$source_connect" "$debug_dir/"
        echo -e "   ${GREEN}✓${NC} 复制 connect-cdp.js"
    else
        echo -e "   ${RED}✗${NC} 未找到 connect-cdp.js: $source_connect"
    fi
    
    if [ -f "$source_launch" ]; then
        cp "$source_launch" "$debug_dir/"
        chmod +x "$debug_dir/launch-chrome.sh"
        echo -e "   ${GREEN}✓${NC} 复制 launch-chrome.sh"
    else
        echo -e "   ${RED}✗${NC} 未找到 launch-chrome.sh: $source_launch"
    fi
    
    # 创建输出目录
    local output_dir="$PROJECT_ROOT/debug-output"
    mkdir -p "$output_dir"
    echo -e "   ${GREEN}✓${NC} 创建 debug-output 目录"
    
    # 添加 .gitignore
    if [ ! -f "$output_dir/.gitignore" ]; then
        cat > "$output_dir/.gitignore" << 'EOF'
# 忽略所有调试输出文件
*
!.gitignore
EOF
        echo -e "   ${GREEN}✓${NC} 添加 debug-output/.gitignore"
    fi
    
    echo ""
}

# 确保 package.json 中有 "type": "module"（connect-cdp.js 使用 ESM import 语法）
ensure_esm_support() {
    echo -e "${YELLOW}📦 检查 ESM 支持...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # 检查是否已有 "type": "module"
    if grep -q '"type"[[:space:]]*:[[:space:]]*"module"' package.json 2>/dev/null; then
        echo -e "   ${GREEN}✓${NC} package.json 已设置 \"type\": \"module\""
        return
    fi
    
    # 检查是否有 "type": "commonjs" 或其他 type
    if grep -q '"type"' package.json 2>/dev/null; then
        echo -e "   ${YELLOW}⚠️${NC} package.json 中 \"type\" 不是 \"module\""
        echo -e "   ${YELLOW}⚠️${NC} connect-cdp.js 使用 ESM import 语法，需要 \"type\": \"module\""
        echo -e "   ${YELLOW}⚠️${NC} 如果项目使用 CommonJS，请将 connect-cdp.js 重命名为 connect-cdp.mjs"
        
        # 重命名为 .mjs 以兼容 CommonJS 项目
        if [ -f "$PROJECT_ROOT/scripts/debug/connect-cdp.js" ]; then
            cp "$PROJECT_ROOT/scripts/debug/connect-cdp.js" "$PROJECT_ROOT/scripts/debug/connect-cdp.mjs"
            echo -e "   ${GREEN}✓${NC} 已创建 connect-cdp.mjs（ESM 兼容副本）"
            USE_MJS=true
        fi
        return
    fi
    
    # 没有 type 字段，添加 "type": "module"
    if command -v jq &> /dev/null; then
        local tmp_file=$(mktemp)
        jq '. + {"type": "module"}' package.json > "$tmp_file"
        mv "$tmp_file" package.json
        echo -e "   ${GREEN}✓${NC} 已添加 \"type\": \"module\" 到 package.json"
    else
        echo -e "   ${YELLOW}⚠️${NC} 未找到 jq，请手动添加 \"type\": \"module\" 到 package.json"
        echo -e "   ${YELLOW}⚠️${NC} 或将 scripts/debug/connect-cdp.js 重命名为 connect-cdp.mjs"
    fi
    
    echo ""
}

# 更新 package.json scripts
update_package_scripts() {
    echo -e "${YELLOW}📝 更新 package.json 脚本...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # 根据 ESM 兼容性决定脚本命令中的文件名
    local cdp_script="scripts/debug/connect-cdp.js"
    if [ "$USE_MJS" = true ]; then
        cdp_script="scripts/debug/connect-cdp.mjs"
    fi
    
    if command -v jq &> /dev/null; then
        local tmp_file=$(mktemp)
        jq --arg cdp "$cdp_script" \
            '.scripts["debug:connect"] = ("node " + $cdp) |
            .scripts["debug:styles"] = ("node " + $cdp + " 0") |
            .scripts["debug:launch-chrome"] = "./scripts/debug/launch-chrome.sh" |
            .scripts["debug:launch-default"] = "./scripts/debug/launch-chrome.sh --use-default-profile" |
            .scripts["debug:fast"] = ("node " + $cdp + " --no-network --no-perf")' \
            package.json > "$tmp_file"
        mv "$tmp_file" package.json
        echo -e "   ${GREEN}✓${NC} 已添加调试脚本到 package.json"
    else
        echo -e "   ${YELLOW}⚠️${NC} 未找到 jq，请手动添加以下脚本到 package.json:"
        echo ""
        echo -e "${BLUE}   \"scripts\": {"
        echo "     \"debug:connect\": \"node $cdp_script\","
        echo "     \"debug:styles\": \"node $cdp_script 0\","
        echo '     "debug:launch-chrome": "./scripts/debug/launch-chrome.sh",'
        echo '     "debug:launch-default": "./scripts/debug/launch-chrome.sh --use-default-profile",'
        echo "     \"debug:fast\": \"node $cdp_script --no-network --no-perf\""
        echo -e "   }${NC}"
    fi
    
    echo ""
}

# =============================================================================
# 验证和完成
# =============================================================================

verify_installation() {
    echo -e "${YELLOW}✅ 验证安装...${NC}"
    
    local all_ok=true
    
    if [ -f "$PROJECT_ROOT/scripts/debug/connect-cdp.js" ]; then
        echo -e "   ${GREEN}✓${NC} connect-cdp.js"
    else
        echo -e "   ${RED}✗${NC} connect-cdp.js 未找到"
        all_ok=false
    fi
    
    if [ -f "$PROJECT_ROOT/scripts/debug/launch-chrome.sh" ]; then
        echo -e "   ${GREEN}✓${NC} launch-chrome.sh"
    else
        echo -e "   ${RED}✗${NC} launch-chrome.sh 未找到"
        all_ok=false
    fi
    
    if [ -x "$PROJECT_ROOT/scripts/debug/launch-chrome.sh" ]; then
        echo -e "   ${GREEN}✓${NC} launch-chrome.sh 可执行"
    else
        echo -e "   ${YELLOW}⚠️${NC} launch-chrome.sh 无执行权限"
    fi
    
    if grep -q '"playwright"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
        echo -e "   ${GREEN}✓${NC} playwright 依赖"
    else
        echo -e "   ${RED}✗${NC} playwright 依赖未安装"
        all_ok=false
    fi
    
    if [ -d "$PROJECT_ROOT/debug-output" ]; then
        echo -e "   ${GREEN}✓${NC} debug-output 目录"
    else
        echo -e "   ${YELLOW}⚠️${NC} debug-output 目录未创建"
    fi
    
    echo ""
    
    if [ "$all_ok" = true ]; then
        return 0
    else
        return 1
    fi
}

print_usage() {
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 安装完成！                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}📖 使用方法:${NC}"
    echo ""
    echo "   1. 启动调试版浏览器:"
    echo -e "      ${YELLOW}$PKG_MANAGER run debug:launch-chrome${NC}"
    echo -e "      ${YELLOW}$PKG_MANAGER run debug:launch-default${NC}  (复用默认 profile，保留登录态)"
    echo ""
    echo "   2. 在浏览器中打开目标页面"
    echo ""
    echo "   3. 分析页面:"
    echo -e "      ${YELLOW}$PKG_MANAGER run debug:connect${NC}             (完整分析)"
    echo -e "      ${YELLOW}$PKG_MANAGER run debug:fast${NC}                (快速分析，跳过网络和性能)"
    echo -e "      ${YELLOW}node scripts/debug/connect-cdp.js --url github${NC}  (按 URL 关键字选择标签页)"
    echo ""
    echo "   4. 查看输出文件:"
    echo -e "      ${YELLOW}debug-output/${NC}"
    echo ""
    echo -e "${BLUE}📁 输出文件说明:${NC}"
    echo "   - screenshot.png              视口截图"
    echo "   - screenshot-full.png         全页截图"
    echo "   - style-report.md             综合分析报告"
    echo "   - dom-tree.txt                DOM 结构树"
    echo "   - page-data.json              完整数据"
    echo "   - network-requests.json       网络请求日志"
    echo "   - console-logs.json           Console 日志"
    echo "   - performance-metrics.json    性能指标"
    echo ""
    echo -e "${BLUE}🔧 环境变量配置（可选）:${NC}"
    echo "   - DEBUG_OUTPUT_DIR      自定义输出目录"
    echo "   - CDP_PORT              调试端口（默认: 9222）"
    echo "   - CHROME_PATH           浏览器可执行文件路径"
    echo "   - BROWSER_TYPE          浏览器类型: chrome/edge/brave"
    echo ""
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    USE_MJS=false
    check_requirements
    detect_project
    install_dependencies
    setup_scripts
    ensure_esm_support
    update_package_scripts
    
    if verify_installation; then
        print_usage
    else
        echo -e "${RED}❌ 安装过程中出现问题，请检查上述错误${NC}"
        exit 1
    fi
}

main "$@"