#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"

if [[ -f "$ROOT/pom.xml" ]]; then
  echo "TOOL=maven"
  echo "ROOT=$ROOT"
  exit 0
fi

if [[ -f "$ROOT/build.gradle" || -f "$ROOT/build.gradle.kts" ]]; then
  echo "TOOL=gradle"
  echo "ROOT=$ROOT"
  exit 0
fi

MAVEN_FILE="$(find "$ROOT" -maxdepth 4 -type f -name pom.xml | head -n 1 || true)"
if [[ -n "$MAVEN_FILE" ]]; then
  echo "TOOL=maven"
  echo "ROOT=$(dirname "$MAVEN_FILE")"
  exit 0
fi

GRADLE_FILE="$(find "$ROOT" -maxdepth 4 -type f \( -name build.gradle -o -name build.gradle.kts \) | head -n 1 || true)"
if [[ -n "$GRADLE_FILE" ]]; then
  echo "TOOL=gradle"
  echo "ROOT=$(dirname "$GRADLE_FILE")"
  exit 0
fi

echo "TOOL=unknown"
echo "ROOT=$ROOT"
echo "ERROR=No Maven/Gradle build file found under $ROOT" >&2
exit 1
