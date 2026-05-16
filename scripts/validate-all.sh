#!/usr/bin/env bash
# Run full offline validation (no AWS deploy). Mirrors Jenkins lint/test stages.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Serverless tests & package"
npm ci
npm test
npx serverless print --stage staging
npx serverless package --stage staging
npx serverless package --stage production

echo "==> kk-payments service"
cd services/kk-payments
npm ci
npm run lint
npm test
cd "$ROOT"

echo "==> Kubernetes kustomize"
kubectl kustomize k8s/overlays/staging >/dev/null
kubectl kustomize k8s/overlays/production >/dev/null

echo ""
echo "All offline checks passed."
echo "When AWS is ready: SKIP_AWS_DEPLOY=false ./scripts/deploy-staging.sh"
