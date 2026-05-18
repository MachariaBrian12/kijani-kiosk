# Pipeline demo checklist (Loom or screenshots)

Record **≤5 minutes**. Use `SKIP_AWS_DEPLOY=true` on Jenkins until AWS is active.

## Shot list

| # | What to show | Command / action |
|---|----------------|------------------|
| 1 | Repo on GitHub | https://github.com/MachariaBrian12/kijani-kiosk |
| 2 | Offline validation green | `./scripts/validate-all.sh` |
| 3 | Jenkins build triggered on `main` | Blue Ocean or Stage View |
| 4 | Parallel stages pass | Lint & Test (serverless + kk-payments + kustomize) |
| 5 | **Approval gate** | Production Approval — enter reason, click Proceed |
| 6 | Offline production package | Log line: "Production package ready" |
| 7 | Release tag | `git show v1.0.0` or GitHub Releases |
| 8 | Architecture PNG in repo | `docs/architecture.png` on GitHub |

## Jenkins job setup (one time)

- New Pipeline → from SCM → GitHub `kijani-kiosk` → branch `main`
- Environment: `SKIP_AWS_DEPLOY=true`
- Build → wait at **Production approval** → fill reason → Proceed

## Narration script (30 sec each)

1. "Track B: K8s kk-payments writes receipts to S3; three Lambdas process them."
2. "Offline mode packages Serverless without AWS until account activates."
3. "Merge to main runs tests and Kustomize validation."
4. "Production deploy requires explicit approval reason — audit trail."
5. "Tag v1.0.0 marks capstone release; cloud deploy follows AWS activation."
