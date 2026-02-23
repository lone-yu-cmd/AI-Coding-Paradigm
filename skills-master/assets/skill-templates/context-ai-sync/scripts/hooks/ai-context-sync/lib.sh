#!/usr/bin/env bash
#
# AI Context Sync - 通用函数库
# 提供 Hook 脚本使用的通用函数
#

# =============================================================================
# 颜色定义
# =============================================================================

COLOR_RESET="\033[0m"
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_GRAY="\033[90m"

# =============================================================================
# 日志函数
# =============================================================================

# 获取当前时间戳
get_timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# 写入日志文件
write_log() {
    local level="$1"
    local message="$2"
    local log_file="${HOOK_DIR:-$(dirname "${BASH_SOURCE[0]}")}/sync.log"
    
    echo "[$(get_timestamp)] [$level] $message" >> "$log_file"
}

# 信息日志
lib_log_info() {
    local message="$1"
    echo -e "${COLOR_BLUE}[AI Context Sync]${COLOR_RESET} $message"
    write_log "INFO" "$message"
}

# 成功日志
lib_log_success() {
    local message="$1"
    echo -e "${COLOR_GREEN}[AI Context Sync]${COLOR_RESET} ✅ $message"
    write_log "SUCCESS" "$message"
}

# 警告日志
lib_log_warn() {
    local message="$1"
    echo -e "${COLOR_YELLOW}[AI Context Sync]${COLOR_RESET} ⚠️  $message"
    write_log "WARN" "$message"
}

# 错误日志
lib_log_error() {
    local message="$1"
    echo -e "${COLOR_RED}[AI Context Sync]${COLOR_RESET} ❌ $message" >&2
    write_log "ERROR" "$message"
}

# 调试日志
lib_log_debug() {
    local message="$1"
    if [[ "${LOG_LEVEL:-info}" == "debug" ]]; then
        echo -e "${COLOR_GRAY}[AI Context Sync DEBUG]${COLOR_RESET} $message"
    fi
    write_log "DEBUG" "$message"
}

# =============================================================================
# 项目检测函数
# =============================================================================

# 检查是否是 Git 仓库
is_git_repo() {
    git rev-parse --is-inside-work-tree &>/dev/null
}

# 获取 Git 仓库根目录
get_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

# 检查 AI Context 目录是否存在
has_ai_context_dir() {
    [[ -d "docs/AI_CONTEXT" ]]
}

# 检查配置文件是否存在
has_config_file() {
    [[ -f ".aicontextrc.json" ]]
}

# =============================================================================
# 变更检测函数
# =============================================================================

# 获取已暂存文件列表
get_staged_files() {
    git diff --cached --name-only 2>/dev/null
}

# 获取已暂存文件的统计信息
get_staged_stats() {
    git diff --cached --stat 2>/dev/null
}

# 检查是否有代码文件变更（排除文档等）
has_code_changes() {
    local staged_files
    staged_files=$(get_staged_files)
    
    if [[ -z "$staged_files" ]]; then
        return 1
    fi
    
    # 检查是否有非文档文件变更
    local code_extensions="js|ts|jsx|tsx|py|go|rs|java|cpp|c|h|rb|php|swift|kt"
    echo "$staged_files" | grep -qE "\.($code_extensions)$"
}

# 检查是否有文档文件变更
has_doc_changes() {
    local staged_files
    staged_files=$(get_staged_files)
    
    echo "$staged_files" | grep -q "docs/AI_CONTEXT/"
}

# =============================================================================
# 配置读取函数
# =============================================================================

# 从 JSON 配置文件读取值
read_config() {
    local key="$1"
    local default="$2"
    
    if ! has_config_file; then
        echo "$default"
        return
    fi
    
    local value
    value=$(grep -o "\"$key\"[[:space:]]*:[[:space:]]*[^,}]*" .aicontextrc.json | head -1 | sed 's/.*:[[:space:]]*//' | tr -d '"' | tr -d ' ')
    
    if [[ -z "$value" || "$value" == "null" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# 读取布尔配置
read_bool_config() {
    local key="$1"
    local default="$2"
    
    local value
    value=$(read_config "$key" "$default")
    
    if [[ "$value" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# 工具函数
# =============================================================================

# 检查命令是否存在
command_exists() {
    command -v "$1" &>/dev/null
}

# 获取文件大小（字节）
get_file_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        wc -c < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# 检查文件大小是否超过限制
is_file_over_limit() {
    local file="$1"
    local limit="$2"
    
    local size
    size=$(get_file_size "$file")
    
    [[ "$size" -gt "$limit" ]]
}

# 清理日志文件（保留最近 1000 行）
cleanup_log() {
    local log_file="${HOOK_DIR:-$(dirname "${BASH_SOURCE[0]}")}/sync.log"
    
    if [[ -f "$log_file" ]]; then
        local line_count
        line_count=$(wc -l < "$log_file" | tr -d ' ')
        
        if [[ "$line_count" -gt 1000 ]]; then
            tail -500 "$log_file" > "${log_file}.tmp"
            mv "${log_file}.tmp" "$log_file"
        fi
    fi
}
