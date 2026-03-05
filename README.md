# Java JaCoCo Coverage Backfill Skill

Universal skill for Codex and Claude Code to backfill Java test coverage using JaCoCo, focused on branch-quality improvement with guardrail metrics.

## What This Skill Solves
- Detects Maven/Gradle projects and report locations quickly.
- Standardizes coverage analysis around `CLASS`, `METHOD`, `LINE`, `BRANCH`.
- Prioritizes lowest `BRANCH` classes for targeted test design.
- Supports iterative baseline/post snapshot comparison.
- Works for single-module and multi-module Java repositories.

## Repository Structure
```text
java-jacoco-coverage-backfill/
├── install.sh
├── SKILL.md
├── scripts/
│   ├── detect_build_tool.sh
│   ├── generate_jacoco_report.sh
│   ├── find_jacoco_reports.sh
│   ├── analyze_jacoco_xml.py
│   └── compare_jacoco_snapshots.py
├── INSTALL.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

## Requirements
- Java project built by Maven or Gradle.
- JaCoCo XML report generation enabled (`jacoco.xml` or `jacocoTestReport.xml`).
- Python 3.9+ for analysis scripts.

## Install (Codex + Claude Code)
See [INSTALL.md](INSTALL.md) for complete steps.

Quick one-command install to both tools:
```bash
./install.sh both
```

Install only for Claude Code:
```bash
./install.sh claude
```

## Quick Usage
Run from this skill directory (or call with absolute paths):
```bash
scripts/detect_build_tool.sh <repo_or_module_path>
scripts/generate_jacoco_report.sh <repo_or_module_path>
scripts/find_jacoco_reports.sh <repo_or_module_path>
python3 scripts/analyze_jacoco_xml.py --xml <jacoco.xml> --top 10 --out .coverage/baseline.json
python3 scripts/compare_jacoco_snapshots.py --before .coverage/baseline.json --after .coverage/post.json
```

## Recommended Workflow
1. Generate baseline report and snapshot.
2. Use `jacoco_reporter_server` + snapshot to choose the lowest `BRANCH` classes.
3. Add targeted tests for missing branch directions.
4. Regenerate report and compare snapshots.
5. Repeat until threshold is met or blockers are documented.

## Open Source
- License: [MIT](LICENSE)
- Security policy: [SECURITY.md](SECURITY.md)
- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
