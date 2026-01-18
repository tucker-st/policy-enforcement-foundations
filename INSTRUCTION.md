
## INSTRUCTION.md
```
# policy-enforcement-foundations — Instructions

This repository provides a minimal, evidence-driven policy gate using **OPA/Rego**.
OPA runs via a Docker container to avoid local dependency installs.

The repo produces:
- `decision.json` (machine-readable)
- `summary.md` (human-readable)
- a non-zero exit code when policy denies (for CI gating)

---

## Preconditions

- Docker installed and running:
  ```bash
  docker info
