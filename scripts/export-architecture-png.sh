#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Generating docs/architecture.png from docs/architecture.mmd ..."
npx -y @mermaid-js/mermaid-cli@11.4.0 \
  -i docs/architecture.mmd \
  -o docs/architecture.png \
  -b transparent \
  -w 1920 \
  -H 1080

ls -la docs/architecture.png
echo "Done. Commit with:"
echo "  git add docs/architecture.png docs/architecture.mmd scripts/export-architecture-png.sh"
echo "  git commit -m 'docs: add architecture diagram PNG for capstone submission'"
echo "  git push origin main"
