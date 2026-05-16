#!/usr/bin/env bash
# Deploy KijaniKiosk serverless stack to AWS staging and run a smoke upload.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Checking AWS credentials..."
if ! aws sts get-caller-identity; then
  echo ""
  echo "ERROR: AWS credentials not configured."
  echo "Run one of:"
  echo "  aws configure          # access key + secret"
  echo "  aws login              # AWS SSO (if your org uses it)"
  echo ""
  echo "Then re-run: ./scripts/deploy-staging.sh"
  exit 1
fi

echo "==> Installing dependencies..."
npm ci 2>/dev/null || npm install

echo "==> Running unit tests..."
npm test

echo "==> Deploying to staging..."
npm run deploy:staging

echo "==> Stack info:"
npm run info:staging

echo "==> Uploading sample receipt..."
./scripts/upload-test-receipt.sh staging

echo ""
echo "Done. Check CloudWatch log groups for kk-processor, kk-notifier, kk-analytics."
