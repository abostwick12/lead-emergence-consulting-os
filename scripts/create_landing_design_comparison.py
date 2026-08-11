"""Build a normalized visual comparison board for landing-page design QA."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def fit(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    copy = image.copy()
    copy.thumbnail(size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", size, "#020713")
    canvas.paste(copy, ((size[0] - copy.width) // 2, (size[1] - copy.height) // 2))
    return canvas


def add_pair(
    board: Image.Image,
    draw: ImageDraw.ImageDraw,
    y: int,
    label: str,
    source: Image.Image,
    implementation: Image.Image,
    slot: tuple[int, int],
) -> int:
    font = ImageFont.load_default(size=20)
    draw.text((30, y), label, fill="#eef4ff", font=font)
    y += 34
    board.paste(fit(source, slot), (30, y))
    board.paste(fit(implementation, slot), (50 + slot[0], y))
    draw.text((30, y + slot[1] + 8), "APPROVED MOCK", fill="#53d7ff", font=font)
    draw.text((50 + slot[0], y + slot[1] + 8), "IMPLEMENTATION", fill="#e5a51c", font=font)
    return y + slot[1] + 54


def build(reference_path: Path, new_reality_path: Path, product_path: Path, output_path: Path) -> None:
    reference = Image.open(reference_path).convert("RGB")
    new_reality = Image.open(new_reality_path).convert("RGB")
    product = Image.open(product_path).convert("RGB")

    board = Image.new("RGB", (1460, 1760), "#01060f")
    draw = ImageDraw.Draw(board)
    title_font = ImageFont.load_default(size=28)
    draw.text((30, 22), "LEAD EMERGENCE LANDING - NORMALIZED DESIGN QA", fill="#ffffff", font=title_font)

    y = 70
    y = add_pair(
        board,
        draw,
        y,
        "NEW REALITY ARTWORK / EXACT GEOMETRY",
        reference.crop((1079, 166, 1272, 339)),
        new_reality.crop((809, 272, 1312, 773)),
        (680, 510),
    )
    y = add_pair(
        board,
        draw,
        y,
        "LOWER-LEFT ENTRY COMPOSITION",
        reference.crop((15, 613, 544, 1002)),
        product.crop((43, 188, 640, 628)),
        (680, 500),
    )
    add_pair(
        board,
        draw,
        y,
        "MINISTRY + CONSULTING LOGIN PANELS",
        reference.crop((544, 623, 1273, 992)),
        product.crop((656, 188, 1492, 628)),
        (680, 420),
    )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    board.save(output_path, optimize=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path)
    parser.add_argument("new_reality", type=Path)
    parser.add_argument("product", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    build(args.reference, args.new_reality, args.product, args.output)
