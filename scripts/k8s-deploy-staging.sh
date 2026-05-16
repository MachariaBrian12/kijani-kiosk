#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Applying staging overlay (namespace: kijani-staging)..."
kubectl apply -k "${ROOT}/k8s/overlays/staging"

echo ""
echo "Required secrets (once per cluster):"
echo "  kk-payments-secrets  — DB_PASSWORD, STRIPE_API_KEY, JWT_SECRET"
echo "  kk-payments-aws      — AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
echo "See k8s/secrets/*.example"
echo ""
kubectl get pods,svc,ingress -n kijani-staging
