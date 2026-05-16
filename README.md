# KijaniKiosk

Capstone repository — **Track B (serverless-first)** with Kubernetes integration and Jenkins CI/CD.  
Goal: a new engineer can clone the repo, run offline validation, and understand the full system in one day.

**Repository:** https://github.com/MachariaBrian12/kijani-kiosk

---

## 1. Project overview

KijaniKiosk is a payments platform. This capstone connects:

- **Kubernetes** — `kk-payments` accepts payments and writes receipt JSON to S3  
- **Serverless** — S3 triggers `kk-processor` → `kk-notifier` → `kk-analytics`  
- **Jenkins** — lint, test, staging deploy/package, approval gate, production  

```
POST /payments (K8s) → S3 receipts bucket → Lambdas → CloudWatch analytics log
```

| Document | Purpose |
|----------|---------|
| [docs/project-scope.md](docs/project-scope.md) | Scope PDF source |
| [docs/architecture.md](docs/architecture.md) | Diagram (export PNG for submit) |
| [docs/k8s-serverless-bridge.md](docs/k8s-serverless-bridge.md) | Integration seam |
| [docs/ai-governance-log.md](docs/ai-governance-log.md) | AI tooling audit trail |

---

## 2. Prerequisites

| Tool | Version | Used for |
|------|---------|----------|
| Node.js | 18+ | Serverless + kk-payments service |
| npm | 9+ | Dependencies |
| Docker | 24+ | Build `kk-payments` image |
| kubectl | 1.28+ | Apply Kustomize overlays |
| Minikube or cluster | optional | Run K8s locally |
| AWS CLI | 2.x | Deploy serverless / S3 smoke tests |
| Jenkins | 2.x | CI/CD (optional locally) |

**AWS account** must be fully activated for cloud deploy. Until then, use offline mode (below).

---

## 3. Repository structure

```
kijani-kiosk/
├── Jenkinsfile                 # CI/CD (root — Jenkins default)
├── serverless.yml              # Lambdas + S3 buckets
├── functions/                  # kk-processor, kk-notifier, kk-analytics
├── services/kk-payments/       # K8s payments API (S3 writer)
├── k8s/
│   ├── base/                   # Shared Deployment, Service, Ingress
│   └── overlays/
│       ├── staging/            # namespace kijani-staging
│       └── production/         # namespace kijani-project
├── observability/prometheus/   # Alert rules
├── jenkins/                    # Pipeline notes
├── scripts/                    # validate, deploy, smoke helpers
├── docs/                       # Capstone deliverables (scope, slides, reflection)
└── tests/                      # Serverless unit tests
```

---

## 4. Setup

```bash
git clone https://github.com/MachariaBrian12/kijani-kiosk.git
cd kijani-kiosk

# Serverless project
npm install

# Payments microservice
cd services/kk-payments && npm install && cd ../..

# Environment template (never commit .env)
cp .env.example .env
```

**Offline validation (no AWS):**

```bash
chmod +x scripts/*.sh
./scripts/validate-all.sh
```

---

## 5. Deployment

### A. Serverless (AWS)

```bash
# After: aws sts get-caller-identity
npm run deploy:staging
npm run info:staging
./scripts/upload-test-receipt.sh staging

npm run deploy:production   # after Jenkins approval in CI
```

### B. Kubernetes

```bash
./scripts/build-payments-image.sh
minikube image load kijanikiosk/kk-payments:1.1.0   # if using Minikube

# Secrets — see k8s/secrets/*.example
kubectl create secret generic kk-payments-aws ... -n kijani-staging

./scripts/k8s-deploy-staging.sh
./scripts/smoke-k8s-payment.sh kijani-staging
```

| Environment | Namespace | `RECEIPTS_BUCKET` |
|-------------|-----------|-------------------|
| Staging | `kijani-staging` | `kk-payments-receipts-staging` |
| Production | `kijani-project` | `kk-payments-receipts-production` |

### C. Jenkins

1. Create multibranch pipeline from this repo.  
2. Set `SKIP_AWS_DEPLOY=true` until AWS is ready.  
3. On `main`, pipeline runs tests → offline package → **production approval** (reason required).  
4. When AWS works: `SKIP_AWS_DEPLOY=false` + credentials `aws-access-key-id`, `aws-secret-access-key`.

See [jenkins/README.md](jenkins/README.md).

---

## 6. Testing

| Layer | Command |
|-------|---------|
| Serverless unit | `npm test` |
| Payments service | `cd services/kk-payments && npm test` |
| Full offline CI | `./scripts/validate-all.sh` |
| Peer review plan | [docs/peer-review-test-plan.md](docs/peer-review-test-plan.md) |
| K8s smoke | `./scripts/smoke-k8s-payment.sh kijani-staging` |
| S3 chain smoke | `./scripts/upload-test-receipt.sh staging` (needs AWS) |

---

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Unable to locate credentials` | AWS not configured / account pending | Finish AWS registration; `aws configure` |
| `Repository not found` (git push) | GitHub repo not created yet | Create empty repo on GitHub first |
| Jenkins fails on `kubectl` | No cluster | Install Minikube or skip K8s stage locally |
| `kk-payments` CrashLoop | Missing secrets | Create `kk-payments-secrets` and `kk-payments-aws` |
| S3 chain silent after upload | Lambdas not deployed | `npm run deploy:staging` |
| Bucket name exists error | Global S3 name taken | Change prefix in `serverless.yml` `custom.bucketNames` |

**Production gaps:** [docs/governance-checklist.md](docs/governance-checklist.md)

---

## Capstone deliverables checklist

| # | Deliverable | Location |
|---|-------------|----------|
| 1 | Scope + diagram | `docs/project-scope.md`, export `docs/architecture.png` |
| 2 | Working repo | This repository |
| 3 | Pipeline demo | Jenkins + Loom/screenshots |
| 4 | Peer feedback | `docs/peer-feedback-log.md` + GitHub Issues |
| 5 | Slides | `docs/slides.md` → PDF |
| 6 | Reflection | `docs/reflection.md` → PDF |

**Release tag (before submit):** `git tag -a v1.0.0 -m "Capstone release" && git push origin v1.0.0`
