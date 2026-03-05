# Installation Guide

## Option 1: One-Command Install (Recommended)
From repository root:

```bash
./scripts/install_skill.sh both
```

Targets:
- `./scripts/install_skill.sh codex`
- `./scripts/install_skill.sh claude`
- `./scripts/install_skill.sh both`

## Option 2: Manual Install (Codex)
Clone or copy this folder into your Codex skills directory:

```bash
mkdir -p "$CODEX_HOME/skills"
cp -R java-jacoco-coverage-backfill "$CODEX_HOME/skills/"
```

If `CODEX_HOME` is not set, Codex commonly uses:
- macOS/Linux: `~/.codex`

## Option 3: Manual Install (Claude Code)
Clone or copy this folder into your Claude Code skills directory:

```bash
mkdir -p "$CLAUDE_HOME/skills"
cp -R java-jacoco-coverage-backfill "$CLAUDE_HOME/skills/"
```

If `CLAUDE_HOME` is not set, Claude Code commonly uses:
- macOS/Linux: `~/.claude`

## Option 4: Install From GitHub Repo
Clone directly:

```bash
git clone https://github.com/changheng10000/java-jacoco-coverage-backfill.git
mkdir -p "$CODEX_HOME/skills"
cp -R java-jacoco-coverage-backfill "$CODEX_HOME/skills/"
```

Install to both Codex and Claude Code after clone:

```bash
cd java-jacoco-coverage-backfill
./scripts/install_skill.sh both
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
