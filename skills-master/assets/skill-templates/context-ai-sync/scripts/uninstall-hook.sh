#!/usr/bin/env bash
#
# AI Context Sync - Hook 卸载脚本
# 从当前 Git 仓库移除 AI Context Sync hook
#
# 用法：
#   bash scripts/uninstall-hook.sh [选项]
#
# 选项：
#   --keep-config  保留配置文件
#   --help         显示帮助信息
#

set -e

# =============================================================================
# 颜色定义
# =============================================================================

COLOR_RESET="\033[0m"
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"

# =============================================================================
# 辅助函数
# =============================================================================

log_info() {
    echo -e "${COLOR_BLUE}[AI Context Sync]${COLOR_RESET} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}[AI Context Sync]${COLOR_RESET} ✅ $1"
}

log_warn() {
    echo -e "${COLOR_YELLOW}[AI Context Sync]${COLOR_RESET} ⚠️  $1"
}

log_error() {
    echo -e "${COLOR_RED}[AI Context Sync]${COLOR_RESET} ❌ $1" >&2
}

show_help() {
    cat << EOF
AI Context Sync - Hook 卸载脚本

用法：
    bash scripts/uninstall-hook.sh [选项]

选项：
    --keep-config  保留配置文件和日志
    --help         显示此帮助信息

示例：
    # 完全卸载
    bash scripts/uninstall-hook.sh

    # 卸载但保留配置
    bash scripts/uninstall-hook.sh --keep-config

EOF
}

# =============================================================================
# 主逻辑
# =============================================================================

KEEP_CONFIG=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        --keep-config)
            KEEP_CONFIG=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查是否在 Git 仓库中
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    log_error "当前目录不是 Git 仓库"
    exit 1
fi

# 获取仓库根目录和 hooks 目录
REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$REPO_ROOT/.git/hooks"
TARGET_HOOK="$HOOKS_DIR/pre-commit"
HOOK_CONFIG_DIR="$HOOKS_DIR/ai-context-sync"

# 检查是否安装了 AI Context Sync hook
if [[ ! -f "$TARGET_HOOK" ]]; then
    log_warn "未找到 pre-commit hook"
    exit 0
fi

if ! grep -q "AI Context Sync" "$TARGET_HOOK" 2>/dev/null; then
    log_warn "当前 pre-commit hook 不是由 AI Context Sync 安装的"
    exit 0
fi

log_info "正在卸载 AI Context Sync hook..."

# 检查是否是合并的 hook
if grep -q "以下是原有的 pre-commit hook 内容" "$TARGET_HOOK" 2>/dev/null; then
    # 是合并的 hook，需要提取原有内容
    log_info "检测到合并的 hook，正在提取原有内容..."
    
    TEMP_FILE=$(mktemp)
    
    # 写入 shebang
    echo "#!/usr/bin/env bash" > "$TEMP_FILE"
    
    # 提取原有内容（从分隔符之后开始）
    sed -n '/以下是原有的 pre-commit hook 内容/,$ p' "$TARGET_HOOK" | tail -n +3 >> "$TEMP_FILE"
    
    # 检查提取的内容是否为空
    if [[ $(wc -l < "$TEMP_FILE" | tr -d ' ') -le 1 ]]; then
        # 只有 shebang，删除 hook
        rm "$TARGET_HOOK"
        rm "$TEMP_FILE"
        log_info "已删除 pre-commit hook"
    else
        # 恢复原有 hook
        mv "$TEMP_FILE" "$TARGET_HOOK"
        chmod +x "$TARGET_HOOK"
        log_success "已恢复原有的 pre-commit hook"
    fi
else
    # 不是合并的 hook，直接删除
    rm "$TARGET_HOOK"
    log_info "已删除 pre-commit hook"
    
    # 如果有备份，询问是否恢复
    if [[ -f "$TARGET_HOOK.backup" ]]; then
        echo ""
        echo -n "发现备份文件，是否恢复？[y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            mv "$TARGET_HOOK.backup" "$TARGET_HOOK"
            chmod +x "$TARGET_HOOK"
            log_success "已恢复备份的 hook"
        else
            rm "$TARGET_HOOK.backup"
            log_info "已删除备份文件"
        fi
    fi
fi

# 清理配置目录
if [[ -d "$HOOK_CONFIG_DIR" ]]; then
    if [[ "$KEEP_CONFIG" == "true" ]]; then
        log_info "保留配置目录: $HOOK_CONFIG_DIR"
    else
        rm -rf "$HOOK_CONFIG_DIR"
        log_info "已删除配置目录"
    fi
fi

log_success "卸载完成！"
echo ""
echo "如需重新安装，请运行："
echo "  bash scripts/install-hook.sh"
echo ""
