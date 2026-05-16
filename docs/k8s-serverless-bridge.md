# Kubernetes ↔ Serverless integration

## Integration seam

`kk-payments` (Kubernetes) accepts `POST /payments` and writes receipt JSON to S3.  
That upload triggers the serverless receipt chain deployed via Serverless Framework.

```
POST /payments (K8s)
       ↓
kk-payments-receipts-{staging|production}
       ↓
kk-processor → kk-notifier → kk-analytics
```

## Environment-specific buckets

| Overlay | Namespace | `RECEIPTS_BUCKET` | `DB_HOST` |
|---------|-----------|-------------------|-----------|
| staging | `kijani-staging` | `kk-payments-receipts-staging` | `postgres.kijani-staging.svc.cluster.local` |
| production | `kijani-project` | `kk-payments-receipts-production` | `postgres.kijani-project.svc.cluster.local` |

The **same** `k8s/base/deployment.yaml` is used for both; only ConfigMap patches differ.

## Deploy checklist

1. `serverless deploy --stage staging` (and `production` when ready)
2. `./scripts/build-payments-image.sh`
3. `minikube image load kijanikiosk/kk-payments:1.1.0` (if using Minikube)
4. Create secrets in target namespace (see `k8s/secrets/`)
5. `./scripts/k8s-deploy-staging.sh`
6. `./scripts/smoke-k8s-payment.sh kijani-staging`
