# Peer review test plan

**Reviewer:** _____________________  
**Date:** _____________________  
**Branch / commit:** `main` @ ___________________

## Environment

- [ ] `./scripts/validate-all.sh` run locally
- [ ] Jenkins job `kijani-kiosk` with `SKIP_AWS_DEPLOY=true`

## Test cases

| ID | Area | Steps | Expected |
|----|------|-------|----------|
| T1 | Serverless unit tests | `npm test` | 3 tests pass |
| T2 | Receipt parser | Invalid JSON without `amount` | Error thrown |
| T3 | Kustomize staging | `kubectl kustomize k8s/overlays/staging` | Valid YAML; `RECEIPTS_BUCKET=kk-payments-receipts-staging` |
| T4 | Kustomize production | `kubectl kustomize k8s/overlays/production` | `RECEIPTS_BUCKET=kk-payments-receipts-production`; replicas: 3 |
| T5 | README | Follow quick start through `validate-all` | Completes without undocumented steps |
| T6 | Jenkins approval | Run main pipeline; reach approval stage | Cannot proceed without reason text |
| T7 | Governance log | Open `docs/ai-governance-log.md` | ≥2 entries; “what it got wrong” not empty |
| T8 | Secrets hygiene | `git grep -i password` in repo | No real secrets in tracked files |

## Severity guide

- **Critical** — blocks deploy or exposes secrets
- **Major** — feature broken or rubric gap
- **Minor** — docs or style

## Sign-off

| Result | Notes |
|--------|-------|
| Pass / Fail | |

Feedback recorded in [peer-feedback-log.md](./peer-feedback-log.md).
