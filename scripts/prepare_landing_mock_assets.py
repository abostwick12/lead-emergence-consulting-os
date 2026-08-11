"""Prepare source-faithful landing artwork from the approved mockup.

The roadmap frames are enlarged with conservative contrast and sharpness recovery.
No new geometry is drawn. The product-entry panel is cropped directly from the
approved mockup so its summit, rays, facets, and foreground remain canonical.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter


ROADMAP_FRAMES = (
    "mock-stage-01-see-v9.png",
    "mock-stage-02-reframe-v9.png",
    "mock-stage-03-align-v9.png",
    "mock-stage-04-build-v9.png",
    "mock-stage-05-produce-v9.png",
    "mock-stage-06-new-reality-v9.png",
    "mock-stage-07-see-again-v9.png",
)


def restore_frame(source: Path, destination: Path) -> None:
    image = Image.open(source).convert("RGB")
    image = image.resize((2048, 2048), Image.Resampling.LANCZOS)
    image = ImageEnhance.Contrast(image).enhance(1.06)
    image = ImageEnhance.Color(image).enhance(1.04)
    image = image.filter(ImageFilter.UnsharpMask(radius=1.35, percent=72, threshold=4))
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, optimize=True)


def prepare(reference: Path, roadmap_dir: Path) -> None:
    for frame_name in ROADMAP_FRAMES:
        source = roadmap_dir / frame_name
        destination = roadmap_dir / frame_name.replace("-v9", "-v10")
        restore_frame(source, destination)

    mockup = Image.open(reference).convert("RGB")
    if mockup.size != (1536, 1024):
        raise ValueError(f"Expected the 1536 x 1024 approved mockup, received {mockup.size}")

    # Exact lower-left composition, excluding the outer container stroke.
    intro = mockup.crop((15, 613, 544, 1002))
    intro.save(roadmap_dir / "mock-product-intro-v10.png", optimize=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path)
    parser.add_argument("roadmap_dir", type=Path)
    args = parser.parse_args()
    prepare(args.reference, args.roadmap_dir)
