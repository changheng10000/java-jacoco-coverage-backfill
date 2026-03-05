#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"

find "$ROOT" -type f \( -name "jacoco.xml" -o -name "jacocoTestReport.xml" \) | sort
