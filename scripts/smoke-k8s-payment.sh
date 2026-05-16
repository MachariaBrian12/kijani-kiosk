#!/usr/bin/env bash
# POST a payment to kk-payments and verify receipt upload (port-forward or ingress).
set -euo pipefail

NAMESPACE="${1:-kijani-staging}"
MODE="${2:-port-forward}"

if [[ "${MODE}" == "port-forward" ]]; then
  echo "Port-forwarding kk-payments:3000 → local 9300 (Ctrl+C to stop after smoke)..."
  kubectl port-forward -n "${NAMESPACE}" svc/kk-payments 9300:3000 &
  PF_PID=$!
  trap 'kill ${PF_PID} 2>/dev/null' EXIT
  sleep 2
  URL="http://127.0.0.1:9300/payments"
else
  URL="${MODE}"
fi

echo "POST ${URL}"
curl -sf -X POST "${URL}" \
  -H 'Content-Type: application/json' \
  -d '{"amount": 999.5, "currency": "KES", "metadata": {"terminalId": "KIOSK-01"}}' | jq .

echo "Check S3 bucket from ConfigMap and CloudWatch for serverless chain."
