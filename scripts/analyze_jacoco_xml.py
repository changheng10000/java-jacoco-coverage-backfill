#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
import xml.etree.ElementTree as ET


METRICS = ("CLASS", "METHOD", "LINE", "BRANCH")


def pct(missed: int, covered: int) -> float | None:
    total = missed + covered
    if total == 0:
        return None
    return covered * 100.0 / total


def load_xml(path: Path) -> ET.Element:
    return ET.parse(path).getroot()


def sourcefile_missed_branch_lines(root: ET.Element) -> dict[str, list[int]]:
    result: dict[str, list[int]] = {}
    for pkg in root.findall("package"):
        pkg_name = pkg.attrib["name"]
        for sourcefile in pkg.findall("sourcefile"):
            source_name = sourcefile.attrib["name"]
            class_name = f"{pkg_name}/{source_name[:-5]}" if source_name.endswith(".java") else f"{pkg_name}/{source_name}"
            missed = []
            for line in sourcefile.findall("line"):
                mb = int(line.attrib.get("mb", "0"))
                cb = int(line.attrib.get("cb", "0"))
                if mb + cb > 0 and mb > 0:
                    missed.append(int(line.attrib["nr"]))
            result[class_name] = missed
    return result


def class_metrics(root: ET.Element) -> list[dict]:
    missed_lines = sourcefile_missed_branch_lines(root)
    rows: list[dict] = []
    for pkg in root.findall("package"):
        for clazz in pkg.findall("class"):
            class_name = clazz.attrib["name"]
            counters: dict[str, tuple[int, int]] = {}
            for counter in clazz.findall("counter"):
                counters[counter.attrib["type"]] = (
                    int(counter.attrib["missed"]),
                    int(counter.attrib["covered"]),
                )
            branch = counters.get("BRANCH", (0, 0))
            if sum(branch) == 0:
                continue
            row = {
                "class": class_name,
                "covered_branches": branch[1],
                "missed_branches": branch[0],
                "missed_branch_lines": missed_lines.get(class_name, []),
                "metrics": {},
            }
            for metric in METRICS:
                m, c = counters.get(metric, (0, 0))
                row["metrics"][metric] = {
                    "missed": m,
                    "covered": c,
                    "pct": pct(m, c),
                }
            rows.append(row)
    rows.sort(
        key=lambda r: (
            999.0 if r["metrics"]["BRANCH"]["pct"] is None else r["metrics"]["BRANCH"]["pct"],
            -r["missed_branches"],
            999.0 if r["metrics"]["LINE"]["pct"] is None else r["metrics"]["LINE"]["pct"],
        )
    )
    return rows


def module_summary(root: ET.Element) -> dict:
    summary = {}
    for counter in root.findall("counter"):
        metric = counter.attrib["type"]
        if metric not in METRICS:
            continue
        missed = int(counter.attrib["missed"])
        covered = int(counter.attrib["covered"])
        summary[metric] = {
            "missed": missed,
            "covered": covered,
            "pct": pct(missed, covered),
        }
    return summary


def format_pct(value: float | None) -> str:
    return "-" if value is None else f"{value:.2f}"


def print_table(rows: list[dict], top: int) -> None:
    print("Top classes by BRANCH ascending")
    print("class | CLASS% | METHOD% | LINE% | BRANCH% | covered/missed(branch)")
    for row in rows[:top]:
        m = row["metrics"]
        print(
            f"{row['class']} | "
            f"{format_pct(m['CLASS']['pct'])} | "
            f"{format_pct(m['METHOD']['pct'])} | "
            f"{format_pct(m['LINE']['pct'])} | "
            f"{format_pct(m['BRANCH']['pct'])} | "
            f"{row['covered_branches']}/{row['missed_branches']}"
        )


def print_module(summary: dict) -> None:
    print("\nModule summary")
    print("metric | covered/missed | pct")
    for metric in METRICS:
        if metric not in summary:
            continue
        data = summary[metric]
        print(f"{metric} | {data['covered']}/{data['missed']} | {format_pct(data['pct'])}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Analyze JaCoCo XML for class and module coverage.")
    parser.add_argument("--xml", required=True, help="Path to jacoco.xml")
    parser.add_argument("--top", type=int, default=10, help="Top N lowest BRANCH classes")
    parser.add_argument("--out", help="Optional JSON output path")
    parser.add_argument(
        "--selected",
        help="Optional comma-separated class list to print after top table",
    )
    args = parser.parse_args()

    xml_path = Path(args.xml).expanduser().resolve()
    root = load_xml(xml_path)
    rows = class_metrics(root)
    summary = module_summary(root)

    print_table(rows, args.top)
    print_module(summary)

    if args.selected:
        selected = [s.strip() for s in args.selected.split(",") if s.strip()]
        row_map = {row["class"]: row for row in rows}
        print("\nSelected classes")
        print("class | CLASS% | METHOD% | LINE% | BRANCH% | covered/missed(branch) | missed branch lines")
        for class_name in selected:
            row = row_map.get(class_name)
            if not row:
                print(f"{class_name} | - | - | - | - | - | -")
                continue
            m = row["metrics"]
            print(
                f"{class_name} | "
                f"{format_pct(m['CLASS']['pct'])} | "
                f"{format_pct(m['METHOD']['pct'])} | "
                f"{format_pct(m['LINE']['pct'])} | "
                f"{format_pct(m['BRANCH']['pct'])} | "
                f"{row['covered_branches']}/{row['missed_branches']} | "
                f"{row['missed_branch_lines']}"
            )

    if args.out:
        payload = {
            "xml": str(xml_path),
            "module": summary,
            "classes": rows,
            "top": args.top,
        }
        out_path = Path(args.out).expanduser().resolve()
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False))
        print(f"\nWrote snapshot JSON: {out_path}")


if __name__ == "__main__":
    main()
