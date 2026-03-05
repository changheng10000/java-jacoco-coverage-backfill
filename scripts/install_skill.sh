#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_DIR")"

TARGET="${1:-both}" # codex | claude | both

CODEX_HOME_DEFAULT="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME_DEFAULT="${CLAUDE_HOME:-$HOME/.claude}"

canonical_path() {
  python3 - "$1" <<'PY'
import os
import sys
print(os.path.realpath(sys.argv[1]))
PY
}

copy_skill() {
  local base_home="$1"
  local tool_name="$2"
  local target_dir="$base_home/skills/$SKILL_NAME"
  local source_real target_real

  mkdir -p "$base_home/skills"
  mkdir -p "$target_dir"

  source_real="$(canonical_path "$SKILL_DIR")"
  target_real="$(canonical_path "$target_dir")"
  if [[ "$source_real" == "$target_real" ]]; then
    echo "Skip $tool_name install: source and target are the same ($target_real)"
    return 0
  fi

  if command -v rsync >/dev/null 2>&1; then
    rsync -a \
      --exclude '.git/' \
      --exclude '__pycache__/' \
      --exclude '.DS_Store' \
      "$SKILL_DIR/" "$target_dir/"
  else
    cp -R "$SKILL_DIR/." "$target_dir/"
  fi

  echo "Installed to $tool_name: $target_dir"
}

case "$TARGET" in
  codex)
    copy_skill "$CODEX_HOME_DEFAULT" "Codex"
    ;;
  claude)
    copy_skill "$CLAUDE_HOME_DEFAULT" "Claude Code"
    ;;
  both)
    copy_skill "$CODEX_HOME_DEFAULT" "Codex"
    copy_skill "$CLAUDE_HOME_DEFAULT" "Claude Code"
    ;;
  *)
    echo "Usage: $0 [codex|claude|both]" >&2
    exit 1
    ;;
esac
