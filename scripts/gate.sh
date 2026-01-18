#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

INPUT_JSON="${1:-}"
OUT_DIR="${2:-out}"

if [[ -z "${INPUT_JSON}" ]]; then
  echo "Usage: $0 <input.json> [out_dir]" >&2
  exit 2
fi

./scripts/eval_policy.sh "${INPUT_JSON}" "${OUT_DIR}" >/dev/null

ALLOW="$(python3 - "${OUT_DIR}" <<'PY'
import json, sys, pathlib
out_dir = pathlib.Path(sys.argv[1])
decision = json.load(open(out_dir / "decision.json"))
print("true" if decision.get("allow") else "false")
PY
)"

if [[ "${ALLOW}" == "true" ]]; then
  echo "Policy gate: ALLOW"
  exit 0
fi

echo "Policy gate: DENY"
echo "See ${OUT_DIR}/decision.json and ${OUT_DIR}/summary.md"
exit 1
