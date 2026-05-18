#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EV="${ROOT}/docs/demo-evidence"
OUT="${EV}/DEMO-EVIDENCE.html"

escape() {
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

log_block() {
  local title="$1" file="$2"
  echo "<h2>${title}</h2>"
  if [[ -f "${file}" ]]; then
    echo "<pre>$(cat "${file}" | escape)</pre>"
  else
    echo "<p><em>Missing: ${file}</em></p>"
  fi
}

{
  cat <<'HDR'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>KijaniKiosk Demo Evidence</title>
  <style>
    body { font-family: Menlo, Monaco, monospace; background: #1e1e1e; color: #d4d4d4; margin: 24px; line-height: 1.4; }
    h1 { color: #4ec9b0; font-family: -apple-system, sans-serif; }
    h2 { color: #569cd6; font-family: -apple-system, sans-serif; margin-top: 28px; }
    pre { background: #0d1117; border: 1px solid #30363d; padding: 16px; overflow-x: auto; font-size: 12px; border-radius: 8px; }
    .ok { color: #3fb950; }
    .meta { font-family: -apple-system, sans-serif; color: #8b949e; }
    img { max-width: 100%; border: 1px solid #30363d; border-radius: 8px; }
    a { color: #58a6ff; }
  </style>
</head>
<body>
  <h1>KijaniKiosk — Capstone demo evidence (offline)</h1>
  <p class="meta">Screenshot this page or sections for LMS. Repo: <a href="https://github.com/MachariaBrian12/kijani-kiosk">github.com/MachariaBrian12/kijani-kiosk</a></p>
  <p class="ok">● Generated for submission — mirrors Jenkinsfile with SKIP_AWS_DEPLOY=true</p>
HDR
  log_block "1. Unit tests" "${EV}/01-npm-test.log"
  log_block "2. Fault handling" "${EV}/02-fault-handling.log"
  log_block "3. validate-all.sh" "${EV}/03-validate-all.log"
  log_block "4. Full offline pipeline run" "${EV}/pipeline-run.log"
  echo "<h2>5. Architecture diagram</h2>"
  echo '<img src="../architecture.png" alt="architecture"/>'
  echo "</body></html>"
} > "${OUT}"

echo "Wrote ${OUT}"
echo "Open: open ${OUT}"
