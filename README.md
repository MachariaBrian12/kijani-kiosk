# KijaniKiosk

Capstone repository for the KijaniKiosk DevOps programme — Track B (serverless receipt chain) with Kubernetes and Jenkins integration planned under `k8s/` and `jenkins/`.

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

## Prerequisites

- Node.js 18+
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
functions/kk-processor/   # Receipt validation
functions/kk-notifier/    # Notification forward
functions/kk-analytics/   # Aggregation + structured summary
lib/                      # Shared S3 and receipt helpers
k8s/                      # Kubernetes manifests (Week 9 integration)
jenkins/                  # CI/CD pipeline
docs/                     # Architecture, governance, reflection
tests/                    # Unit tests and invoke fixtures
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
