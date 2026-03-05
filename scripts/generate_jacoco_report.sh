#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
IGNORE_FAILURES="${2:-}"

eval "$("$SCRIPT_DIR/detect_build_tool.sh" "$PROJECT_DIR")"

if [[ "$TOOL" == "unknown" ]]; then
  echo "Cannot generate JaCoCo report: build tool is unknown." >&2
  exit 1
fi

cd "$ROOT"

if [[ "$TOOL" == "maven" ]]; then
  if [[ "$IGNORE_FAILURES" == "--ignore-test-failures" ]]; then
    echo "Running: mvn -q -Dmaven.test.failure.ignore=true test jacoco:report"
    mvn -q -Dmaven.test.failure.ignore=true test jacoco:report
  else
    echo "Running: mvn -q test jacoco:report"
    mvn -q test jacoco:report
  fi
  exit 0
fi

GRADLE_BIN="./gradlew"
if [[ ! -x "$GRADLE_BIN" ]]; then
  GRADLE_BIN="gradle"
fi

if [[ "$IGNORE_FAILURES" == "--ignore-test-failures" ]]; then
  echo "Running: $GRADLE_BIN test jacocoTestReport --continue"
  "$GRADLE_BIN" test jacocoTestReport --continue
else
  echo "Running: $GRADLE_BIN test jacocoTestReport"
  "$GRADLE_BIN" test jacocoTestReport
fi
