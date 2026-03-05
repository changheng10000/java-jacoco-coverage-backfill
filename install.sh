#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$SCRIPT_DIR"
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

prepare_payload() {
  local payload_dir="$1"
  mkdir -p "$payload_dir"

  if [[ ! -f "$SKILL_DIR/SKILL.md" ]]; then
    echo "SKILL.md not found in $SKILL_DIR" >&2
    exit 1
  fi
  cp "$SKILL_DIR/SKILL.md" "$payload_dir/SKILL.md"

  for dir_name in scripts references assets agents; do
    if [[ -d "$SKILL_DIR/$dir_name" ]]; then
      cp -R "$SKILL_DIR/$dir_name" "$payload_dir/$dir_name"
    fi
  done

  python3 - "$payload_dir" <<'PY'
import os
import shutil
import sys

root = sys.argv[1]
drop_dirs = {"__pycache__", ".git"}
drop_files = {".DS_Store"}

for current_root, dirnames, filenames in os.walk(root, topdown=True):
    keep = []
    for d in dirnames:
        if d in drop_dirs:
            shutil.rmtree(os.path.join(current_root, d), ignore_errors=True)
        else:
            keep.append(d)
    dirnames[:] = keep
    for f in filenames:
        if f in drop_files:
            path = os.path.join(current_root, f)
            try:
                os.remove(path)
            except FileNotFoundError:
                pass
PY
}

sync_dir_python() {
  local src="$1"
  local dst="$2"
  python3 - "$src" "$dst" <<'PY'
import os
import shutil
import sys

src, dst = sys.argv[1], sys.argv[2]
os.makedirs(dst, exist_ok=True)

src_entries = set(os.listdir(src))
dst_entries = set(os.listdir(dst))

for name in dst_entries - src_entries:
    target = os.path.join(dst, name)
    if os.path.isdir(target) and not os.path.islink(target):
        shutil.rmtree(target)
    else:
        os.remove(target)

for name in src_entries:
    s = os.path.join(src, name)
    d = os.path.join(dst, name)
    if os.path.isdir(s) and not os.path.islink(s):
        if os.path.exists(d):
            shutil.rmtree(d)
        shutil.copytree(s, d)
    else:
        shutil.copy2(s, d)
PY
}

copy_skill() {
  local base_home="$1"
  local tool_name="$2"
  local target_dir="$base_home/skills/$SKILL_NAME"
  local source_real target_real
  local payload_dir

  mkdir -p "$base_home/skills"
  mkdir -p "$target_dir"

  source_real="$(canonical_path "$SKILL_DIR")"
  target_real="$(canonical_path "$target_dir")"
  if [[ "$source_real" == "$target_real" ]]; then
    echo "Skip $tool_name install: source and target are the same ($target_real)"
    return 0
  fi

  payload_dir="$(mktemp -d)"
  prepare_payload "$payload_dir"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$payload_dir/" "$target_dir/"
  else
    sync_dir_python "$payload_dir" "$target_dir"
  fi
  rm -rf "$payload_dir"

  echo "Installed to $tool_name: $target_dir (essential files only)"
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
