#!/usr/bin/env bash
#
# AI Context Sync - Git pre-commit Hook
# 在提交代码前提醒用户同步 AI Context 文档
#
# 安装方式：运行 scripts/install-hook.sh
# 跳过方式：SKIP_AI_CONTEXT_SYNC=1 git commit
#

set -e

# =============================================================================
# 配置加载
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_DIR="$SCRIPT_DIR/ai-context-sync"

# 加载配置文件（如果存在）
if [[ -f "$HOOK_DIR/config.sh" ]]; then
    source "$HOOK_DIR/config.sh"
fi

# 加载通用函数库（如果存在）
if [[ -f "$HOOK_DIR/lib.sh" ]]; then
    source "$HOOK_DIR/lib.sh"
fi

# =============================================================================
# 默认配置
# =============================================================================

: "${HOOK_MODE:=prompt}"           # 运行模式：prompt | cli | auto
: "${TIMEOUT:=30}"                 # 超时时间（秒）
: "${BLOCKING:=false}"             # 是否阻断 commit
: "${AI_CLI_PATH:=}"               # AI CLI 工具路径
: "${LOG_LEVEL:=info}"             # 日志级别：silent | info | debug
: "${INTERACTIVE_CONFIRM:=false}"  # 是否需要交互式确认

# =============================================================================
# 辅助函数
# =============================================================================

log_info() {
    if [[ "$LOG_LEVEL" != "silent" ]]; then
        echo -e "\033[34m[AI Context Sync]\033[0m $1"
    fi
}

log_warn() {
    if [[ "$LOG_LEVEL" != "silent" ]]; then
        echo -e "\033[33m[AI Context Sync]\033[0m ⚠️  $1"
    fi
}

log_debug() {
    if [[ "$LOG_LEVEL" == "debug" ]]; then
        echo -e "\033[90m[AI Context Sync DEBUG]\033[0m $1"
    fi
}

log_error() {
    echo -e "\033[31m[AI Context Sync]\033[0m ❌ $1" >&2
}

# 检测 AI CLI 工具
detect_ai_cli() {
    # 1. 检查环境变量指定的路径
    if [[ -n "$AI_CLI_PATH" && -x "$AI_CLI_PATH" ]]; then
        echo "$AI_CLI_PATH"
        return 0
    fi
    
    # 2. 检查项目配置文件
    if [[ -f ".aicontextrc.json" ]]; then
        local cli_path=$(grep -o '"cliPath"[[:space:]]*:[[:space:]]*"[^"]*"' .aicontextrc.json | cut -d'"' -f4)
        if [[ -n "$cli_path" && -x "$cli_path" ]]; then
            echo "$cli_path"
            return 0
        fi
    fi
    
    # 3. 检查系统 PATH
    for cli in codebuddy-cli cursor-cli ai-context-cli; do
        if command -v "$cli" &>/dev/null; then
            echo "$cli"
            return 0
        fi
    done
    
    return 1
}

# 检查是否应该跳过
should_skip() {
    # 检查环境变量
    if [[ "$SKIP_AI_CONTEXT_SYNC" == "1" ]]; then
        log_info "检测到 SKIP_AI_CONTEXT_SYNC=1，跳过文档同步检查"
        return 0
    fi
    
    # 检查是否存在 AI Context 目录
    if [[ ! -d "docs/AI_CONTEXT" ]]; then
        log_debug "未检测到 docs/AI_CONTEXT 目录，跳过检查"
        return 0
    fi
    
    return 1
}

# 显示变更统计
show_change_stats() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 本次提交的变更统计："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    git diff --cached --stat 2>/dev/null || true
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# =============================================================================
# Level 1: 提示模式
# =============================================================================

run_prompt_mode() {
    show_change_stats
    
    log_warn "请确保已同步 AI Context 文档！"
    echo ""
    echo "  运行命令：调用 AI Context Sync Skill 帮我提交代码"
    echo ""
    
    if [[ "$INTERACTIVE_CONFIRM" == "true" ]]; then
        echo -n "是否已完成文档同步？[y/N] "
        read -r -t 30 response || response="n"
        
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            if [[ "$BLOCKING" == "true" ]]; then
                log_error "提交已取消。请先完成文档同步。"
                exit 1
            else
                log_warn "建议在提交后同步文档。"
            fi
        fi
    fi
    
    return 0
}

# =============================================================================
# Level 2: CLI 调用模式
# =============================================================================

run_cli_mode() {
    local cli_path
    
    if ! cli_path=$(detect_ai_cli); then
        log_warn "未检测到 AI CLI 工具，回退到提示模式"
        run_prompt_mode
        return $?
    fi
    
    log_info "检测到 AI CLI: $cli_path"
    log_info "正在执行文档同步分析..."
    
    local diff_content
    diff_content=$(git diff --cached 2>/dev/null || true)
    
    if [[ -z "$diff_content" ]]; then
        log_debug "无暂存变更，跳过同步"
        return 0
    fi
    
    # 执行 CLI 调用
    local exit_code=0
    if timeout "$TIMEOUT" "$cli_path" context-sync --diff "$diff_content" --timeout "$TIMEOUT" 2>/dev/null; then
        exit_code=$?
    else
        exit_code=$?
    fi
    
    case $exit_code in
        0)
            log_info "✅ 文档同步完成"
            # 自动暂存更新的文档
            if [[ -f ".aicontextrc.json" ]]; then
                local auto_stage=$(grep -o '"autoStageUpdatedDocs"[[:space:]]*:[[:space:]]*[^,}]*' .aicontextrc.json | grep -o 'true\|false' || echo "true")
                if [[ "$auto_stage" == "true" ]]; then
                    git add docs/AI_CONTEXT/ 2>/dev/null || true
                fi
            fi
            return 0
            ;;
        1)
            log_warn "文档同步分析失败，继续提交"
            return 0
            ;;
        2)
            log_warn "需要用户确认，请手动运行 AI Context Sync Skill"
            if [[ "$BLOCKING" == "true" ]]; then
                exit 1
            fi
            return 0
            ;;
        124)
            log_warn "CLI 执行超时，回退到提示模式"
            run_prompt_mode
            return $?
            ;;
        *)
            log_warn "CLI 返回未知错误码: $exit_code，回退到提示模式"
            run_prompt_mode
            return $?
            ;;
    esac
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    log_debug "Hook 开始执行，模式: $HOOK_MODE"
    
    # 检查是否应该跳过
    if should_skip; then
        exit 0
    fi
    
    # 根据模式执行
    case "$HOOK_MODE" in
        prompt)
            run_prompt_mode
            ;;
        cli)
            run_cli_mode
            ;;
        auto)
            # 自动检测最佳模式
            if detect_ai_cli &>/dev/null; then
                run_cli_mode
            else
                run_prompt_mode
            fi
            ;;
        *)
            log_error "未知的 HOOK_MODE: $HOOK_MODE"
            exit 1
            ;;
    esac
    
    log_debug "Hook 执行完成"
    exit 0
}

# 执行主函数
main "$@"
