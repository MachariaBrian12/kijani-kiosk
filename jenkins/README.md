# Jenkins pipeline

Pipeline definition: [`../Jenkinsfile`](../Jenkinsfile)

## Running without AWS (default)

Set job environment variable:

```
SKIP_AWS_DEPLOY=true
```

The pipeline will:

- Run all unit tests and `serverless package`
- Validate Kustomize overlays
- Run offline smoke tests
- Show the **production approval gate** (with required reason)
- Package production Serverless artifacts without deploying

## Running with AWS (after account activation)

```
SKIP_AWS_DEPLOY=false
```

Add Jenkins credentials:

| ID | Type |
|----|------|
| `aws-access-key-id` | Secret text |
| `aws-secret-access-key` | Secret text |

On merge to `main`, the pipeline deploys staging, smoke-tests, waits for approval, then deploys production.

## Multibranch

Point Jenkins at `https://github.com/MachariaBrian12/kijani-kiosk` and scan `main` plus feature branches (feature branches skip production stages except lint/test).
