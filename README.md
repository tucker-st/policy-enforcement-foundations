# policy-enforcement-foundations

A focused repository that demonstrates **policy evaluation and enforcement decisions** as a DevSecOps capability layer.

This repository is intentionally designed to **consume evidence artifacts** produced by other controls (e.g., SBOM and vulnerability reports) and produce:

- a machine-readable decision (`decision.json`)
- a human-readable summary (`summary.md`)
- an exit code suitable for CI/CD gating

This is an **enforcement decision layer**, not a scanner and not a platform deployment repo.

---

## Design Intent

This repository demonstrates how enforcement should be implemented in mature DevSecOps environments:

- Hygiene and visibility come first
- Assessment produces evidence artifacts
- Policy evaluates those artifacts
- Enforcement is a deliberate decision point

This repo focuses on the **policy decision** and **gating mechanics**, not on building enterprise policy platforms.

---

## Quick Start

Evaluate the included example input:

```
make eval EXAMPLE=examples/input.sample.json
