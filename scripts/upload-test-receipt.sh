#!/usr/bin/env bash
# Upload a sample receipt to trigger the serverless chain (requires AWS CLI + deployed stack).
set -euo pipefail

STAGE="${1:-staging}"
RECEIPT_FILE="${2:-tests/fixtures/sample-receipt.json}"
BUCKET="kk-payments-receipts-${STAGE}"
PAYMENT_ID="$(node -p "JSON.parse(require('fs').readFileSync('${RECEIPT_FILE}','utf8')).paymentId")"
KEY="receipts/${PAYMENT_ID}.json"

echo "Uploading ${RECEIPT_FILE} → s3://${BUCKET}/${KEY}"
aws s3 cp "${RECEIPT_FILE}" "s3://${BUCKET}/${KEY}" --content-type application/json
echo "Done. Check CloudWatch logs for kk-processor → kk-notifier → kk-analytics."
