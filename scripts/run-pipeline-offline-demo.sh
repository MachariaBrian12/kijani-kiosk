#!/usr/bin/env bash
# Mirrors Jenkinsfile offline path (SKIP_AWS_DEPLOY=true) for demo evidence.
# Usage:
#   ./scripts/run-pipeline-offline-demo.sh
#   APPROVAL_REASON="Capstone demo approved" ./scripts/run-pipeline-offline-demo.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
EVIDENCE="${ROOT}/docs/demo-evidence"
LOG="${EVIDENCE}/pipeline-run.log"
SKIP_AWS_DEPLOY="${SKIP_AWS_DEPLOY:-true}"

mkdir -p "${EVIDENCE}"
: > "${LOG}"
exec >> "${LOG}" 2>&1

echo "=============================================="
echo " KijaniKiosk offline pipeline demo"
echo " SKIP_AWS_DEPLOY=${SKIP_AWS_DEPLOY}"
echo " $(date -Iseconds)"
echo "=============================================="

echo ""
echo "[STAGE] Checkout"
git log -1 --oneline

echo ""
echo "[STAGE] Lint & Test — serverless"
if [[ -d node_modules ]]; then echo "node_modules present — skipping npm ci"; else npm ci; fi
npm test
./node_modules/.bin/serverless print --stage staging
./node_modules/.bin/serverless package --stage staging

echo ""
echo "[STAGE] Lint & Test — kk-payments"
cd services/kk-payments
if [[ -d node_modules ]]; then echo "node_modules present — skipping npm ci"; else npm ci; fi
npm run lint
npm test
cd "$ROOT"

echo ""
echo "[STAGE] Validate Kubernetes manifests"
kubectl version --client
kubectl kustomize k8s/overlays/staging > /tmp/kk-staging.yaml
kubectl kustomize k8s/overlays/production > /tmp/kk-production.yaml
echo "Kustomize build OK for staging and production"

echo ""
echo "[STAGE] Offline staging deploy (no AWS)"
echo "SKIP_AWS_DEPLOY=true — packaging only"
./node_modules/.bin/serverless package --stage staging
./scripts/k8s-deploy-staging.sh 2>/dev/null || echo "kubectl apply skipped (no cluster)"

echo ""
echo "[STAGE] Smoke test — staging"
npm test
node -e "
  const r = require('./lib/receipt');
  const f = require('./tests/fixtures/sample-receipt.json');
  const p = r.parseReceipt(f);
  console.log(JSON.stringify({ smoke: 'ok', paymentId: p.paymentId }));
"
node -e "
  const { parseReceipt } = require('./lib/receipt');
  try { parseReceipt({ paymentId: 'x' }); } catch (e) { console.log('FAULT CAUGHT:', e.message); }
"
echo "AWS smoke upload skipped (no AWS account)"

echo ""
echo "=============================================="
echo " [STAGE] Production approval (input gate)"
echo "=============================================="
REASON="${APPROVAL_REASON:-}"
if [[ -z "${REASON}" ]]; then
  read -r -p "Enter APPROVAL_REASON (required): " REASON
fi
if [[ -z "${REASON// }" ]]; then
  echo "ERROR: Production deploy blocked — APPROVAL_REASON is required"
  exit 1
fi
echo "Production approved. Reason: ${REASON}"

echo ""
echo "[STAGE] Offline production package (no AWS)"
./node_modules/.bin/serverless package --stage production
echo "Production package ready. Deploy when AWS account is active."

echo ""
echo "=============================================="
echo " PIPELINE SUCCEEDED (offline demo)"
echo "=============================================="
