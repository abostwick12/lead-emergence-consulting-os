#!/usr/bin/env python3
"""Extract a DOCX into reviewable, fidelity-oriented Markdown.

The converter preserves document order for paragraphs and tables, includes
paragraph style labels where useful, and appends headers, footers, footnotes,
endnotes, comments, and text-box text when present in the OOXML package.
"""

from __future__ import annotations

import argparse
import re
import sys
import zipfile
from pathlib import Path

from docx import Document
from docx.document import Document as DocumentObject
from docx.oxml.ns import qn
from docx.table import Table
from docx.text.paragraph import Paragraph
from lxml import etree


W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
NS = {"w": W_NS}


def iter_blocks(parent: DocumentObject):
    def walk(element):
        for child in element.iterchildren():
            if child.tag == qn("w:p"):
                yield Paragraph(child, parent)
            elif child.tag == qn("w:tbl"):
                yield Table(child, parent)
            else:
                yield from walk(child)

    yield from walk(parent.element.body)


def clean(text: str) -> str:
    text = text.replace("\u00a0", " ").replace("\r", "")
    return re.sub(r"[ \t]+", " ", text).strip()


def ooxml_text(element) -> str:
    parts: list[str] = []
    for node in element.iter():
        if node.tag in {qn("w:t"), qn("w:delText")}:
            parts.append(node.text or "")
        elif node.tag == qn("w:tab"):
            parts.append("\t")
        elif node.tag in {qn("w:br"), qn("w:cr")}:
            parts.append("\n")
    return clean("".join(parts))


def paragraph_markdown(paragraph: Paragraph) -> str:
    text = ooxml_text(paragraph._p)
    if not text:
        return ""
    style = paragraph.style.name if paragraph.style else ""
    heading = re.match(r"Heading (\d+)", style, re.IGNORECASE)
    if heading:
        level = min(int(heading.group(1)), 6)
        return f"{'#' * level} {text}"
    if style.lower() == "title":
        return f"# {text}"
    if style.lower() == "subtitle":
        return f"_{text}_"
    if "list bullet" in style.lower():
        return f"- {text}"
    if "list number" in style.lower():
        return f"1. {text}"
    if style and style.lower() not in {"normal", "body text"}:
        return f"<!-- style: {style} -->\n{text}"
    return text


def escape_cell(text: str) -> str:
    return clean(text).replace("|", "\\|").replace("\n", "<br>")


def table_markdown(table: Table) -> list[str]:
    rows = [
        [
            escape_cell("\n".join(filter(None, (ooxml_text(paragraph._p) for paragraph in cell.paragraphs))))
            for cell in row.cells
        ]
        for row in table.rows
    ]
    if not rows:
        return []
    width = max(len(row) for row in rows)
    rows = [row + [""] * (width - len(row)) for row in rows]
    lines = ["| " + " | ".join(rows[0]) + " |"]
    lines.append("| " + " | ".join(["---"] * width) + " |")
    lines.extend("| " + " | ".join(row) + " |" for row in rows[1:])
    return lines


def part_text(zf: zipfile.ZipFile, part_name: str) -> list[str]:
    if part_name not in zf.namelist():
        return []
    root = etree.fromstring(zf.read(part_name))
    results: list[str] = []
    for node in root.xpath(".//w:p", namespaces=NS):
        text = clean("".join(node.xpath(".//w:t/text()", namespaces=NS)))
        if text:
            results.append(text)
    return results


def extract(source: Path) -> str:
    doc = Document(source)
    lines: list[str] = []
    for block in iter_blocks(doc):
        if isinstance(block, Paragraph):
            rendered = paragraph_markdown(block)
            if rendered:
                lines.extend([rendered, ""])
        else:
            rendered_table = table_markdown(block)
            if rendered_table:
                lines.extend(rendered_table + [""])

    with zipfile.ZipFile(source) as zf:
        supplemental = {
            "Headers": sorted(n for n in zf.namelist() if re.fullmatch(r"word/header\d+\.xml", n)),
            "Footers": sorted(n for n in zf.namelist() if re.fullmatch(r"word/footer\d+\.xml", n)),
            "Footnotes": ["word/footnotes.xml"],
            "Endnotes": ["word/endnotes.xml"],
            "Comments": ["word/comments.xml"],
        }
        for label, parts in supplemental.items():
            values: list[str] = []
            for part in parts:
                values.extend(part_text(zf, part))
            unique_values = list(dict.fromkeys(values))
            if unique_values:
                lines.extend([f"## {label}", ""])
                lines.extend(f"- {value}" for value in unique_values)
                lines.append("")

        root = etree.fromstring(zf.read("word/document.xml"))
        textbox_values = []
        for node in root.xpath(".//w:txbxContent//w:p", namespaces=NS):
            value = clean("".join(node.xpath(".//w:t/text()", namespaces=NS)))
            if value:
                textbox_values.append(value)
        textbox_values = list(dict.fromkeys(textbox_values))
        if textbox_values:
            lines.extend(["## Text boxes", ""])
            lines.extend(f"- {value}" for value in textbox_values)
            lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    content = extract(args.source)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(content, encoding="utf-8")
    else:
        sys.stdout.reconfigure(encoding="utf-8")
        print(content, end="")


if __name__ == "__main__":
    main()
