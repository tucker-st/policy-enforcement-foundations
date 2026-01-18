# policy-enforcement-foundations

This repository demonstrates policy evaluation and enforcement gating using Open Policy Agent (OPA). It is intentionally minimal and evidence-driven: inputs are evaluated against explicit policy rules, producing a deterministic allow/deny decision and reviewable artifacts.

This document is the step-by-step operational guide for using the repository on macOS and Linux.

---

## What This Repository Does

Core capabilities:
- Validate policy syntax (OPA policy-as-code)
- Evaluate an input evidence document against policy rules
- Produce machine-readable and human-readable artifacts
- Enforce a gate outcome using a deterministic exit code

Outputs produced by evaluation:
- out/decision.json (machine-readable allow/deny decision with reasons/warnings)
- out/summary.md (human-readable summary suitable for review)

---

## Requirements

Required:
- Docker (Docker Desktop is fine on macOS)
- python3
- make

Notes:
- OPA runs as a container image. No local OPA install is required.

---

## Repository Layout

Key paths:
- policies/policy.rego          Policy rules
- scripts/eval_policy.sh        Evaluates policy and writes artifacts
- scripts/gate.sh               Enforces allow/deny exit code
- scripts/adapt_and_gate.sh     Optional adapter (assurance to enforcement)
- examples/                     Example evidence inputs
- out/                          Output artifacts directory (generated)

---

## Quick Start

From the repository root:

```
make help
make eval EXAMPLE=examples/input.sample.json
make gate EXAMPLE=examples/input.sample.json
```

Expected:
- make eval writes out/decision.json and out/summary.md
- make gate prints "Policy gate: ALLOW" or "Policy gate: DENY"

---

## Make Targets

Show available targets:

```
make help
```

Check prerequisites:

```
make check-tools
```

Evaluate policy (creates artifacts):

```
make eval EXAMPLE=examples/input.sample.json
```

Enforce the gate (exit 0 on allow, non-zero on deny):

```
make gate EXAMPLE=examples/input.sample.json
```

Clean artifacts:

```
make clean
```

---

## Policy Validation (OPA Check)

Validate the policy file parses cleanly under the OPA container:

```
docker run --rm -v "$(pwd)":/work -w /work openpolicyagent/opa:latest check policies/policy.rego
```

If this fails, fix the reported policy line(s) before running evaluation.

---

## Understanding the Evidence Input

The enforcement workflow expects a JSON input document that includes:
- vulnerability severity counts
- policy control toggles (example: allow_high, allow_medium)
- optional change metadata

Common fields:
- vulns.critical
- vulns.high
- vulns.medium
- vulns.low
- vulns.unknown
- controls.allow_high
- controls.allow_medium

Use examples/input.sample.json as a baseline.

---

## Outputs and Review

After a successful evaluation:

1) Machine-readable decision:
- out/decision.json

2) Human-readable summary:
- out/summary.md

Recommended review steps:
- Read out/summary.md first (quick explanation)
- Inspect out/decision.json for structured details

---

## Adapter: Assurance to Enforcement (Optional)

This repository includes an optional adapter script that allows enforcement to be driven by vulnerability evidence produced by docker-image-assurance.

Purpose:
- Read a vulnerability report (vuln.json) produced by docker-image-assurance
- Normalize it into a simple evidence format
- Run the policy gate using the normalized evidence

Preconditions:
- docker-image-assurance has been run successfully
- A vulnerability report exists (for example: docker-image-assurance/out/vuln.json)
- You are running from the root of this repository

Usage:

```
./scripts/adapt_and_gate.sh /path/to/docker-image-assurance/out/vuln.json
```

Example (sibling repositories):

```
./scripts/adapt_and_gate.sh ../docker-image-assurance/out/vuln.json
```

What the adapter does:
- Writes normalized evidence to out/evidence.json
- Runs the standard gate and produces:
  - out/decision.json
  - out/summary.md

Notes:
- The adapter is intentionally minimal and scanner-specific
- Normalization logic is isolated to the adapter
- Policy logic remains unchanged
- This demonstrates decoupling between evidence production and enforcement

---

## Troubleshooting

1) "make: No rule to make target ..."
- Confirm you are in the repository root
- Confirm the file is named Makefile (exact casing)

2) "ERROR: docker daemon not accessible"
- Ensure Docker Desktop is running (macOS) or the docker service is running (Linux)

3) Policy parse errors from opa check
- Run the policy validation command and fix the referenced line numbers
- Re-run opa check until it passes

4) Evaluation fails with exit code 2
- This usually indicates the OPA evaluation step failed
- Run opa check first, then retry make eval

---

## Release Notes

This repository is intended as a foundations example:
- explicit policy rules
- explicit evidence inputs
- explicit decisions and artifacts
- clean gate semantics

Policy rules and thresholds are examples and should be tuned to match your environment and risk tolerance.
