#!/usr/bin/env python3
"""Generate capstone PDFs from docs/*.md (no AWS required)."""
from __future__ import annotations

import re
import unicodedata
from pathlib import Path

from fpdf import FPDF

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"


def sanitize(text: str) -> str:
    text = unicodedata.normalize("NFKD", text)
    text = text.replace("\u2014", "-").replace("\u2013", "-")
    text = text.replace("\u201c", '"').replace("\u201d", '"')
    text = text.replace("\u2018", "'").replace("\u2019", "'")
    return text.encode("latin-1", "replace").decode("latin-1")


def md_plain(path: Path) -> str:
    t = path.read_text()
    t = re.sub(r"^#+ ", "", t, flags=re.M)
    t = re.sub(r"\*\*([^*]+)\*\*", r"\1", t)
    t = re.sub(r"`([^`]+)`", r"\1", t)
    t = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", t)
    t = re.sub(r"!\[[^\]]*\]\([^)]+\)", "[diagram: architecture.png]", t)
    t = re.sub(r"^> .*$", "", t, flags=re.M)
    return sanitize(t)


class DocPDF(FPDF):
    def footer(self):
        self.set_y(-12)
        self.set_font("Helvetica", "I", 8)
        self.cell(0, 8, f"KijaniKiosk Capstone | page {self.page_no()}", align="C")


def write_lines(pdf: FPDF, text: str, size: int = 10):
    pdf.set_font("Helvetica", size=size)
    w = pdf.epw
    for line in text.splitlines():
        line = line.strip()
        if not line or line == "---":
            pdf.ln(3)
            continue
        if re.match(r"^[\|\-\s]+$", line):
            continue
        if line.startswith("|"):
            line = "  ".join(c.strip() for c in line.split("|") if c.strip())
        pdf.set_x(pdf.l_margin)
        pdf.multi_cell(w, 5, line)


def md_to_pdf(md_file: str, pdf_file: str, title: str | None = None):
    pdf = DocPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    if title:
        pdf.set_font("Helvetica", "B", 14)
        pdf.cell(0, 10, sanitize(title), new_x="LMARGIN", new_y="NEXT")
        pdf.ln(4)
    write_lines(pdf, md_plain(DOCS / md_file))
    out = DOCS / pdf_file
    pdf.output(str(out))
    print(f"wrote {out} ({out.stat().st_size:,} bytes)")


def slides_to_pdf():
    blocks = (DOCS / "slides.md").read_text().split("---")
    pdf = DocPDF()
    pdf.set_auto_page_break(auto=True, margin=12)
    first = True
    for block in blocks:
        block = block.strip()
        if not block or "slide deck" in block.lower():
            continue
        if first:
            first = False
        else:
            pdf.add_page()
        plain = md_plain_from_str(block)
        write_lines(pdf, plain)


def md_plain_from_str(t: str) -> str:
    path = DOCS / "_tmp.md"
    path.write_text(t)
    try:
        return md_plain(path)
    finally:
        path.unlink(missing_ok=True)


def main():
    md_to_pdf("project-scope.md", "project-scope.pdf", "KijaniKiosk Project Scope")
    md_to_pdf("reflection.md", "reflection.pdf", "Capstone Reflection")

    pdf = DocPDF()
    pdf.set_auto_page_break(auto=True, margin=12)
    blocks = (DOCS / "slides.md").read_text().split("---")
    for i, block in enumerate(blocks):
        block = block.strip()
        if not block or "slide deck" in block.lower():
            continue
        pdf.add_page()
        write_lines(pdf, md_plain_from_str(block))
        if "Architecture" in block and (DOCS / "architecture.png").exists():
            pdf.ln(4)
            pdf.image(str(DOCS / "architecture.png"), w=pdf.epw)

    out = DOCS / "slides.pdf"
    pdf.output(str(out))
    print(f"wrote {out} ({out.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
