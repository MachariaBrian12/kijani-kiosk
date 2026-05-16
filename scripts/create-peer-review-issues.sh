#!/usr/bin/env bash
# Step 6: Create peer-review GitHub issues for the capstone.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Checking gh CLI..."
gh auth status

echo ""
echo "==> Creating issues..."

gh issue create \
  --title "Document SKIP_AWS_DEPLOY in README" \
  --body "Peer review: document offline Jenkins mode for builds when AWS is not yet active.

**Resolution target:** README § CI/CD and jenkins/README.md"

gh issue create \
  --title "Add validate-all offline script" \
  --body "Peer review: single script to run all pre-Jenkins offline checks (tests, serverless package, kustomize).

**Resolution target:** scripts/validate-all.sh"

gh issue create \
  --title "Export architecture PNG for submission" \
  --body "Peer review: export Mermaid diagram from docs/architecture.md to docs/architecture.png for capstone PDF/slides.

**Resolution target:** docs/architecture.png"

echo ""
echo "Done. List open issues:"
gh issue list
