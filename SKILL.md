---
name: java-jacoco-coverage-backfill
description: Universal Java coverage backfill workflow for any Java project. Detect build tool, add JaCoCo if missing, analyze low-coverage classes, add targeted tests, and iterate with CLASS/METHOD/LINE/BRANCH metrics until threshold is met or blockers are reported.
---

# Java JaCoCo Coverage Backfill (Universal)

## When to use
- User asks to add/fix Java tests.
- User asks to improve coverage.
- User asks for branch-gap based supplementary tests.
- Project is Maven or Gradle based.

## Goals
- Use JaCoCo XML as the coverage source of truth.
- Track four coverage metrics consistently: `CLASS`, `METHOD`, `LINE`, `BRANCH`.
- Prioritize classes with worst `BRANCH` coverage for test backfill.
- Raise branch quality without causing regression on other coverage dimensions.

## Coverage Model
- `CLASS`: covered classes / total classes
- `METHOD`: covered methods / total methods
- `LINE`: covered lines / total lines
- `BRANCH`: covered branches / total branches

- Primary backfill target metric: `BRANCH`
- Secondary guardrail metrics: `CLASS`, `METHOD`, `LINE`

## Inputs And Defaults
- Class selection: 10 lowest `BRANCH`-coverage classes with branch counters.
- Default threshold: `BRANCH >= 80%` for each selected class.
- Secondary constraint: no unexplained regression in `CLASS/METHOD/LINE` for selected classes.
- If user provides different thresholds/scope/metric priorities, follow user input.



## Important: Where Files Go

| Location                                                     | What Goes There |
| ------------------------------------------------------------ | --------------- |
| Skill directory (`${HOME}/.codex/skills/java-jacoco-coverage-backfill`) | scripts         |

## Bundled Scripts (Use First)

Scripts are under `scripts/` and should be preferred over ad-hoc one-off shell snippets.

1. `scripts/detect_build_tool.sh <repo_or_module_path>`
   - Detect Maven/Gradle and resolve effective build root.
2. `scripts/generate_jacoco_report.sh <repo_or_module_path> [--ignore-test-failures]`
   - Generate JaCoCo XML/HTML reports for Maven or Gradle.
3. `scripts/find_jacoco_reports.sh <repo_or_module_path>`
   - Locate all JaCoCo XML report files in mono-repo/multi-module layouts.
4. `scripts/analyze_jacoco_xml.py --xml <report> --top 10 [--out <snapshot.json>] [--selected <class1,class2,...>]`
   - Produce class ranking (BRANCH asc), module metrics, and optional snapshot JSON for diffing.
5. `scripts/compare_jacoco_snapshots.py --before <baseline.json> --after <post.json> [--selected <class1,class2,...>]`
   - Show metric delta at module and class granularity.

## Required workflow

### 1) Discover project layout
1. Detect build system and build root using script:
```bash
scripts/detect_build_tool.sh <repo_or_module_path>
```
2. Detect module(s) to analyze:
   - Prefer module(s) touched by the task.
   - If unspecified, start with the primary module containing Java production code and tests.

### 2) Ensure JaCoCo is configured (mandatory)
If JaCoCo is missing, add it first.

#### Maven (if missing)
- Ensure `org.jacoco:jacoco-maven-plugin` exists in `<build><plugins>`.
- Required executions:
  - `prepare-agent`
  - `report` (bound to `test` phase or invoked via `jacoco:report`)

Reference snippet:
```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.12</version>
  <executions>
    <execution>
      <goals>
        <goal>prepare-agent</goal>
      </goals>
    </execution>
    <execution>
      <id>report</id>
      <phase>test</phase>
      <goals>
        <goal>report</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

#### Gradle (if missing)
- Apply plugin: `id 'jacoco'`.
- Ensure XML report is enabled.
- Ensure `test` finalizes `jacocoTestReport`.

Reference snippet (Groovy DSL):
```groovy
plugins {
  id 'java'
  id 'jacoco'
}

test {
  finalizedBy jacocoTestReport
}

jacocoTestReport {
  dependsOn test
  reports {
    xml.required = true
    html.required = true
  }
}
```

### 3) Generate baseline JaCoCo XML
Use script:
```bash
scripts/generate_jacoco_report.sh <repo_or_module_path>
```

### 4) Locate JaCoCo XML report(s)
Find candidate XML files:
```bash
scripts/find_jacoco_reports.sh <repo_or_module_path>
```
Selection rules:
1. Prefer module-specific report for requested scope.
2. If multiple are relevant, analyze per module.
3. If only one exists, use it.

### 5) Analyze coverage with `jacoco_reporter_server`
For each selected XML report:
1. Call `jacoco_reporter_server` on that file (authoritative source for missed line/branch positions).
2. Use script to compute ranked metrics and baseline snapshot:
```bash
python3 scripts/analyze_jacoco_xml.py \
  --xml <report_path> \
  --top 10 \
  --out .coverage/baseline.json
```
3. Rank classes primarily by `BRANCH` ascending:
   - primary: `BRANCH%` ascending
   - tie-breaker 1: missed branches descending
   - tie-breaker 2: `LINE%` ascending
4. Select top 10 classes with branch counters (or fewer if not available).
5. Extract missed branch lines from `jacoco_reporter_server` or `analyze_jacoco_xml.py` output.
6. Preserve baseline snapshot for delta comparison.

### 6) Design targeted tests
For each selected class:
1. Map missed branch lines to concrete conditions.
2. Add tests for missing branch directions (`true/false`, success/error, allow/deny, found/not-found).
3. Prefer unit tests first; use integration tests only when branch behavior depends on framework/runtime boundaries.
4. Avoid tests that only increase line hits but still miss branch directions.

### 7) Run tests and iterate
1. Run targeted tests first.
2. Regenerate JaCoCo XML.
3. Re-run `jacoco_reporter_server`.
4. Generate post snapshot and compare:
```bash
python3 scripts/analyze_jacoco_xml.py \
  --xml <report_path> \
  --top 10 \
  --out .coverage/post.json

python3 scripts/compare_jacoco_snapshots.py \
  --before .coverage/baseline.json \
  --after .coverage/post.json
```
5. Repeat until completion criteria are met or blockers are confirmed.

## Test design rules
- One test should target one explicit missed-branch intent.
- Use deterministic inputs to force both branch directions.
- Include failure paths (validation, unauthorized, conflict, not found) where relevant.
- Avoid redundant tests that hit same branch direction.
- Keep tests local, readable, and consistent with project conventions.

## Multi-module rule
- Do not merge unrelated module coverage into one ranking unless user requests aggregate mode.
- Default: report baseline and post-change per module.

## Completion criteria
- For selected class set(s):
  - each class reaches `BRANCH >= 80%` (or user-defined threshold), and
  - `CLASS/METHOD/LINE` do not regress without explanation.
- If any selected class remains below target, report blockers:
  - class name
  - current CLASS/METHOD/LINE/BRANCH percentages
  - missed branch lines
  - why not coverable now
  - exact next action needed

## Output format (every run)
1. Project/build detection summary (Maven/Gradle, module scope).
2. JaCoCo setup status:
   - already present, or
   - added/updated files and config changes.
3. Baseline table (selected classes):
   - class name
   - CLASS%, METHOD%, LINE%, BRANCH%
   - covered/missed branch counts
4. Added/updated test files list.
5. Validation commands and pass/fail status.
6. Post-change table for same selected classes with delta columns.
7. Module-level summary before/after for CLASS/METHOD/LINE/BRANCH.
8. Remaining gaps and concrete next tests (if not complete).

## Script-First Commands
```bash
scripts/detect_build_tool.sh .
scripts/generate_jacoco_report.sh .
scripts/find_jacoco_reports.sh .
python3 scripts/analyze_jacoco_xml.py --xml <report_path> --top 10 --out .coverage/baseline.json
python3 scripts/analyze_jacoco_xml.py --xml <report_path> --top 10 --out .coverage/post.json
python3 scripts/compare_jacoco_snapshots.py --before .coverage/baseline.json --after .coverage/post.json
```

## Notes
- Do not modify production code only to increase coverage unless user explicitly requests it.
- Coverage decisions must be based on JaCoCo XML + `jacoco_reporter_server` output.
- If build policy blocks adding JaCoCo, report blocker and required approval explicitly.
