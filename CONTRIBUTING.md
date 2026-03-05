# Contributing

## Scope
This repository provides a reusable Codex skill and scripts for Java JaCoCo coverage backfill.

## Development Principles
- Keep the skill deterministic where possible via scripts.
- Preserve compatibility with both Maven and Gradle projects.
- Keep `SKILL.md` concise and script-first.
- Coverage logic must stay consistent across `CLASS/METHOD/LINE/BRANCH`.

## Local Validation Checklist
1. Script sanity:
```bash
scripts/detect_build_tool.sh .
scripts/find_jacoco_reports.sh .
```
2. Python script syntax:
```bash
python3 -m py_compile scripts/analyze_jacoco_xml.py scripts/compare_jacoco_snapshots.py
```
3. End-to-end on a sample Java repo:
- Generate report
- Analyze baseline
- Compare baseline/post snapshots

## Pull Request Expectations
- Describe what changed and why.
- Include before/after output for at least one example project.
- Keep changes small and focused when possible.
