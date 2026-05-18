# AI governance log

Week 10 eight-field format. All AI-assisted work on this capstone is recorded here.

---

## Entry 1 — Serverless receipt chain

| Field | Value |
|-------|-------|
| **Date** | 2026-05-16 |
| **Tool** | AI coding assistant (Claude) |
| **Task** | Implement `serverless.yml` and three Lambda handlers for the receipt chain |
| **What the AI produced** | Full `serverless.yml` with three S3 buckets, IAM statements, and handlers for processor / notifier / analytics |
| **What it got wrong** | Initially scaffolded `functions/kk-payments/` as a Lambda; that name belongs to the Kubernetes service, not a fourth serverless function |
| **Reviewer change** | Removed `functions/kk-payments/`; documented K8s producer in README; kept three Lambdas only |
| **Checklist item** | Control 3 (no secrets in code) and Control 6 (AI-assisted code reviewed) — verified .gitignore blocks .env*; governance log entry confirms human review before merge |
| **Outcome** | Merged via PR #1; `npm test` passes; `serverless print` validated locally |

---

## Entry 2 — Kubernetes ↔ S3 bridge

| Field | Value |
|-------|-------|
| **Date** | 2026-05-16 |
| **Tool** | AI coding assistant (Claude) |
| **Task** | Implement Kustomize overlays and `services/kk-payments` with `POST /payments` → S3 |
| **What the AI produced** | Kustomize base + staging/production overlays, Node service with `@aws-sdk/client-s3`, deploy scripts |
| **What it got wrong** | Assumed AWS credentials would exist for deploy; did not document `SKIP_AWS_DEPLOY` until the AWS account was still pending activation |
| **Reviewer change** | Added `scripts/validate-all.sh`, Jenkins `SKIP_AWS_DEPLOY=true` default, and `docs/k8s-serverless-bridge.md` |
| **Checklist item** | Control 1 (least-privilege IAM) and Control 3 (no secrets in code) — verified Kustomize overlays use K8s Secret references, not hardcoded values; npm test passes |
| **Outcome** | Feature branch ready; offline validation passes without AWS |

---

## Entry 3 — Jenkins pipeline (offline mode)

| Field | Value |
|-------|-------|
| **Date** | 2026-05-16 |
| **Tool** | AI coding assistant (Claude) |
| **Task** | Jenkinsfile with staging deploy, smoke test, production approval gate |
| **What the AI produced** | Declarative pipeline with parallel test stages and `input` step for approval reason |
| **What it got wrong** | First draft used `text()` parameter type, which is not available on all Jenkins installations |
| **Reviewer change** | Switched to `string(name: 'APPROVAL_REASON')` and map-safe reason extraction |
| **Checklist item** | Control 4 (human approval for production) and Control 6 (AI-assisted code reviewed) — Jenkins input step requires APPROVAL_REASON; this log entry is the documentation |
| **Outcome** | Pipeline runnable on Jenkins without AWS when `SKIP_AWS_DEPLOY=true` |
