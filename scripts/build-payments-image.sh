#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${1:-kijanikiosk/kk-payments:1.1.0}"

docker build -t "${IMAGE}" "${ROOT}/services/kk-payments"
echo "Built ${IMAGE}"
echo "Minikube: minikube image load ${IMAGE}"
