#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path


METRICS = ("CLASS", "METHOD", "LINE", "BRANCH")


def load_snapshot(path: Path) -> dict:
    return json.loads(path.read_text())


def fmt(value: float | None) -> str:
    return "-" if value is None else f"{value:.2f}"


def delta(before: float | None, after: float | None) -> str:
    if before is None or after is None:
        return "-"
    return f"{after - before:+.2f}"


def print_module(before: dict, after: dict) -> None:
    print("Module delta")
    print("metric | before | after | delta")
    for metric in METRICS:
        b = before["module"].get(metric, {}).get("pct")
        a = after["module"].get(metric, {}).get("pct")
        print(f"{metric} | {fmt(b)} | {fmt(a)} | {delta(b, a)}")


def class_map(snapshot: dict) -> dict[str, dict]:
    return {row["class"]: row for row in snapshot["classes"]}


def print_classes(before: dict, after: dict, selected: list[str] | None) -> None:
    before_map = class_map(before)
    after_map = class_map(after)
    if selected:
        classes = selected
    else:
        classes = sorted(set(before_map.keys()) | set(after_map.keys()))

    print("\nClass delta")
    print("class | BRANCH before->after(delta) | LINE before->after(delta) | CLASS before->after(delta) | METHOD before->after(delta)")
    for class_name in classes:
        b_row = before_map.get(class_name)
        a_row = after_map.get(class_name)
        if not b_row or not a_row:
            print(f"{class_name} | - | - | - | -")
            continue
        b = b_row["metrics"]
        a = a_row["metrics"]
        print(
            f"{class_name} | "
            f"{fmt(b['BRANCH']['pct'])}->{fmt(a['BRANCH']['pct'])}({delta(b['BRANCH']['pct'], a['BRANCH']['pct'])}) | "
            f"{fmt(b['LINE']['pct'])}->{fmt(a['LINE']['pct'])}({delta(b['LINE']['pct'], a['LINE']['pct'])}) | "
            f"{fmt(b['CLASS']['pct'])}->{fmt(a['CLASS']['pct'])}({delta(b['CLASS']['pct'], a['CLASS']['pct'])}) | "
            f"{fmt(b['METHOD']['pct'])}->{fmt(a['METHOD']['pct'])}({delta(b['METHOD']['pct'], a['METHOD']['pct'])})"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Compare two JaCoCo analysis snapshots.")
    parser.add_argument("--before", required=True, help="Path to baseline snapshot JSON")
    parser.add_argument("--after", required=True, help="Path to post-change snapshot JSON")
    parser.add_argument(
        "--selected",
        help="Optional comma-separated class list; if omitted, compare all classes present in both snapshots",
    )
    args = parser.parse_args()

    before = load_snapshot(Path(args.before).expanduser().resolve())
    after = load_snapshot(Path(args.after).expanduser().resolve())
    selected = None
    if args.selected:
        selected = [item.strip() for item in args.selected.split(",") if item.strip()]

    print_module(before, after)
    print_classes(before, after, selected)


if __name__ == "__main__":
    main()
