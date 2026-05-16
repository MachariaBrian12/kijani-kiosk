# KijaniKiosk capstone — project scope

> Export to one-page PDF for submission (`docs/project-scope.pdf`).

## Problem statement

KijaniKiosk processes payments in Kubernetes but had no automated path from a completed payment to downstream receipt processing and analytics. Receipts were not flowing into an observable, event-driven pipeline, so operations could not verify payment volume or failures without manual log inspection.

## Track

**Track B — Serverless-first**, with Kubernetes integration as the seam between the payments service and the serverless receipt chain.

## In scope (five items)

1. Four-function serverless receipt chain (`kk-processor`, `kk-notifier`, `kk-analytics`, plus K8s `kk-payments` as the event producer).
2. `kk-payments` on Kubernetes writing receipt JSON to environment-specific S3 buckets.
3. Jenkins pipeline with staging validation, smoke tests, and a production approval gate that records a reason.
4. Repository documentation and architecture diagram so a new engineer can run offline validation in one day.
5. AI governance log and peer-review feedback with at least one documented improvement.

## Out of scope

1. **Multi-region AWS failover** — adds cost and complexity beyond the course lab; single `us-east-1` region is sufficient for the demo.
2. **Managed PostgreSQL in cloud** — Week 9 used in-cluster Postgres references only; provisioning RDS is deferred to a production hardening phase.

## Success criteria (measurable)

| Criterion | How to demonstrate |
|-----------|-------------------|
| `npm test` and `./scripts/validate-all.sh` pass | Terminal output in demo or CI |
| `serverless package` succeeds for staging and production | Jenkins build log or local run |
| Production approval gate requires `APPROVAL_REASON` | Jenkins screenshot with input field |
| `POST /payments` writes to correct S3 bucket per overlay | `kubectl describe configmap` + S3 object key |
| Serverless chain produces analytics log line | CloudWatch log after receipt upload (when AWS active) |

## Architecture

See [architecture.md](./architecture.md) and `docs/architecture.png` (export from Mermaid).
