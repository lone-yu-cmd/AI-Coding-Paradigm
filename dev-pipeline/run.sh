#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# dev-pipeline/run.sh - Autonomous Dev Pipeline Runner
#
# Drives the prizm-dev-team multi-agent team through iterative
# CodeBuddy CLI sessions to build a complete app from a feature list.
#
# Usage:
#   ./run.sh run [feature-list.json]    Start/resume the pipeline
#   ./run.sh status [feature-list.json] Show pipeline status
#   ./run.sh reset                      Clear all state and start fresh
#
# Environment Variables:
#   MAX_RETRIES           Max retries per feature (default: 3)
#   SESSION_TIMEOUT       Session timeout in seconds (default: 3600)
#   CODEBUDDY_CLI         CLI command name (default: cbc)
#   HEARTBEAT_STALE_THRESHOLD  Heartbeat stale threshold in seconds (default: 600)
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$SCRIPT_DIR/state"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Configuration (override via environment variables)
MAX_RETRIES=${MAX_RETRIES:-3}
SESSION_TIMEOUT=${SESSION_TIMEOUT:-3600}
HEARTBEAT_STALE_THRESHOLD=${HEARTBEAT_STALE_THRESHOLD:-600}
CODEBUDDY_CLI=${CODEBUDDY_CLI:-"cbc"}

# Feature list path (set in main, used by cleanup trap)
FEATURE_LIST=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}    $(date '+%Y-%m-%d %H:%M:%S') $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}    $(date '+%Y-%m-%d %H:%M:%S') $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC}   $(date '+%Y-%m-%d %H:%M:%S') $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*"; }

# ============================================================
# Graceful Shutdown
# ============================================================

cleanup() {
    echo ""
    log_warn "Received interrupt signal. Saving state..."

    if [[ -n "$FEATURE_LIST" && -f "$FEATURE_LIST" ]]; then
        python3 "$SCRIPTS_DIR/update-feature-status.py" \
            --feature-list "$FEATURE_LIST" \
            --state-dir "$STATE_DIR" \
            --action pause 2>/dev/null || true
    fi

    log_info "Pipeline paused. Run './run.sh run' to resume."
    exit 130
}
trap cleanup SIGINT SIGTERM

# ============================================================
# Dependency Check
# ============================================================

check_dependencies() {
    # Check for jq
    if ! command -v jq &>/dev/null; then
        log_error "jq is required but not installed. Install with: brew install jq"
        exit 1
    fi

    # Check for python3
    if ! command -v python3 &>/dev/null; then
        log_error "python3 is required but not installed."
        exit 1
    fi

    # Check for CodeBuddy CLI
    if ! command -v "$CODEBUDDY_CLI" &>/dev/null; then
        log_warn "CodeBuddy CLI '$CODEBUDDY_CLI' not found in PATH."
        log_warn "Set CODEBUDDY_CLI environment variable to the correct command."
        log_warn "Continuing anyway (will fail when spawning sessions)..."
    fi
}

# ============================================================
# Main Loop
# ============================================================

main() {
    local feature_list="${1:-.dev-pipeline/feature-list.json}"

    # Resolve to absolute path
    if [[ ! "$feature_list" = /* ]]; then
        feature_list="$(pwd)/$feature_list"
    fi

    FEATURE_LIST="$feature_list"

    # Validate feature list exists
    if [[ ! -f "$feature_list" ]]; then
        log_error "Feature list not found: $feature_list"
        log_info "Create a feature list first using the app-planner skill,"
        log_info "or provide a path: ./run.sh run <path-to-feature-list.json>"
        exit 1
    fi

    check_dependencies

    # Initialize pipeline state if needed
    if [[ ! -f "$STATE_DIR/pipeline.json" ]]; then
        log_info "Initializing pipeline state..."
        local init_result
        init_result=$(python3 "$SCRIPTS_DIR/init-pipeline.py" \
            --feature-list "$feature_list" \
            --state-dir "$STATE_DIR" 2>&1)

        local init_valid
        init_valid=$(echo "$init_result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('valid', False))" 2>/dev/null || echo "False")

        if [[ "$init_valid" != "True" ]]; then
            log_error "Pipeline initialization failed:"
            echo "$init_result"
            exit 1
        fi

        local features_count
        features_count=$(echo "$init_result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('features_count', 0))" 2>/dev/null || echo "0")
        log_success "Pipeline initialized with $features_count features"
    else
        log_info "Resuming existing pipeline..."
    fi

    # Print header
    echo ""
    echo -e "${BOLD}════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}          Dev-Pipeline Runner Started${NC}"
    echo -e "${BOLD}════════════════════════════════════════════════════${NC}"
    log_info "Feature list: $feature_list"
    log_info "Max retries per feature: $MAX_RETRIES"
    log_info "Session timeout: ${SESSION_TIMEOUT}s"
    log_info "CodeBuddy CLI: $CODEBUDDY_CLI"
    echo -e "${BOLD}════════════════════════════════════════════════════${NC}"
    echo ""

    # Main processing loop
    local session_count=0

    while true; do
        # Check for stuck features
        local stuck_result
        stuck_result=$(python3 "$SCRIPTS_DIR/detect-stuck.py" \
            --state-dir "$STATE_DIR" \
            --feature-list "$FEATURE_LIST" \
            --max-retries "$MAX_RETRIES" \
            --stale-threshold "$HEARTBEAT_STALE_THRESHOLD" 2>/dev/null || echo '{"stuck_count": 0}')

        local stuck_count
        stuck_count=$(echo "$stuck_result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stuck_count', 0))" 2>/dev/null || echo "0")

        if [[ "$stuck_count" -gt 0 ]]; then
            log_warn "Detected $stuck_count stuck feature(s):"
            echo "$stuck_result" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for f in data.get('stuck_features', []):
    print(f'  - {f[\"feature_id\"]}: {f[\"reason\"]} — {f[\"suggestion\"]}')
" 2>/dev/null || true
        fi

        # Find next feature to process
        local next_feature
        next_feature=$(python3 "$SCRIPTS_DIR/update-feature-status.py" \
            --feature-list "$feature_list" \
            --state-dir "$STATE_DIR" \
            --max-retries "$MAX_RETRIES" \
            --action get_next 2>/dev/null)

        if [[ "$next_feature" == "PIPELINE_COMPLETE" ]]; then
            echo ""
            log_success "════════════════════════════════════════════════════"
            log_success "  All features completed! Pipeline finished."
            log_success "  Total sessions: $session_count"
            log_success "════════════════════════════════════════════════════"
            break
        fi

        if [[ "$next_feature" == "PIPELINE_BLOCKED" ]]; then
            log_warn "All remaining features are blocked by dependencies or failed."
            log_warn "Run './run.sh status' to see details."
            log_warn "Waiting 60s before re-checking... (Ctrl+C to stop)"
            sleep 60
            continue
        fi

        # Parse feature info
        local feature_id feature_title retry_count resume_phase
        feature_id=$(echo "$next_feature" | jq -r '.feature_id')
        feature_title=$(echo "$next_feature" | jq -r '.title')
        retry_count=$(echo "$next_feature" | jq -r '.retry_count // 0')
        resume_phase=$(echo "$next_feature" | jq -r '.resume_from_phase // "null"')

        echo ""
        echo -e "${BOLD}────────────────────────────────────────────────────${NC}"
        log_info "Feature: ${BOLD}$feature_id${NC} — $feature_title"
        log_info "Retry: $retry_count / $MAX_RETRIES"
        if [[ "$resume_phase" != "null" ]]; then
            log_info "Resuming from Phase $resume_phase"
        fi
        echo -e "${BOLD}────────────────────────────────────────────────────${NC}"

        # Generate session ID and bootstrap prompt
        local session_id run_id
        run_id=$(jq -r '.run_id' "$STATE_DIR/pipeline.json")
        session_id="${feature_id}-$(date +%Y%m%d%H%M%S)"

        local session_dir="$STATE_DIR/features/$feature_id/sessions/$session_id"
        mkdir -p "$session_dir/logs"

        local bootstrap_prompt="$session_dir/bootstrap-prompt.md"
        python3 "$SCRIPTS_DIR/generate-bootstrap-prompt.py" \
            --feature-list "$feature_list" \
            --feature-id "$feature_id" \
            --session-id "$session_id" \
            --run-id "$run_id" \
            --retry-count "$retry_count" \
            --resume-phase "$resume_phase" \
            --state-dir "$STATE_DIR" \
            --output "$bootstrap_prompt" >/dev/null 2>&1

        # Update current session tracking
        python3 -c "
import json, sys
from datetime import datetime
data = {
    'feature_id': '$feature_id',
    'session_id': '$session_id',
    'started_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
}
with open('$STATE_DIR/current-session.json', 'w') as f:
    json.dump(data, f, indent=2)
"

        # Run CodeBuddy CLI session
        log_info "Spawning CodeBuddy session: $session_id"
        local exit_code=0

        if timeout "$SESSION_TIMEOUT" "$CODEBUDDY_CLI" \
            --print "$bootstrap_prompt" \
            --yes \
            2>&1 | tee "$session_dir/logs/session.log"; then
            exit_code=0
        else
            exit_code=$?
        fi

        # Check session outcome
        local session_status_file="$session_dir/session-status.json"
        local session_status

        if [[ $exit_code -eq 124 ]]; then
            log_warn "Session timed out after ${SESSION_TIMEOUT}s"
            session_status="timed_out"
        elif [[ -f "$session_status_file" ]]; then
            session_status=$(python3 "$SCRIPTS_DIR/check-session-status.py" \
                --status-file "$session_status_file" 2>/dev/null)
        else
            log_warn "Session ended without status file — treating as crashed"
            session_status="crashed"
        fi

        log_info "Session result: $session_status"

        # Update feature status based on session outcome
        python3 "$SCRIPTS_DIR/update-feature-status.py" \
            --feature-list "$feature_list" \
            --state-dir "$STATE_DIR" \
            --feature-id "$feature_id" \
            --session-status "$session_status" \
            --session-id "$session_id" \
            --max-retries "$MAX_RETRIES" \
            --action update >/dev/null 2>&1

        session_count=$((session_count + 1))

        # Brief pause before next iteration
        log_info "Pausing 5s before next feature..."
        sleep 5
    done
}

# ============================================================
# Entry Point
# ============================================================

show_help() {
    echo "Usage: $0 <command> [feature-list.json]"
    echo ""
    echo "Commands:"
    echo "  run      Start or resume the pipeline (default)"
    echo "  status   Show current pipeline status"
    echo "  reset    Clear all state and start fresh"
    echo "  help     Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  MAX_RETRIES           Max retries per feature (default: 3)"
    echo "  SESSION_TIMEOUT       Session timeout in seconds (default: 3600)"
    echo "  CODEBUDDY_CLI         CLI command name (default: cbc)"
    echo "  HEARTBEAT_STALE_THRESHOLD  Heartbeat stale threshold in seconds (default: 600)"
    echo ""
    echo "Examples:"
    echo "  ./run.sh run                                    # Run with default feature-list.json"
    echo "  ./run.sh run /path/to/feature-list.json         # Run with custom feature list"
    echo "  ./run.sh status                                 # Show pipeline status"
    echo "  MAX_RETRIES=5 SESSION_TIMEOUT=7200 ./run.sh run # Custom config"
}

case "${1:-run}" in
    run|resume)
        main "${2:-.dev-pipeline/feature-list.json}"
        ;;
    status)
        check_dependencies
        if [[ ! -f "$STATE_DIR/pipeline.json" ]]; then
            log_error "No pipeline state found. Run './run.sh run' first."
            exit 1
        fi
        python3 "$SCRIPTS_DIR/update-feature-status.py" \
            --feature-list "${2:-.dev-pipeline/feature-list.json}" \
            --state-dir "$STATE_DIR" \
            --action status
        ;;
    reset)
        log_warn "Resetting pipeline state..."
        rm -rf "$STATE_DIR"
        log_success "State cleared. Run './run.sh run' to start fresh."
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
