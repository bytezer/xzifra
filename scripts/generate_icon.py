#!/usr/bin/env python3
"""Generate the Xzifra launcher icon assets.

The mark is an original isometric cube with four corner dots, drawn for Xzifra
by xzero and covered by the project's MIT license.
See app/assets/icon/LICENSE-icon.txt.

Usage:
    python3 scripts/generate_icon.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "app" / "assets" / "icon"

SIZE = 1024
SUPERSAMPLE = 4

INDIGO = (79, 70, 229, 255)  # #4F46E5, the app seed color
WHITE = (255, 255, 255, 255)
LIGHT_BG = (245, 245, 247, 255)
DARK_BG = (17, 17, 20, 255)
PASTEL = (232, 222, 248, 255)
INK = (30, 30, 35, 255)

FONT_REGULAR = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

# Isometric cube in a 24-unit viewbox. The cube is 14 units wide and 14.4 tall;
# the four dots sit at the corners of an 18-unit square.
TOP = (12.0, 4.8)
UPPER_RIGHT = (19.0, 8.5)
LOWER_RIGHT = (19.0, 15.5)
BOTTOM = (12.0, 19.2)
LOWER_LEFT = (5.0, 15.5)
UPPER_LEFT = (5.0, 8.5)
CENTER = (12.0, 12.2)
CORNERS = ((3.0, 3.0), (3.0, 21.0), (21.0, 3.0), (21.0, 21.0))


def render_cube(
    *,
    cube_width: int,
    include_corners: bool,
    background: tuple[int, int, int, int] | None = None,
) -> Image.Image:
    """Render the cube with a 1.5-unit stroke, optionally on a background."""
    canvas = SIZE * SUPERSAMPLE
    unit = cube_width * SUPERSAMPLE / 14.0
    stroke = max(1, int(round(1.5 * unit)))
    center = canvas / 2

    mark = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    draw = ImageDraw.Draw(mark)

    def point(x: float, y: float) -> tuple[float, float]:
        return (center + (x - 12.0) * unit, center + (y - 12.0) * unit)

    def dot(x: float, y: float, radius: float) -> None:
        px, py = point(x, y)
        draw.ellipse(
            [px - radius, py - radius, px + radius, py + radius],
            fill=WHITE,
        )

    # Outer hexagon, closed with round joins.
    outer = [
        point(*TOP),
        point(*UPPER_RIGHT),
        point(*LOWER_RIGHT),
        point(*BOTTOM),
        point(*LOWER_LEFT),
        point(*UPPER_LEFT),
        point(*TOP),
    ]
    draw.line(outer, fill=WHITE, width=stroke, joint="curve")
    dot(*TOP, stroke / 2)

    # Inner Y: the visible top face and the vertical front edge.
    for start, end in (
        (UPPER_LEFT, CENTER),
        (UPPER_RIGHT, CENTER),
        (CENTER, BOTTOM),
    ):
        draw.line(
            [point(*start), point(*end)],
            fill=WHITE,
            width=stroke,
        )
        dot(*start, stroke / 2)
        dot(*end, stroke / 2)

    if include_corners:
        for x, y in CORNERS:
            dot(x, y, 0.75 * unit)

    mark = mark.resize((SIZE, SIZE), Image.LANCZOS)
    if background is None:
        return mark

    base = Image.new("RGBA", (SIZE, SIZE), background)
    base.alpha_composite(mark)
    return base


def circle_mask(size: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    return mask


def crop_adaptive_visible(icon: Image.Image, size: int) -> Image.Image:
    """Crop the central 72/108 of an adaptive layer, as the launcher shows it."""
    visible = int(round(SIZE * 72 / 108))
    offset = (SIZE - visible) // 2
    crop = icon.crop((offset, offset, offset + visible, offset + visible))
    return crop.resize((size, size), Image.LANCZOS)


def panel(
    sheet: Image.Image,
    image: Image.Image,
    box: tuple[int, int, int, int],
    *,
    background: tuple[int, int, int, int] | None = None,
    rounded: bool = True,
) -> None:
    x, y, width, height = box
    if background is not None:
        layer = Image.new("RGBA", (width, height), background)
        if rounded:
            mask = Image.new("L", (width, height), 0)
            ImageDraw.Draw(mask).rounded_rectangle(
                (0, 0, width - 1, height - 1), radius=56, fill=255
            )
            layer.putalpha(mask)
        sheet.alpha_composite(layer, (x, y))

    icon = image.resize((width, height), Image.LANCZOS)
    sheet.alpha_composite(icon, (x, y))


def build_preview(
    icon: Image.Image, foreground: Image.Image, monochrome: Image.Image
) -> None:
    width, height = 1400, 1000
    sheet = Image.new("RGBA", (width, height), LIGHT_BG)
    draw = ImageDraw.Draw(sheet)
    title = ImageFont.truetype(FONT_BOLD, 32)
    label = ImageFont.truetype(FONT_REGULAR, 22)
    note = ImageFont.truetype(FONT_REGULAR, 18)

    draw.text((40, 28), "Xzifra icon — isometric cube", font=title, fill=INK)

    size = 300
    y = 100
    positions = [40, 380, 720, 1060]

    # 1. Legacy icon on a light surface (with corner dots).
    panel(
        sheet,
        icon,
        (positions[0], y, size, size),
        background=(255, 255, 255, 255),
    )
    draw.text((positions[0], y + size + 16), "Legacy · light", font=label, fill=INK)

    # 2. Legacy icon on a dark surface.
    panel(sheet, icon, (positions[1], y, size, size), background=DARK_BG)
    draw.text((positions[1], y + size + 16), "Legacy · dark", font=label, fill=INK)

    # 3. Adaptive foreground, trimmed to the 72/108 visible area and masked.
    adaptive = Image.new("RGBA", (size, size), INDIGO)
    adaptive.alpha_composite(crop_adaptive_visible(foreground, size))
    adaptive.putalpha(circle_mask(size))
    sheet.alpha_composite(adaptive, (positions[2], y))
    draw.text(
        (positions[2], y + size + 16),
        "Adaptive · circle mask",
        font=label,
        fill=INK,
    )

    # 4. Monochrome layer, tinted like an Android 13 themed icon.
    themed = Image.new("RGBA", (size, size), PASTEL)
    tint = Image.new("RGBA", (size, size), INDIGO)
    themed.paste(
        tint,
        (0, 0),
        crop_adaptive_visible(monochrome, size),
    )
    themed.putalpha(circle_mask(size))
    sheet.alpha_composite(themed, (positions[3], y))
    draw.text(
        (positions[3], y + size + 16),
        "Monochrome · themed",
        font=label,
        fill=INK,
    )

    # Small sizes, as they appear in a launcher or search result.
    draw.text((40, 520), "Small sizes", font=title, fill=INK)
    x = 40
    for small in (48, 72, 96, 144, 192):
        small_icon = icon.resize((small, small), Image.LANCZOS)
        sheet.alpha_composite(small_icon, (x, 590))
        draw.text((x, 590 + small + 10), f"{small} px", font=note, fill=INK)
        x += small + 48

    draw.text(
        (40, 920),
        "Original isometric cube by xzero · MIT · background #4F46E5",
        font=note,
        fill=(110, 110, 120, 255),
    )

    sheet.convert("RGB").save(OUT / "preview.png", quality=95)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    # Legacy: larger cube, corner dots, solid indigo tile.
    icon = render_cube(
        cube_width=560,
        include_corners=True,
        background=INDIGO,
    )
    # Adaptive: the cube alone, sized to stay inside the 66dp safe zone.
    foreground = render_cube(cube_width=420, include_corners=False)
    monochrome = render_cube(cube_width=420, include_corners=False)

    icon.save(OUT / "icon.png")
    foreground.save(OUT / "icon_foreground.png")
    monochrome.save(OUT / "icon_monochrome.png")
    build_preview(icon, foreground, monochrome)

    print(f"Wrote icon assets to {OUT}")


if __name__ == "__main__":
    main()
