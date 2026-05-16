# Thursday governance checklist — deployed stack assessment

Assessed against **offline / packaged** configuration until AWS account activation completes.  
Re-run with `serverless info --stage staging` after deploy and update the **Deployed** column.

| # | Control | Staging (configured) | Production (configured) | Finding | Remediation |
|---|---------|---------------------|-------------------------|---------|-------------|
| 1 | **Least-privilege IAM** | Lambda role: S3 Get/Put/List on three stage buckets only | Same pattern with `production` suffix | Pass in `serverless.yml` | After deploy: run IAM Access Analyzer |
| 2 | **Encryption at rest** | S3 buckets use SSE-S256 in CloudFormation | Same | Pass in template | Enable bucket versioning for prod |
| 3 | **No secrets in code** | `.gitignore` blocks `.env*`; secrets via K8s Secret + Jenkins credentials | Same | Pass | Rotate AWS keys if ever committed |
| 4 | **Human approval for production** | Jenkins `input` requires `APPROVAL_REASON` | Same | Pass in Jenkinsfile | Screenshot approval in Loom demo |
| 5 | **Structured logging** | Lambdas log JSON; analytics emits aggregate object | Same | Pass in handlers | Add CloudWatch metric filters post-deploy |
| 6 | **AI-assisted code reviewed** | `docs/ai-governance-log.md` entries with non-empty “what it got wrong” | Same | Pass | Slide deck references log entries |

## Post-AWS activation checklist

- [ ] `aws sts get-caller-identity` succeeds
- [ ] `SKIP_AWS_DEPLOY=false` Jenkins build deploys staging
- [ ] `./scripts/upload-test-receipt.sh staging` triggers all three Lambdas
- [ ] `./scripts/smoke-k8s-payment.sh kijani-staging` after K8s deploy
- [ ] Update this table **Deployed** column with ARNs from `serverless info`
