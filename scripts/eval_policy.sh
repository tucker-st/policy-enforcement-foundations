#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 027

INPUT_JSON="${1:-}"
OUT_DIR="${2:-out}"

if [[ -z "${INPUT_JSON}" ]]; then
  echo "Usage: $0 <input.json> [out_dir]" >&2
  exit 2
fi

if [[ ! -f "${INPUT_JSON}" ]]; then
  echo "ERROR: Input file not found: ${INPUT_JSON}" >&2
  exit 2
fi

mkdir -p "${OUT_DIR}"

echo "Evaluating policy for input: ${INPUT_JSON}"

docker run --rm \
  -v "$(pwd)":/work \
  -w /work \
  openpolicyagent/opa:latest \
  eval --format=json \
  --data policies/policy.rego \
  --input "${INPUT_JSON}" \
  '{ "allow": data.gate.allow, "reasons": data.gate.reasons_list, "warnings": data.gate.warnings_list }' \
  > "${OUT_DIR}/opa_result.json"

python3 - "${OUT_DIR}" <<'PY'
import json, sys, pathlib

out_dir = pathlib.Path(sys.argv[1])
data = json.load(open(out_dir / "opa_result.json"))

value = data["result"][0]["expressions"][0]["value"]
decision = {
    "allow": bool(value.get("allow", False)),
    "reasons": value.get("reasons", []) or [],
    "warnings": value.get("warnings", []) or [],
}

(out_dir / "decision.json").write_text(json.dumps(decision, indent=2) + "\n", encoding="utf-8")

allow = decision["allow"]
reasons = decision["reasons"]
warnings = decision["warnings"]

summary = ["# Policy Gate Summary\n\n", f"- Allow: `{allow}`\n"]
if reasons:
    summary.append("\n## Reasons\n")
    for r in reasons:
        summary.append(f"- {r}\n")
if warnings:
    summary.append("\n## Warnings\n")
    for w in warnings:
        summary.append(f"- {w}\n")

(out_dir / "summary.md").write_text("".join(summary), encoding="utf-8")
print("allow" if allow else "deny")
PY


echo "Wrote:"
echo "  ${OUT_DIR}/decision.json"
echo "  ${OUT_DIR}/summary.md"
