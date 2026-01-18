#!/usr/bin/env bash
set -Eeuo pipefail

# Adapter: docker-image-assurance -> policy-enforcement-foundations
#
# Usage:
#   ./adapt_and_gate.sh /absolute/or/relative/path/to/vuln.json
#
# This script:
# - Reads vulnerability output from docker-image-assurance
# - Normalizes severity counts into evidence.json
# - Runs the policy gate in this repo

VULN_JSON="${1:-}"
OUT_DIR="out"

if [[ -z "$VULN_JSON" || ! -f "$VULN_JSON" ]]; then
  echo "ERROR: vuln.json not found or not specified"
  echo "Usage: $0 path/to/vuln.json"
  exit 2
fi

# Safety check: ensure we are in policy-enforcement-foundations
if [[ ! -f Makefile || ! -d policies ]]; then
  echo "ERROR: must be run from policy-enforcement-foundations repo root"
  exit 2
fi

mkdir -p "$OUT_DIR"

echo "Normalizing vulnerability evidence"
echo "Source: $VULN_JSON"
echo

python3 - "$VULN_JSON" "$OUT_DIR/evidence.json" <<'PY'
import json, sys

src = sys.argv[1]
dst = sys.argv[2]

data = json.load(open(src))

severity_counts = {
    "CRITICAL": 0,
    "HIGH": 0,
    "MEDIUM": 0,
    "LOW": 0,
    "UNKNOWN": 0,
}

# Assumes Trivy-style output
for result in data.get("Results", []):
    for vuln in result.get("Vulnerabilities", []) or []:
        sev = vuln.get("Severity", "UNKNOWN").upper()
        severity_counts.setdefault(sev, 0)
        severity_counts[sev] += 1

evidence = {
    "vulns": {
        "critical": severity_counts.get("CRITICAL", 0),
        "high": severity_counts.get("HIGH", 0),
        "medium": severity_counts.get("MEDIUM", 0),
        "low": severity_counts.get("LOW", 0),
        "unknown": severity_counts.get("UNKNOWN", 0),
    },
    "controls": {
        "allow_high": False,
        "allow_medium": True,
    },
    "changes": {
        "images_added": 0,
        "images_removed": 0,
    }
}

with open(dst, "w") as f:
    json.dump(evidence, f, indent=2)

print(f"Wrote normalized evidence to {dst}")
PY

echo
echo "Running policy gate"
echo

make gate EXAMPLE="$OUT_DIR/evidence.json"
