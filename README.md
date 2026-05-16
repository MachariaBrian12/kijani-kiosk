# KijaniKiosk

Capstone repository for the KijaniKiosk DevOps programme — Track B (serverless receipt chain) with Kubernetes bridge and Jenkins integration under `k8s/` and `jenkins/`.

## Serverless receipt chain

Three Lambda functions wired by S3 events:

```
kk-payments (K8s) writes receipt JSON
        ↓
kk-payments-receipts-{stage}     →  kk-processor
        ↓
kk-payments-processed-{stage}    →  kk-notifier
        ↓
kk-notifier-output-{stage}       →  kk-analytics (count, total, time range)
```

| Function | Trigger bucket | Role |
|----------|----------------|------|
| `kk-processor` | `kk-payments-receipts-{stage}` | Validate receipt, write processed record |
| `kk-notifier` | `kk-payments-processed-{stage}` | Write notification payload |
| `kk-analytics` | `kk-notifier-output-{stage}` | Aggregate all notifications, structured log |

## Kubernetes bridge

`services/kk-payments` runs in-cluster and writes receipts to S3 (`POST /payments`).  
Kustomize overlays share one Deployment; ConfigMaps set `DB_HOST` and `RECEIPTS_BUCKET` per environment.

| Environment | Namespace | Receipts bucket |
|-------------|-----------|-----------------|
| Staging | `kijani-staging` | `kk-payments-receipts-staging` |
| Production | `kijani-project` | `kk-payments-receipts-production` |

```bash
./scripts/build-payments-image.sh
# minikube image load kijanikiosk/kk-payments:1.1.0
# create secrets — see k8s/secrets/*.example
./scripts/k8s-deploy-staging.sh
./scripts/smoke-k8s-payment.sh kijani-staging
```

Details: [docs/k8s-serverless-bridge.md](docs/k8s-serverless-bridge.md)

## Prerequisites

- Node.js 18+
- kubectl + cluster (Minikube or other)
- Docker (build `kk-payments` image)
- AWS CLI configured (`aws sts get-caller-identity`)
- [Serverless Framework](https://www.serverless.com/) v3 (installed via `npm install`)

## Quick start

```bash
npm install
npm test

# Deploy staging stack (creates buckets + Lambdas)
npm run deploy:staging
npm run info:staging

# Trigger chain with a sample receipt
chmod +x scripts/upload-test-receipt.sh
./scripts/upload-test-receipt.sh staging

# Local HTTP (functions without S3 — use invoke for S3 handlers)
npm run offline
```

## Project layout

```
functions/                # Serverless Lambdas
services/kk-payments/     # K8s payments API → S3 receipts
k8s/base + overlays/      # Kustomize (staging / production)
lib/                      # Shared receipt helpers (serverless)
jenkins/                  # CI/CD pipeline
docs/                     # Architecture, governance, bridge doc
tests/                    # Serverless unit tests
```

## Receipt JSON format

Upload objects as `receipts/{paymentId}.json`:

```json
{
  "paymentId": "pay-001",
  "amount": 1250.75,
  "currency": "KES",
  "timestamp": "2026-05-15T14:30:00.000Z"
}
```

See `tests/fixtures/sample-receipt.json`.
