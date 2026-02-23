#!/usr/bin/env bash
#
# AI Context Sync - Hook 安装脚本
# 将 pre-commit hook 安装到当前 Git 仓库
#
# 用法：
#   bash scripts/install-hook.sh [选项]
#
# 选项：
#   --force    强制覆盖已存在的 hook
#   --merge    与已存在的 hook 合并
#   --help     显示帮助信息
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
AI Context Sync - Hook 安装脚本

用法：
    bash scripts/install-hook.sh [选项]

选项：
    --force    强制覆盖已存在的 hook
    --merge    与已存在的 hook 合并（将 AI Context Sync 添加到开头）
    --help     显示此帮助信息

示例：
    # 首次安装
    bash scripts/install-hook.sh

    # 强制覆盖
    bash scripts/install-hook.sh --force

    # 与现有 hook 合并
    bash scripts/install-hook.sh --merge

EOF
}

# =============================================================================
# 主逻辑
# =============================================================================

FORCE_MODE=false
MERGE_MODE=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE_MODE=true
            shift
            ;;
        --merge)
            MERGE_MODE=true
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
    log_info "请先运行: git init"
    exit 1
fi

# 获取仓库根目录和 hooks 目录
REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$REPO_ROOT/.git/hooks"
TARGET_HOOK="$HOOKS_DIR/pre-commit"

# 获取脚本所在目录（skill 的 scripts/hooks 目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOOK="$SCRIPT_DIR/hooks/pre-commit.sh"
SOURCE_CONFIG_DIR="$SCRIPT_DIR/hooks/ai-context-sync"

# 检查源文件是否存在
if [[ ! -f "$SOURCE_HOOK" ]]; then
    log_error "源 hook 文件不存在: $SOURCE_HOOK"
    exit 1
fi

# 确保 hooks 目录存在
mkdir -p "$HOOKS_DIR"

# 创建 ai-context-sync 配置目录
HOOK_CONFIG_DIR="$HOOKS_DIR/ai-context-sync"
mkdir -p "$HOOK_CONFIG_DIR"

# 检查是否已存在 pre-commit hook
if [[ -f "$TARGET_HOOK" ]]; then
    if grep -q "AI Context Sync" "$TARGET_HOOK" 2>/dev/null; then
        log_warn "AI Context Sync hook 已安装"
        if [[ "$FORCE_MODE" == "true" ]]; then
            log_info "强制模式：将覆盖现有 hook"
        else
            log_info "使用 --force 覆盖，或 --merge 合并"
            exit 0
        fi
    else
        if [[ "$FORCE_MODE" == "true" ]]; then
            log_warn "将覆盖现有的 pre-commit hook"
            # 备份现有 hook
            cp "$TARGET_HOOK" "$TARGET_HOOK.backup"
            log_info "已备份到: $TARGET_HOOK.backup"
        elif [[ "$MERGE_MODE" == "true" ]]; then
            log_info "将与现有 hook 合并"
        else
            log_warn "已存在 pre-commit hook"
            echo ""
            echo "请选择操作："
            echo "  1. 使用 --force 覆盖现有 hook（将备份原文件）"
            echo "  2. 使用 --merge 将 AI Context Sync 添加到现有 hook 开头"
            echo ""
            exit 1
        fi
    fi
fi

# 安装 hook
log_info "正在安装 AI Context Sync pre-commit hook..."

if [[ "$MERGE_MODE" == "true" && -f "$TARGET_HOOK" ]]; then
    # 合并模式：将 AI Context Sync 添加到开头
    TEMP_FILE=$(mktemp)
    
    # 写入 AI Context Sync hook
    cat "$SOURCE_HOOK" > "$TEMP_FILE"
    
    # 添加分隔符
    echo "" >> "$TEMP_FILE"
    echo "# ========================================" >> "$TEMP_FILE"
    echo "# 以下是原有的 pre-commit hook 内容" >> "$TEMP_FILE"
    echo "# ========================================" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    
    # 添加原有 hook 内容（跳过 shebang 行）
    tail -n +2 "$TARGET_HOOK" >> "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$TARGET_HOOK"
else
    # 覆盖模式或首次安装
    cp "$SOURCE_HOOK" "$TARGET_HOOK"
fi

# 设置可执行权限
chmod +x "$TARGET_HOOK"

# 复制配置文件
if [[ -d "$SOURCE_CONFIG_DIR" ]]; then
    cp -r "$SOURCE_CONFIG_DIR/"* "$HOOK_CONFIG_DIR/" 2>/dev/null || true
    chmod +x "$HOOK_CONFIG_DIR/"*.sh 2>/dev/null || true
fi

# 创建空日志文件
touch "$HOOK_CONFIG_DIR/sync.log"

log_success "Hook 安装完成！"
echo ""
echo "已安装文件："
echo "  - $TARGET_HOOK"
echo "  - $HOOK_CONFIG_DIR/config.sh"
echo "  - $HOOK_CONFIG_DIR/lib.sh"
echo ""
echo "配置说明："
echo "  编辑 $HOOK_CONFIG_DIR/config.sh 自定义行为"
echo ""
echo "跳过检查："
echo "  SKIP_AI_CONTEXT_SYNC=1 git commit -m 'message'"
echo ""
