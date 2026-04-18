#!/bin/bash
# fork-join.sh — Git worktree manager for SDD parallel execution
# Manages the full lifecycle: fork (create), status (check), join (merge + cleanup)
#
# Usage:
#   bash .claude/hooks/fork-join.sh fork   <branch> <worktree-dir> [base-branch]
#   bash .claude/hooks/fork-join.sh status <worktree-dir>
#   bash .claude/hooks/fork-join.sh list
#   bash .claude/hooks/fork-join.sh join   <worktree-dir> [--no-delete]
#   bash .claude/hooks/fork-join.sh purge  <worktree-dir>

set -e

COMMAND="${1:-help}"
WORKTREE_BASE=".worktrees"

# ─── Helpers ─────────────────────────────────────────────────────────────────
die() { echo "❌ ERROR: $*" >&2; exit 1; }
info() { echo "ℹ️  $*"; }
ok() { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }

ensure_git() {
    git rev-parse --is-inside-work-tree > /dev/null 2>&1 || die "Not inside a git repository."
}

# ─── H3 FIX: Validate branch name to prevent command injection ───────────────
# Branch names containing ; $() ` & | < > could inject into commit message strings.
# Git itself allows many special chars in branch names, but we restrict to safe subset.
validate_branch_name() {
    local BRANCH="$1"
    # Allow: alphanumeric, hyphen, underscore, dot, forward-slash (for feature/name patterns)
    # Block: shell metacharacters ; $ ` & | < > ( ) spaces
    if echo "$BRANCH" | grep -qE '[;$`&|<>()" ]'; then
        die "Branch name '$BRANCH' contains shell metacharacters. Use only: letters, digits, -, _, ., /"
    fi
    # Block path traversal
    if echo "$BRANCH" | grep -qE '\.\.'; then
        die "Branch name '$BRANCH' contains path traversal pattern (..)"
    fi
    # Max length sanity check
    if [ ${#BRANCH} -gt 200 ]; then
        die "Branch name too long (max 200 chars)"
    fi
}

# ─── FORK: Create a new worktree for parallel work ───────────────────────────
cmd_fork() {
    local BRANCH="${2:-}"
    local WORKTREE_DIR="${3:-}"
    local BASE_BRANCH="${4:-$(git branch --show-current)}"

    [ -z "$BRANCH" ] && die "Usage: fork-join.sh fork <branch-name> <worktree-dir> [base-branch]"
    validate_branch_name "$BRANCH"
    [ -z "$WORKTREE_DIR" ] && WORKTREE_DIR="$WORKTREE_BASE/$(echo "$BRANCH" | tr '/' '-')"

    ensure_git

    # Validate branch name doesn't already exist
    if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
        warn "Branch '$BRANCH' already exists. Worktree will check it out."
    fi

    # Create worktree base directory if needed
    mkdir -p "$WORKTREE_BASE"

    # Check if worktree already exists
    if [ -d "$WORKTREE_DIR" ]; then
        die "Worktree directory '$WORKTREE_DIR' already exists. Use 'purge' first or choose a different name."
    fi

    info "Creating worktree: $WORKTREE_DIR (branch: $BRANCH, base: $BASE_BRANCH)"

    # Create new branch from base and add worktree
    git worktree add -b "$BRANCH" "$WORKTREE_DIR" "$BASE_BRANCH" 2>/dev/null || \
    git worktree add "$WORKTREE_DIR" "$BRANCH" 2>/dev/null || \
    die "Failed to create worktree. Check branch name and base branch."

    # Copy .env.example as reference (never the actual .env)
    [ -f ".env.example" ] && cp ".env.example" "$WORKTREE_DIR/.env.example"

    ok "Worktree created: $WORKTREE_DIR"
    echo ""
    echo "  Branch  : $BRANCH"
    echo "  Base    : $BASE_BRANCH"
    echo "  Path    : $(realpath "$WORKTREE_DIR")"
    echo ""
    echo "  Agent working directory: $WORKTREE_DIR"
    echo "  Pass this path to the agent as its working directory."
}

# ─── STATUS: Check a worktree's current state ────────────────────────────────
cmd_status() {
    local WORKTREE_DIR="${2:-}"
    [ -z "$WORKTREE_DIR" ] && die "Usage: fork-join.sh status <worktree-dir>"
    [ -d "$WORKTREE_DIR" ] || die "Worktree directory not found: $WORKTREE_DIR"

    local BRANCH
    local CHANGED
    local STAGED
    local COMMITS
    BRANCH=$(git -C "$WORKTREE_DIR" branch --show-current 2>/dev/null)
    CHANGED=$(git -C "$WORKTREE_DIR" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    STAGED=$(git -C "$WORKTREE_DIR" diff --staged --name-only 2>/dev/null | wc -l | tr -d ' ')
    COMMITS=$(git -C "$WORKTREE_DIR" log --oneline "$(git branch --show-current)..$BRANCH" 2>/dev/null | wc -l | tr -d ' ')

    echo "📊 Worktree Status: $WORKTREE_DIR"
    echo "   Branch    : $BRANCH"
    echo "   New commits: $COMMITS"
    echo "   Staged    : $STAGED files"
    echo "   Modified  : $CHANGED files"

    if [ "$CHANGED" -gt 0 ]; then
        warn "Uncommitted changes detected."
        git -C "$WORKTREE_DIR" diff --name-only 2>/dev/null | while read -r f; do echo "     - $f"; done
    fi
}

# ─── LIST: Show all active worktrees ─────────────────────────────────────────
cmd_list() {
    ensure_git
    echo "📋 Active Worktrees:"
    git worktree list --porcelain 2>/dev/null | awk '
        /^worktree / { wt=$2 }
        /^branch / { branch=$2 }
        /^HEAD / { head=substr($0,6,8) }
        /^$/ { if (wt != "") print "  " wt "\n    branch: " branch "\n    HEAD:   " head; wt=""; branch=""; head="" }
    '
}

# ─── JOIN: Merge worktree branch back and clean up ───────────────────────────
cmd_join() {
    local WORKTREE_DIR="${2:-}"
    local NO_DELETE="${3:-}"
    [ -z "$WORKTREE_DIR" ] && die "Usage: fork-join.sh join <worktree-dir> [--no-delete]"
    [ -d "$WORKTREE_DIR" ] || die "Worktree directory not found: $WORKTREE_DIR"

    local FEATURE_BRANCH
    local BASE_BRANCH
    FEATURE_BRANCH=$(git -C "$WORKTREE_DIR" branch --show-current 2>/dev/null)
    BASE_BRANCH=$(git branch --show-current 2>/dev/null)

    # Validate branch names before using in commit message (H3: command injection defense)
    validate_branch_name "$FEATURE_BRANCH"

    # Ensure worktree has clean state
    local UNCOMMITTED
    UNCOMMITTED=$(git -C "$WORKTREE_DIR" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    if [ "$UNCOMMITTED" -gt 0 ]; then
        die "Worktree has uncommitted changes. Commit or stash before joining."
    fi

    info "Merging $FEATURE_BRANCH → $BASE_BRANCH"

    # Merge feature branch into current branch (no fast-forward for traceability)
    # Use printf to build message safely — never interpolate branch names directly into -m string
    MERGE_MSG=$(printf "chore: join fork-join worktree '%s' into '%s'" "$FEATURE_BRANCH" "$BASE_BRANCH")
    git merge --no-ff "$FEATURE_BRANCH" -m "$MERGE_MSG" 2>/dev/null || {
        warn "Merge conflict detected. Resolve conflicts, then run 'git merge --continue'."
        warn "After resolving, run: bash .claude/hooks/fork-join.sh purge $WORKTREE_DIR"
        exit 1
    }

    ok "Merged $FEATURE_BRANCH into $BASE_BRANCH"

    # Delete worktree unless --no-delete
    if [ "$NO_DELETE" != "--no-delete" ]; then
        git worktree remove "$WORKTREE_DIR" --force 2>/dev/null && ok "Worktree removed: $WORKTREE_DIR"
        git branch -d "$FEATURE_BRANCH" 2>/dev/null && ok "Branch deleted: $FEATURE_BRANCH"
    else
        info "Kept worktree (--no-delete): $WORKTREE_DIR"
    fi
}

# ─── PURGE: Force remove a worktree without merging ──────────────────────────
cmd_purge() {
    local WORKTREE_DIR="${2:-}"
    [ -z "$WORKTREE_DIR" ] && die "Usage: fork-join.sh purge <worktree-dir>"

    local BRANCH=""
    [ -d "$WORKTREE_DIR" ] && BRANCH=$(git -C "$WORKTREE_DIR" branch --show-current 2>/dev/null)

    warn "Purging worktree WITHOUT merging: $WORKTREE_DIR"

    git worktree remove "$WORKTREE_DIR" --force 2>/dev/null
    git worktree prune 2>/dev/null

    [ -n "$BRANCH" ] && git branch -D "$BRANCH" 2>/dev/null && info "Branch deleted: $BRANCH"
    ok "Purged: $WORKTREE_DIR"
}

# ─── HELP ────────────────────────────────────────────────────────────────────
cmd_help() {
    echo "fork-join.sh — Git worktree manager for SDD parallel execution"
    echo ""
    echo "Commands:"
    echo "  fork   <branch> <dir> [base]  Create isolated worktree for parallel agent"
    echo "  status <dir>                  Show worktree health (commits, changes)"
    echo "  list                          List all active worktrees"
    echo "  join   <dir> [--no-delete]    Merge branch back and clean up"
    echo "  purge  <dir>                  Force remove worktree WITHOUT merging"
    echo ""
    echo "Workflow:"
    echo "  1. fork  → agent works in isolation"
    echo "  2. status → verify agent completed cleanly"
    echo "  3. join  → merge results, delete worktree"
}

# ─── Dispatch ────────────────────────────────────────────────────────────────
case "$COMMAND" in
    fork)   cmd_fork "$@" ;;
    status) cmd_status "$@" ;;
    list)   cmd_list "$@" ;;
    join)   cmd_join "$@" ;;
    purge)  cmd_purge "$@" ;;
    help|*) cmd_help ;;
esac
