# Installation Guide

## Option 1: One-Command Install (Recommended)
From repository root:

```bash
./install.sh both
```

Targets:
- `./install.sh codex`
- `./install.sh claude`
- `./install.sh both`

## Option 2: Manual Install (Codex)
Install only the essential skill files (`SKILL.md` + runtime folders such as `scripts/`, `references/`, `assets/`, `agents/` when present):

```bash
SKILL_NAME="java-jacoco-coverage-backfill"
TARGET="${CODEX_HOME:-$HOME/.codex}/skills/$SKILL_NAME"
mkdir -p "$TARGET"
cp SKILL.md "$TARGET/SKILL.md"
[ -d scripts ] && cp -R scripts "$TARGET/scripts"
[ -d references ] && cp -R references "$TARGET/references"
[ -d assets ] && cp -R assets "$TARGET/assets"
[ -d agents ] && cp -R agents "$TARGET/agents"
```

If `CODEX_HOME` is not set, Codex commonly uses:
- macOS/Linux: `~/.codex`

## Option 3: Manual Install (Claude Code)
Install only the essential skill files:

```bash
SKILL_NAME="java-jacoco-coverage-backfill"
TARGET="${CLAUDE_HOME:-$HOME/.claude}/skills/$SKILL_NAME"
mkdir -p "$TARGET"
cp SKILL.md "$TARGET/SKILL.md"
[ -d scripts ] && cp -R scripts "$TARGET/scripts"
[ -d references ] && cp -R references "$TARGET/references"
[ -d assets ] && cp -R assets "$TARGET/assets"
[ -d agents ] && cp -R agents "$TARGET/agents"
```

If `CLAUDE_HOME` is not set, Claude Code commonly uses:
- macOS/Linux: `~/.claude`

## Option 4: Install From GitHub Repo
Clone directly:

```bash
git clone https://github.com/changheng10000/java-jacoco-coverage-backfill.git
```

Install to both Codex and Claude Code after clone:

```bash
cd java-jacoco-coverage-backfill
./install.sh both
```

## Verify Installation
1. Ensure the skill directory exists (Codex):
```bash
ls "$CODEX_HOME/skills/java-jacoco-coverage-backfill"
```
2. Ensure the skill directory exists (Claude Code):
```bash
ls "$CLAUDE_HOME/skills/java-jacoco-coverage-backfill"
```
3. Confirm `SKILL.md` exists:
```bash
test -f "$CODEX_HOME/skills/java-jacoco-coverage-backfill/SKILL.md" && echo OK
test -f "$CLAUDE_HOME/skills/java-jacoco-coverage-backfill/SKILL.md" && echo OK
```
4. Confirm scripts are executable:
```bash
ls -l "$CODEX_HOME/skills/java-jacoco-coverage-backfill/scripts"
ls -l "$CLAUDE_HOME/skills/java-jacoco-coverage-backfill/scripts"
```

## Optional: Smoke Test
```bash
"$CODEX_HOME/skills/java-jacoco-coverage-backfill/scripts/detect_build_tool.sh" <your-java-repo>
"$CLAUDE_HOME/skills/java-jacoco-coverage-backfill/scripts/detect_build_tool.sh" <your-java-repo>
```
