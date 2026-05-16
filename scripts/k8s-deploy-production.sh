#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Applying production overlay (namespace: kijani-project)..."
kubectl apply -k "${ROOT}/k8s/overlays/production"

echo ""
echo "Production RECEIPTS_BUCKET=kk-payments-receipts-production (triggers serverless chain)"
kubectl get pods,svc,ingress -n kijani-project
