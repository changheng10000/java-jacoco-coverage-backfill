# Installation Guide

## Option 1: Manual Install (Recommended)
Clone or copy this folder into your Codex skills directory.

```bash
mkdir -p "$CODEX_HOME/skills"
cp -R java-jacoco-coverage-backfill "$CODEX_HOME/skills/"
```

If `CODEX_HOME` is not set, Codex commonly uses:
- macOS/Linux: `~/.codex`

## Option 2: Install From GitHub Repo
Clone directly:

```bash
git clone <REPO_URL>
mkdir -p "$CODEX_HOME/skills"
cp -R java-jacoco-coverage-backfill "$CODEX_HOME/skills/"
```

## Verify Installation
1. Ensure the skill directory exists:
```bash
ls "$CODEX_HOME/skills/java-jacoco-coverage-backfill"
```
2. Confirm `SKILL.md` exists:
```bash
test -f "$CODEX_HOME/skills/java-jacoco-coverage-backfill/SKILL.md" && echo OK
```
3. Confirm scripts are executable:
```bash
ls -l "$CODEX_HOME/skills/java-jacoco-coverage-backfill/scripts"
```

## Optional: Smoke Test
```bash
"$CODEX_HOME/skills/java-jacoco-coverage-backfill/scripts/detect_build_tool.sh" <your-java-repo>
```
