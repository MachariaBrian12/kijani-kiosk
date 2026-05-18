#!/usr/bin/env bash
# Export capstone markdown deliverables to PDF.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

if [[ ! -d .venv-pdf ]]; then
  python3 -m venv .venv-pdf
  .venv-pdf/bin/pip install -q fpdf2
fi

.venv-pdf/bin/python scripts/generate-pdfs.py
exit 0

# --- Chrome fallback below (optional) ---
DOCS="${ROOT}/docs"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TMP="${TMPDIR:-/tmp}/kijani-pdf-$$"
mkdir -p "${TMP}"

if [[ ! -x "${CHROME}" ]]; then
  echo "ERROR: Google Chrome not found at ${CHROME}"
  exit 1
fi

md_to_html() {
  local src="$1"
  local title="$2"
  local body
  body="$(cat "${src}" | npx -y marked 2>/dev/null || cat "${src}")"
  cat > "${TMP}/page.html" <<HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>${title}</title>
  <style>
    body { font-family: -apple-system, Helvetica, Arial, sans-serif; margin: 40px; line-height: 1.45; font-size: 11pt; color: #111; }
    h1 { font-size: 18pt; border-bottom: 2px solid #1a7f37; padding-bottom: 6px; }
    h2 { font-size: 13pt; margin-top: 18px; color: #1a7f37; }
    table { border-collapse: collapse; width: 100%; margin: 12px 0; font-size: 10pt; }
    th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
    th { background: #f4f4f4; }
    code { background: #f4f4f4; padding: 1px 4px; border-radius: 3px; font-size: 9pt; }
    img { max-width: 100%; height: auto; }
    hr { border: none; border-top: 1px solid #ddd; margin: 24px 0; }
    @page { margin: 0.75in; }
  </style>
</head>
<body>
${body}
</body>
</html>
HTML
}

print_pdf() {
  local html_file="$1"
  local pdf_out="$2"
  "${CHROME}" --headless --disable-gpu --no-pdf-header-footer \
    --print-to-pdf="${pdf_out}" "file://${html_file}" 2>/dev/null
  echo "  -> ${pdf_out}"
}

echo "==> project-scope.pdf"
md_to_html "${DOCS}/project-scope.md" "KijaniKiosk Project Scope"
print_pdf "${TMP}/page.html" "${DOCS}/project-scope.pdf"

echo "==> reflection.pdf"
md_to_html "${DOCS}/reflection.md" "KijaniKiosk Reflection"
print_pdf "${TMP}/page.html" "${DOCS}/reflection.pdf"

echo "==> slides.pdf (with architecture image)"
# slides reference ./architecture.png — use absolute file URL
SLIDES_HTML="${TMP}/slides.html"
cat "${DOCS}/slides.md" | npx -y marked > "${TMP}/slides-body.html" 2>/dev/null || cat "${DOCS}/slides.md" > "${TMP}/slides-body.html"
ARCH_URI="file://${DOCS}/architecture.png"
sed "s|](./architecture.png)|](${ARCH_URI})|g; s|src=\"./architecture.png\"|src=\"${ARCH_URI}\"|g" "${TMP}/slides-body.html" > "${TMP}/slides-fixed.html"
cat > "${SLIDES_HTML}" <<HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>KijaniKiosk Slides</title>
  <style>
    body { font-family: -apple-system, Helvetica, Arial, sans-serif; margin: 36px; line-height: 1.4; font-size: 11pt; }
    h2 { color: #1a7f37; page-break-before: always; margin-top: 0; padding-top: 8px; }
    h2:first-of-type { page-break-before: avoid; }
    img { max-width: 95%; max-height: 420px; display: block; margin: 12px auto; }
    table { font-size: 10pt; border-collapse: collapse; }
    th, td { border: 1px solid #ccc; padding: 5px 8px; }
    hr { display: none; }
    @page { margin: 0.6in; }
  </style>
</head>
<body>
$(cat "${TMP}/slides-fixed.html")
</body>
</html>
HTML
print_pdf "${SLIDES_HTML}" "${DOCS}/slides.pdf"

rm -rf "${TMP}"
echo ""
echo "Done:"
ls -la "${DOCS}"/*.pdf
